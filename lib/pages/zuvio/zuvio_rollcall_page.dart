import 'dart:async';

import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nkust_ap/pages/zuvio/ui/zuvio_ui.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/utils/global.dart';

enum _State { checking, notOpen, open, locating, submitting, answered, error }

class ZuvioRollcallPage extends StatefulWidget {
  static const String routerName = '/zuvio/rollcall';

  const ZuvioRollcallPage({super.key, required this.course});

  final ZuvioCourse course;

  @override
  ZuvioRollcallPageState createState() => ZuvioRollcallPageState();
}

class ZuvioRollcallPageState extends State<ZuvioRollcallPage> {
  static const Duration _pollInterval = Duration(seconds: 15);

  _State _state = _State.checking;
  ZuvioRollcall _rollcall = const ZuvioRollcall.notOpen();
  String _errorText = '';
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'ZuvioRollcallPage',
      'zuvio_rollcall_page.dart',
    );
    _check();
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      title: context.t.zuvioRollcall,
      body: RefreshIndicator(
        onRefresh: () => _check(),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ZGap.m,
                    ZGap.xl,
                    ZGap.m,
                    ZGap.xl,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ZCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ZGap.l,
                          vertical: ZGap.xxl,
                        ),
                        child: Column(
                          children: <Widget>[
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              child: _icon(),
                            ),
                            const SizedBox(height: ZGap.l),
                            Text(
                              _title(),
                              textAlign: TextAlign.center,
                              style: context.zt.heading,
                            ),
                            const SizedBox(height: ZGap.s),
                            Text(
                              _subtitle(),
                              textAlign: TextAlign.center,
                              style: context.zt.supporting,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: ZGap.l),
                      _action(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _icon() {
    final ZColors zc = context.zc;
    if (_state == _State.checking ||
        _state == _State.submitting ||
        _state == _State.locating) {
      return const SizedBox(
        key: ValueKey<String>('rc-progress'),
        height: 72,
        width: 72,
        child: Center(
          child: SizedBox(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      );
    }
    final (IconData icon, Color color) = switch (_state) {
      _State.notOpen => (Icons.event_busy_outlined, zc.textSecondary),
      _State.open => (Icons.how_to_reg_outlined, zc.accent),
      _State.error => (Icons.error_outline_rounded, zc.danger),
      _State.answered => (Icons.check_circle_rounded, zc.success),
      _ => (Icons.help_outline_rounded, zc.textSecondary),
    };
    return Container(
      key: ValueKey<_State>(_state),
      height: 72,
      width: 72,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 38, color: color),
    );
  }

  String _title() {
    return switch (_state) {
      _State.checking => context.t.loading,
      _State.notOpen => context.t.zuvioRollcallNotOpen,
      _State.open => context.t.zuvioRollcallOpen,
      _State.locating => context.t.zuvioLocating,
      _State.submitting => context.t.zuvioSigningIn,
      _State.answered => context.t.zuvioSignInSuccess,
      _State.error => context.ap.somethingError,
    };
  }

  String _subtitle() {
    return switch (_state) {
      _State.open => context.t.zuvioRollcallTapHint,
      _State.answered => zuvioTime(_rollcall.answeredAt ?? DateTime.now()),
      _State.error => _errorText,
      _ => widget.course.name,
    };
  }

  Widget _action() {
    return switch (_state) {
      _State.open => ZButton(
          label: context.t.zuvioSignIn,
          icon: Icons.how_to_reg_rounded,
          onPressed: _signIn,
        ),
      _State.error => ZButton(
          label: context.ap.retry,
          variant: ZButtonVariant.secondary,
          onPressed: () => _check(),
        ),
      _ => const SizedBox.shrink(),
    };
  }

  /// [silent] refreshes are the background poll: no spinner, and a
  /// transient failure keeps the current "not open" view rather than
  /// flipping to the error state.
  Future<void> _check({bool silent = false}) async {
    _poll?.cancel();
    if (!silent) setState(() => _state = _State.checking);
    try {
      final ZuvioRollcall rollcall = await ZuvioService.instance
          .getCurrentRollcall(widget.course.courseId);
      if (!mounted) return;
      setState(() {
        _rollcall = rollcall;
        _state = switch (rollcall.state) {
          ZuvioRollcallState.open => _State.open,
          ZuvioRollcallState.answered => _State.answered,
          _ => _State.notOpen,
        };
      });
    } on ZuvioException catch (e) {
      if (!mounted) return;
      if (!silent) {
        setState(() {
          _state = _State.error;
          _errorText = _localizedError(e);
        });
      }
    }
    if (mounted && _state == _State.notOpen) {
      _poll = Timer(_pollInterval, () => _check(silent: true));
    }
  }

  Future<void> _signIn() async {
    _poll?.cancel();
    setState(() => _state = _State.submitting);
    AnalyticsUtil.instance.logEvent('zuvio_rollcall_sign_in');
    try {
      await ZuvioService.instance
          .makeRollcall(rollcallId: _rollcall.rollcallId);
      _markAnswered();
    } on ZuvioException catch (e) {
      if (e.code == ZuvioErrorCode.rollcallNeedLocation) {
        await _signInWithLocation();
        return;
      }
      _showError(_localizedError(e));
    }
  }

  Future<void> _signInWithLocation() async {
    if (!mounted) return;
    setState(() => _state = _State.locating);

    final String serviceOff = context.t.zuvioLocationServiceOff;
    final String denied = context.t.zuvioLocationDeniedHint;
    final String failed = context.t.zuvioLocationDenied;

    Position position;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showError(serviceOff);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showError(denied);
        return;
      }
      position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (_) {
      _showError(failed);
      return;
    }

    if (!mounted) return;
    setState(() => _state = _State.submitting);
    try {
      await ZuvioService.instance.makeRollcall(
        rollcallId: _rollcall.rollcallId,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      _markAnswered();
    } on ZuvioException catch (e) {
      _showError(_localizedError(e));
    }
  }

  String _localizedError(ZuvioException e) {
    return switch (e.code) {
      ZuvioErrorCode.rollcallNotOnair => context.t.zuvioRollcallNotOpen,
      ZuvioErrorCode.rollcallNeedLocation =>
        context.t.zuvioRollcallNeedLocation,
      ZuvioErrorCode.rollcallAnswered =>
        context.t.zuvioRollcallAlreadyAnswered,
      ZuvioErrorCode.rollcallExpired => context.t.zuvioRollcallExpired,
      ZuvioErrorCode.network => context.t.zuvioErrorNetwork,
      ZuvioErrorCode.sessionExpired => context.t.zuvioErrorSessionExpired,
      ZuvioErrorCode.unexpected => context.t.zuvioErrorUnexpected,
      _ => e.message,
    };
  }

  void _markAnswered() {
    if (!mounted) return;
    setState(() {
      _rollcall = ZuvioRollcall(
        rollcallId: _rollcall.rollcallId,
        state: ZuvioRollcallState.answered,
        answeredAt: DateTime.now(),
      );
      _state = _State.answered;
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _state = _State.error;
      _errorText = message;
    });
  }
}
