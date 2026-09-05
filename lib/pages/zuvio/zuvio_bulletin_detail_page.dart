import 'dart:io';

import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/ui/zuvio_ui.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ZuvioBulletinDetailPage extends StatefulWidget {
  static const String routerName = '/zuvio/bulletin/detail';

  const ZuvioBulletinDetailPage({super.key, required this.summary});

  final ZuvioBulletin summary;

  @override
  ZuvioBulletinDetailPageState createState() =>
      ZuvioBulletinDetailPageState();
}

class ZuvioBulletinDetailPageState extends State<ZuvioBulletinDetailPage> {
  late ZuvioBulletin _bulletin = widget.summary;
  bool _loading = true;
  String? _downloadingName;

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'ZuvioBulletinDetailPage',
      'zuvio_bulletin_detail_page.dart',
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final ZColors zc = context.zc;
    return ZScaffold(
      title: context.t.zuvioBulletin,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(ZGap.m, ZGap.l, ZGap.m, ZGap.xxl),
        children: <Widget>[
          Text(_bulletin.title, style: context.zt.pageTitle),
          const SizedBox(height: ZGap.s),
          Text(
            '${_bulletin.author} · ${zuvioDateTime(_bulletin.date)}',
            style: context.zt.label,
          ),
          const SizedBox(height: ZGap.l),
          if (_loading && _bulletin.content.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: ZGap.xxl),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
            )
          else
            SelectableText(
              _bulletin.content,
              style: context.zt.body.copyWith(fontSize: 15, height: 1.65),
            ),
          if (_bulletin.attachments.isNotEmpty) ...<Widget>[
            const SizedBox(height: ZGap.xl),
            ZSectionHeader(context.t.zuvioBulletinAttachments),
            Padding(
              padding: const EdgeInsets.only(bottom: ZGap.s),
              child: Text(
                context.t.zuvioAttachmentHint,
                style: context.zt.label,
              ),
            ),
            for (final ZuvioAttachment file in _bulletin.attachments)
              Padding(
                padding: const EdgeInsets.only(bottom: ZGap.s),
                child: ZCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ZGap.m,
                    vertical: ZGap.sm,
                  ),
                  onTap: _downloadingName == null
                      ? () => _openAttachment(file)
                      : null,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.description_outlined,
                        size: 20,
                        color: zc.textSecondary,
                      ),
                      const SizedBox(width: ZGap.sm),
                      Expanded(
                        child: Text(
                          file.name,
                          style: context.zt.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_downloadingName == file.name)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          Icons.ios_share_rounded,
                          size: 16,
                          color: zc.textFaint,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// Downloads the attachment through our own authenticated client and
  /// hands the OS a local file to open/share — never a Zuvio URL. The
  /// download URL carries `user_id` + `accessToken` in the query string,
  /// so passing it to an external browser or share sheet would leak the
  /// session token into browser history / referer headers.
  Future<void> _openAttachment(ZuvioAttachment file) async {
    setState(() => _downloadingName = file.name);
    try {
      final List<int> bytes =
          await ZuvioService.instance.downloadAttachment(file);
      final Directory dir = await getTemporaryDirectory();
      final String safeName =
          file.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final File localFile = File('${dir.path}/$safeName');
      await localFile.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      await Share.shareXFiles(<XFile>[XFile(localFile.path, name: file.name)]);
    } on ZuvioException catch (e) {
      if (!mounted) return;
      UiUtil.instance.showToast(context, e.message);
    } finally {
      if (mounted) setState(() => _downloadingName = null);
    }
  }

  Future<void> _load() async {
    if (_bulletin.id.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final ZuvioBulletin? full =
          await ZuvioService.instance.getBulletinDetail(_bulletin.id);
      if (!mounted) return;
      setState(() {
        if (full != null) _bulletin = full;
        _loading = false;
      });
    } on ZuvioException {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }
}
