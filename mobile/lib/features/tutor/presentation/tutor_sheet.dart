import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../data/tutor_repository.dart';

class GrammarTutorButton extends StatelessWidget {
  const GrammarTutorButton({
    super.key,
    this.grammarPointId,
    this.lessonAttemptId,
    this.questionCode,
    this.wrongAnswer = false,
    this.reviewFeedback = false,
  }) : assert((grammarPointId == null) != (lessonAttemptId == null));

  final int? grammarPointId;
  final int? lessonAttemptId;
  final String? questionCode;
  final bool wrongAnswer;
  final bool reviewFeedback;

  @override
  Widget build(BuildContext context) {
    void openTutor() {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => GrammarTutorSheet(
          grammarPointId: grammarPointId,
          lessonAttemptId: lessonAttemptId,
          initialMessage: lessonAttemptId == null ? null : '帮我总结这次练习',
          questionCode: questionCode,
          scene: lessonAttemptId != null
              ? 'result'
              : questionCode == null
              ? 'teaching'
              : wrongAnswer
              ? 'wrong'
              : 'answered',
        ),
      );
    }

    if (reviewFeedback && wrongAnswer) {
      return OutlinedButton(
        onPressed: openTutor,
        child: const Text(
          '🐱 还是没弄懂？\n问 Grammar Cat',
          textAlign: TextAlign.center,
        ),
      );
    }
    return TextButton(
      onPressed: openTutor,
      child: Text(
        lessonAttemptId != null
            ? '帮我总结这次练习'
            : questionCode == null
            ? '🐱 问 Grammar Cat'
            : wrongAnswer
            ? '🐱 不明白为什么？问 Grammar Cat'
            : '还有疑问？问 Grammar Cat',
      ),
    );
  }
}

class GrammarTutorSheet extends ConsumerStatefulWidget {
  const GrammarTutorSheet({
    super.key,
    this.grammarPointId,
    this.lessonAttemptId,
    this.initialMessage,
    this.questionCode,
    this.scene = 'teaching',
  }) : assert((grammarPointId == null) != (lessonAttemptId == null));

  final int? grammarPointId;
  final int? lessonAttemptId;
  final String? initialMessage;
  final String? questionCode;
  final String scene;

  @override
  ConsumerState<GrammarTutorSheet> createState() => _GrammarTutorSheetState();
}

class _GrammarTutorSheetState extends ConsumerState<GrammarTutorSheet> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<TutorMessage> _messages = [];
  List<String> _suggestions = [];
  bool _loading = true;
  bool _available = false;
  bool _sending = false;
  String? _error;
  bool _initialMessageStarted = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final status = await ref
          .read(tutorRepositoryProvider)
          .status(widget.scene, lessonAttemptId: widget.lessonAttemptId);
      if (!mounted) return;
      setState(() {
        _available = status.available;
        _suggestions = status.suggestedQuestions;
        _loading = false;
      });
      if (_available &&
          !_initialMessageStarted &&
          widget.initialMessage != null) {
        _initialMessageStarted = true;
        _input.text = widget.initialMessage!;
        await _send();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _available = false;
        _error = error is AppException && error.code == 40311
            ? '只能总结你自己已完成的这次练习。'
            : 'Grammar Cat 暂时无法连接，请稍后重试。';
      });
    }
  }

  Future<void> _send([String? suggested]) async {
    final text = (suggested ?? _input.text).trim();
    if (_sending || !_available || text.isEmpty) return;
    if (text.length > 2000) {
      setState(() => _error = '请将问题控制在 2000 字以内。');
      return;
    }
    final history = List<TutorMessage>.of(_messages);
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final reply = await ref
          .read(tutorRepositoryProvider)
          .chat(
            grammarPointId: widget.grammarPointId,
            lessonAttemptId: widget.lessonAttemptId,
            questionCode: widget.questionCode,
            message: text,
            history: history,
          );
      if (!mounted) return;
      setState(() {
        _messages.addAll([
          TutorMessage('user', text),
          TutorMessage('assistant', reply.answer),
        ]);
        if (_messages.length > 8) {
          _messages.removeRange(0, _messages.length - 8);
        }
        _suggestions = reply.suggestedQuestions;
        _input.clear();
      });
    } on AppException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = switch (error.code) {
          50310 => 'Grammar Cat AI 暂未开启或暂时不可用。',
          50410 => 'Grammar Cat 回答超时，请重试。',
          42910 => 'Grammar Cat 正忙，请稍后重试。',
          40310 => '请先提交这道题，再询问解析。',
          40311 => '只能总结你自己已完成的这次练习。',
          50210 => 'Grammar Cat 暂时不可用，请稍后重试。',
          _ => error.message,
        };
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'Grammar Cat 暂时不可用，请稍后重试。');
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scroll.hasClients) {
            _scroll.jumpTo(_scroll.position.maxScrollExtent);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.78,
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: const Text('🐱 Grammar Cat'),
              trailing: IconButton(
                tooltip: '关闭',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (_loading) const LinearProgressIndicator(),
                  if (!_loading && !_available) ...[
                    if (_error == null)
                      const Text('Grammar Cat AI 暂未开启，你可以继续学习。'),
                    TextButton(
                      onPressed: _loadStatus,
                      child: const Text('重新检查'),
                    ),
                  ],
                  if (_available) ...[
                    const Text('围绕当前知识点提问'),
                    for (final question in _suggestions)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: _sending ? null : () => _send(question),
                          child: Text(question),
                        ),
                      ),
                  ],
                  for (final message in _messages)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SelectableText(
                        '${message.role == 'user' ? '你' : 'Grammar Cat'}：${message.content}',
                      ),
                    ),
                  if (_sending) const Text('Grammar Cat 正在思考…'),
                  if (_error != null) Text(_error!),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      enabled: _available && !_sending,
                      maxLength: 2000,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: '输入你的问题'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _available && !_sending ? () => _send() : null,
                    child: const Text('发送'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
