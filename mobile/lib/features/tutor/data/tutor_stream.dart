import 'dart:async';
import 'dart:convert';

import '../../../core/error/app_exception.dart';

class TutorStreamEvent {
  const TutorStreamEvent.delta(this.content)
      : done = false, suggestedQuestions = const [];
  const TutorStreamEvent.done(this.suggestedQuestions)
      : done = true, content = '';
  final String content;
  final bool done;
  final List<String> suggestedQuestions;
}

/// Byte boundaries may split UTF-8, JSON, or an SSE frame. Only blank lines dispatch events.
Stream<TutorStreamEvent> decodeTutorStream(Stream<List<int>> bytes) async* {
  var event = '';
  final data = <String>[];
  var frameSize = 0;
  var contentSize = 0;
  try {
    // Dio emits Stream<Uint8List>. Widen the runtime stream type before applying
    // Utf8Decoder; a Stream<List<int>> parameter alone does not perform this cast.
    final lines = bytes
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    await for (final line in lines) {
      if (line.isEmpty) {
        if (data.isEmpty) { event = ''; continue; }
        final raw = jsonDecode(data.join('\n'));
        if (raw is! Map) throw const FormatException('Invalid SSE data');
        data.clear();
        frameSize = 0;
        switch (event) {
          case 'delta':
            final content = raw['content'];
            if (content is! String) throw const FormatException('Invalid delta');
            contentSize += content.length;
            if (contentSize > 12000) throw const FormatException('Response too long');
            yield TutorStreamEvent.delta(content);
          case 'done':
            final questions = raw['suggestedQuestions'];
            if (questions != null && questions is! List) throw const FormatException('Invalid suggestions');
            yield TutorStreamEvent.done(questions == null ? const [] : [
              for (final item in (questions as List).take(4)) (item as Map)['text'] as String,
            ]);
            return;
          case 'error':
            throw AppException('Grammar Cat 回复失败，请重试。',
                code: int.tryParse('${raw['code']}'), type: AppErrorType.business);
          default:
            throw const FormatException('Unknown SSE event');
        }
        event = '';
      } else if (line.startsWith('event:')) {
        event = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        var value = line.substring(5);
        if (value.startsWith(' ')) value = value.substring(1);
        frameSize += value.length;
        if (frameSize > 65536) throw const FormatException('Frame too long');
        data.add(value);
      }
      // Comments / id / retry fields are not assistant text.
    }
  } on AppException {
    rethrow;
  } on TimeoutException {
    throw const AppException('回复超时，请重试。', code: 50410);
  } catch (_) {
    throw const AppException('回复中断，请重试。', code: 50210);
  }
  throw const AppException('回复中断，请重试。', code: 50210); // No terminal done event.
}
