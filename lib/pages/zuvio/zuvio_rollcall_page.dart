import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/utils/global.dart';

enum _State {
  checking,
  notOpen,
  needLocation,
  locating,
  locationDenied,
  ready,
  submitting,
  answered,
  error,
}

class ZuvioRollcallPage extends StatefulWidget {
  static const String routerName = '/zuvio/rollcall';

  const ZuvioRollcallPage({super.key, required this.course});

  final ZuvioCourse course;

  @override
  ZuvioRollcallPageState createState() => ZuvioRollcallPageState();
}

class ZuvioRollcallPageState extends State<ZuvioRollcallPage> {
  _State _state = _State.checking;
  ZuvioRollcall _rollcall = const ZuvioRollcall.notOpen();
  ZuvioLocation? _location;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'ZuvioRollcallPage',
      'zuvio_rollcall_page.dart',
    );
    _checkRollcall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.zuvioRollcall)),
      body: RefreshIndicator(
        onRefresh: _checkRollcall,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            const SizedBox(height: 32),
            _statusIcon(),
            const SizedBox(height: 24),
            Text(
              _statusTitle(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _statusSubtitle(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (_location != null) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                '${_location!.latitude.toStringAsFixed(6)}, '
                '${_location!.longitude.toStringAsFixed(6)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 40),
            _actionButton(),
          ],
        ),
      ),
    );
  }

  Widget _statusIcon() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    late final IconData icon;
    late final Color color;
    switch (_state) {
      case _State.checking:
      case _State.locating:
      case _State.submitting:
        return const Center(child: CircularProgressIndicator());
      case _State.notOpen:
        icon = Icons.event_busy_outlined;
        color = colorScheme.onSurfaceVariant;
      case _State.needLocation:
      case _State.ready:
        icon = Icons.location_on_outlined;
        color = colorScheme.primary;
      case _State.locationDenied:
      case _State.error:
        icon = Icons.error_outline_rounded;
        color = colorScheme.error;
      case _State.answered:
        icon = Icons.check_circle_outline_rounded;
        color = Colors.green;
    }
    return Icon(icon, size: 88, color: color);
  }

  String _statusTitle() {
    switch (_state) {
      case _State.checking:
        return context.t.loading;
      case _State.notOpen:
        return context.t.zuvioRollcallNotOpen;
      case _State.needLocation:
      case _State.ready:
        return context.t.zuvioRollcallOpen;
      case _State.locating:
        return context.t.zuvioLocating;
      case _State.locationDenied:
        return context.t.zuvioLocationDenied;
      case _State.submitting:
        return context.t.zuvioSigningIn;
      case _State.answered:
        return context.t.zuvioSignInSuccess;
      case _State.error:
        return context.ap.somethingError;
    }
  }

  String _statusSubtitle() {
    switch (_state) {
      case _State.needLocation:
      case _State.ready:
        return context.t.zuvioRollcallGpsHint;
      case _State.locationDenied:
        return context.t.zuvioLocationDeniedHint;
      case _State.answered:
        final DateTime at = _rollcall.answeredAt ?? DateTime.now();
        return '${at.hour.toString().padLeft(2, '0')}:'
            '${at.minute.toString().padLeft(2, '0')}';
      case _State.error:
        return _errorText;
      default:
        return widget.course.name;
    }
  }

  Widget _actionButton() {
    switch (_state) {
      case _State.needLocation:
      case _State.ready:
        return ApButton(
          text: context.t.zuvioSignIn,
          onPressed: _signIn,
        );
      case _State.locationDenied:
      case _State.error:
        return ApButton(
          text: context.t.tapToRetry,
          onPressed: _checkRollcall,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _checkRollcall() async {
    setState(() {
      _state = _State.checking;
      _location = null;
    });
    try {
      final ZuvioRollcall rollcall = await ZuvioService.instance
          .getCurrentRollcall(widget.course.courseId);
      if (!mounted) return;
      setState(() {
        _rollcall = rollcall;
        switch (rollcall.state) {
          case ZuvioRollcallState.open:
            _state = _State.needLocation;
          case ZuvioRollcallState.answered:
            _state = _State.answered;
          case ZuvioRollcallState.notOpen:
          case ZuvioRollcallState.absent:
          case ZuvioRollcallState.leave:
            _state = _State.notOpen;
        }
      });
    } on ZuvioException catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _State.error;
        _errorText = e.message;
      });
    }
  }

  Future<void> _signIn() async {
    setState(() => _state = _State.locating);
    final ZuvioLocation? location = await _acquireLocation();
    if (!mounted) return;
    if (location == null) {
      setState(() => _state = _State.locationDenied);
      return;
    }
    setState(() {
      _location = location;
      _state = _State.submitting;
    });
    AnalyticsUtil.instance.logEvent('zuvio_rollcall_sign_in');
    try {
      await ZuvioService.instance.makeRollcall(
        rollcallId: _rollcall.rollcallId,
        location: location,
      );
      if (!mounted) return;
      setState(() {
        _rollcall = ZuvioRollcall(
          rollcallId: _rollcall.rollcallId,
          state: ZuvioRollcallState.answered,
          answeredAt: DateTime.now(),
        );
        _state = _State.answered;
      });
    } on ZuvioException catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _State.error;
        _errorText = e.message;
      });
    }
  }

  /// Device GPS. Replace with a `geolocator` call once the platform
  /// location permission plumbing is wired.
  Future<ZuvioLocation?> _acquireLocation() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return const ZuvioLocation(latitude: 22.652, longitude: 120.328);
  }
}
