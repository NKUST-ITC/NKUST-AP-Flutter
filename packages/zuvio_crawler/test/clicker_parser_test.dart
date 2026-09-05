import 'package:test/test.dart';
import 'package:zuvio_crawler/src/models/models.dart';
import 'package:zuvio_crawler/src/parsers/clicker_parser.dart';

import 'support.dart';

void main() {
  test('returns the live question with its name and id', () {
    final ZuvioClickerQuestion? q =
        parseLiveClicker(fixture('clicker_live.html'));
    expect(q, isNotNull);
    expect(q!.id, '7788');
    expect(q.name, contains('堆疊操作'));
    expect(q.isLive, isTrue);
    expect(q.answered, isFalse);
  });

  test('returns null when nothing is playing', () {
    expect(parseLiveClicker(fixture('clicker_idle.html')), isNull);
  });
}
