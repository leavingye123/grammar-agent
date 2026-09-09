import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:grammar_agent/core/error/app_exception.dart';
import 'package:grammar_agent/features/tutor/data/tutor_stream.dart';

void main() {
  test('Dio Uint8List stream stays subscribed after heartbeat and emits live deltas', () async {
    var cancelled = false;
    final source = StreamController<Uint8List>(onCancel: () { cancelled = true; });
    final events = StreamIterator(decodeTutorStream(source.stream));
    try {
      final first = events.moveNext();
      source.add(Uint8List.fromList(utf8.encode(': keepalive\n\n')));
      await Future<void>.delayed(Duration.zero);
      expect(cancelled, isFalse);
      // Keep the source open: first delta must arrive before done or EOF.
      for (final byte in utf8.encode('event: delta\ndata: {"content":"中文🐱"}\n\n')) {
        source.add(Uint8List.fromList([byte]));
      }
      expect(await first, isTrue);
      expect(events.current.content, '中文🐱');
      expect(cancelled, isFalse);
      source.add(Uint8List.fromList(utf8.encode('event: done\ndata: {}\n\n')));
      expect(await events.moveNext(), isTrue);
      expect(events.current.done, isTrue);
      expect(await events.moveNext(), isFalse);
    } finally {
      await events.cancel();
      unawaited(source.close());
    }
  });

  test('UTF-8 Chinese, emoji, newline and JSON survive every byte boundary', () async {
    final frame = ': keepalive\r\n\r\nevent: delta\r\ndata: ${jsonEncode({'content': '中文🐱\n**are**'})}\r\n\r\n'
        'event: delta\ndata: {"content":"ABC"}\n\nevent: done\ndata: {}\n\n';
    final events = await decodeTutorStream(Stream.fromIterable(
      utf8.encode(frame).map((byte) => <int>[byte]),
    )).toList();
    expect(events.map((e) => e.content), ['中文🐱\n**are**', 'ABC', '']);
    expect(events.last.done, isTrue);
  });

  test('partial content precedes a safe provider error', () async {
    final stream = decodeTutorStream(Stream.value(utf8.encode(
      'event: delta\ndata: {"content":"partial"}\n\n'
      'event: error\ndata: {"code":"42910","message":"secret"}\n\n',
    )));
    await expectLater(stream, emitsInOrder([
      isA<TutorStreamEvent>().having((e) => e.content, 'partial', 'partial'),
      emitsError(isA<AppException>()
          .having((e) => e.code, 'code', 42910)
          .having((e) => e.message, 'safe message', isNot(contains('secret')))),
      emitsDone,
    ]));
  });

  for (final body in [
    'event: delta\ndata: bad-json\n\n',
    'event: delta\ndata: {"content":7}\n\n',
    'event: delta\ndata: {"content":"A"}\n\n',
    'event: done\ndata: {"suggestedQuestions":7}\n\n',
    'event: delta\ndata: {"content":"A"}',
  ]) {
    test('malformed frame or missing done is an error: $body', () async {
      await expectLater(decodeTutorStream(Stream.value(utf8.encode(body))).toList(),
          throwsA(isA<AppException>().having((e) => e.code, 'code', 50210)));
    });
  }
}
