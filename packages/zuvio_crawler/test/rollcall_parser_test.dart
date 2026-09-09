import 'package:test/test.dart';
import 'package:zuvio_crawler/src/models/models.dart';
import 'package:zuvio_crawler/src/parsers/rollcall_parser.dart';

import 'support.dart';

void main() {
  test('detects an open rollcall and its id', () {
    final ZuvioRollcall r = parseRollcall(fixture('rollcall_open.html'));
    expect(r.state, ZuvioRollcallState.open);
    expect(r.rollcallId, '55501');
  });

  test('detects an already-answered rollcall', () {
    final ZuvioRollcall r = parseRollcall(fixture('rollcall_answered.html'));
    expect(r.state, ZuvioRollcallState.answered);
    expect(r.rollcallId, '55501');
  });

  test('reports notOpen when no rollcall is running', () {
    final ZuvioRollcall r = parseRollcall(fixture('rollcall_closed.html'));
    expect(r.state, ZuvioRollcallState.notOpen);
    expect(r.rollcallId, isEmpty);
  });
}
