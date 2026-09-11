import 'dart:convert' show utf8;
import 'dart:io' show SecurityContext, TlsException;

import 'package:ap_common/ap_common.dart';
import 'package:flutter/foundation.dart' show Uint8List, debugPrint;
import 'package:flutter/services.dart' show ByteData, PlatformAssetBundle;
import 'package:nkust_ap/config/constants.dart';

/// The set of root CAs the app trusts for NKUST hosts, on top of whatever
/// the platform already trusts.
///
/// # Why this exists
///
/// NKUST's certificates chain to TWCA roots that rotate independently of the
/// leaf. The 2025 leaf chained to `TWCA Global Root CA`; the one issued
/// 2026-09-08 chains to `TWCA CYBER Root CA`, which Apple's trust store does
/// not carry — so every Apple HTTP stack started rejecting the school
/// outright. Android was unaffected because Cronet validates against the
/// Chrome Root Store, which does carry it.
///
/// The app used to pin the *leaf*, which meant a manual asset swap and an
/// app release every year when the certificate was reissued. Pinning roots
/// instead removes that: the shortest-lived root in the shipped bundle runs
/// to 2030, and the one actually in use to 2047.
///
/// # Why it is remotely updatable
///
/// Roots outliving leaves fixes the annual churn but not the failure mode
/// that broke iOS — the school moving to a CA the app has never heard of. An
/// app release cannot be the answer to that, because it strands everyone who
/// has not updated. So the bundle is overridable from Remote Config
/// ([Constants.caBundlePem]): a CA change becomes a config push, no release
/// and no review.
///
/// Two properties keep that from being a backdoor:
///
/// - anchors are *added* to the platform roots, never substituted for them,
///   and certificate validation is never disabled;
/// - a bundle that does not parse as certificates is rejected and the
///   previous one kept, so a malformed push cannot take the app offline.
///
/// A newly fetched bundle takes effect on the next cold start rather than
/// mid-session: the [SecurityContext] is built once and handed to long-lived
/// HTTP clients, and swapping it underneath them is not worth the complexity
/// for a change that happens years apart.
class CaTrustBundle {
  const CaTrustBundle._(this.securityContext, {required this.fromRemote});

  /// Ships with the app as the floor — used on first run, and whenever a
  /// remote bundle is absent or rejected.
  static const String assetPath = 'assets/ca/twca_roots.pem';

  static CaTrustBundle? _instance;

  /// The bundle resolved at startup. Throws if [load] has not run yet.
  static CaTrustBundle get instance {
    final CaTrustBundle? bundle = _instance;
    if (bundle == null) {
      throw StateError('CaTrustBundle.load() must run before first use');
    }
    return bundle;
  }

  /// Platform roots plus this bundle's anchors.
  final SecurityContext securityContext;

  /// Whether the anchors came from Remote Config rather than the asset.
  /// Only interesting for diagnostics.
  final bool fromRemote;

  /// Resolves the bundle to use for this run: the last one Remote Config
  /// handed us if there is one, otherwise the shipped asset.
  static Future<CaTrustBundle> load() async {
    final String cached = PreferenceUtil.instance.getString(
      Constants.prefCaBundlePem,
      '',
    );
    if (cached.isNotEmpty) {
      final SecurityContext? context = _buildContext(cached);
      if (context != null) {
        return _instance = CaTrustBundle._(context, fromRemote: true);
      }
      // No longer loads (truncated write, format change). Drop it so the
      // next fetch can replace it, and fall back to the asset.
      debugPrint('[ca] cached bundle rejected, falling back to asset');
      PreferenceUtil.instance.setString(Constants.prefCaBundlePem, '');
    }

    final ByteData data = await PlatformAssetBundle().load(assetPath);
    final SecurityContext context = SecurityContext(withTrustedRoots: true)
      ..setTrustedCertificatesBytes(data.buffer.asUint8List());
    return _instance = CaTrustBundle._(context, fromRemote: false);
  }

  /// Stores a bundle pushed through Remote Config, to be picked up on the
  /// next launch. Returns whether it was accepted.
  ///
  /// Call this from wherever Remote Config is already being fetched — it
  /// deliberately does no fetching of its own.
  static bool acceptRemote(String pem) {
    if (pem.isEmpty) return false;

    final String current = PreferenceUtil.instance.getString(
      Constants.prefCaBundlePem,
      '',
    );
    if (pem == current) return false;

    if (_buildContext(pem) == null) {
      debugPrint('[ca] remote bundle rejected: not a usable certificate set');
      return false;
    }

    PreferenceUtil.instance.setString(Constants.prefCaBundlePem, pem);
    debugPrint('[ca] remote bundle accepted, active from next launch');
    return true;
  }

  /// Builds a context from [pem], or returns null if it is not a certificate
  /// bundle this platform can load. Anchors already present in the platform
  /// store are absorbed silently, so a bundle that overlaps the system roots
  /// is still accepted.
  static SecurityContext? _buildContext(String pem) {
    final SecurityContext context = SecurityContext(withTrustedRoots: true);
    try {
      context.setTrustedCertificatesBytes(Uint8List.fromList(utf8.encode(pem)));
      return context;
    } on TlsException {
      return null;
    }
  }
}
