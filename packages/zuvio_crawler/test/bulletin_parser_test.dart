import 'package:test/test.dart';
import 'package:zuvio_crawler/src/models/models.dart';
import 'package:zuvio_crawler/src/parsers/bulletin_parser.dart';

import 'support.dart';

void main() {
  group('parseBulletins', () {
    test('reads every card with id, author, title and date', () {
      final List<ZuvioBulletin> list =
          parseBulletins(fixture('bulletins_list.html'));
      expect(list, hasLength(2));
      expect(list.first.id, '377401');
      expect(list.first.author, '示範老師甲');
      expect(list.first.title, '第一次作業說明');
      expect(list.first.content, '請於下週前繳交，格式見附件。');
      expect(list.first.date, DateTime.parse('2025-03-01T12:30'));
    });
  });

  group('parseBulletinDetail', () {
    test('turns <br> into newlines in the body', () {
      final ZuvioBulletin? b = parseBulletinDetail(
        fixture('bulletin_detail.html'),
        id: '377401',
      );
      expect(b, isNotNull);
      expect(b!.content, '第一行說明\n第二行說明');
    });

    test('extracts attachments from SaveToDisk handlers', () {
      final ZuvioBulletin b = parseBulletinDetail(
        fixture('bulletin_detail.html'),
        id: '377401',
      )!;
      expect(b.attachments, hasLength(2));
      expect(b.attachments.first.name, '作業一.pdf');
      expect(b.attachments.first.url, 'https://example.invalid/files/hw1.pdf');
      expect(b.attachments.last.name, '評分表.xlsx');
    });
  });
}
