import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/network/learning_refresh.dart';
import '../data/lesson_repository.dart';
import '../domain/lesson_models.dart';

final lessonRepositoryProvider = Provider<LessonRepository>(
  (ref) => LessonRepository(ref.watch(apiClientProvider)),
);
final lessonSessionProvider = NotifierProvider.autoDispose
    .family<LessonSessionController, LessonSessionState, int>(
      (lessonId) => LessonSessionController(lessonId),
    );

class LessonSessionState {
  const LessonSessionState({
    required this.lessonId,
    this.questions = const [],
    this.currentIndex = 0,
    this.answer,
    this.feedback,
    this.results = const [],
    this.loading = true,
    this.submitting = false,
    this.error,
  });
  final int lessonId;
  final List<Question> questions;
  final int currentIndex;
  final Object? answer;
  final SubmitAnswerResult? feedback;
  final List<SubmitAnswerResult> results;
  final bool loading;
  final bool submitting;
  final String? error;
  Question? get current => questions.isEmpty || currentIndex >= questions.length
      ? null
      : questions[currentIndex];
  int get correctCount => results.where((e) => e.correct).length;
  LessonSessionState copyWith({
    List<Question>? questions,
    int? currentIndex,
    Object? answer = _unset,
    SubmitAnswerResult? feedback,
    bool clearFeedback = false,
    List<SubmitAnswerResult>? results,
    bool? loading,
    bool? submitting,
    String? error,
    bool clearError = false,
  }) => LessonSessionState(
    lessonId: lessonId,
    questions: questions ?? this.questions,
    currentIndex: currentIndex ?? this.currentIndex,
    answer: identical(answer, _unset) ? this.answer : answer,
    feedback: clearFeedback ? null : feedback ?? this.feedback,
    results: results ?? this.results,
    loading: loading ?? this.loading,
    submitting: submitting ?? this.submitting,
    error: clearError ? null : error ?? this.error,
  );
}

const Object _unset = Object();

class LessonSessionController extends Notifier<LessonSessionState> {
  LessonSessionController(this.lessonId);
  final int lessonId;
  final Stopwatch _stopwatch = Stopwatch();
  final Stopwatch sessionWatch = Stopwatch();
  late LessonRepository _repository;
  @override
  LessonSessionState build() {
    _repository = ref.watch(lessonRepositoryProvider);
    Future.microtask(load);
    return LessonSessionState(lessonId: lessonId);
  }

  Future<void> load() async {
    try {
      final questions = await _repository.questions(lessonId);
      if (!ref.mounted) return;
      state = LessonSessionState(
        lessonId: lessonId,
        questions: questions,
        loading: false,
      );
      _stopwatch
        ..reset()
        ..start();
      sessionWatch
        ..reset()
        ..start();
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void setAnswer(Object? value) {
    if (state.feedback == null && !state.submitting) {
      state = state.copyWith(answer: value, clearError: true);
    }
  }

  Future<bool> submit() async {
    final question = state.current;
    if (question == null ||
        state.answer == null ||
        state.submitting ||
        state.feedback != null) {
      return false;
    }
    state = state.copyWith(submitting: true, clearError: true);
    _stopwatch.stop();
    try {
      final result = await _repository.submit(
        question.id,
        question.questionType,
        state.answer!,
        _stopwatch.elapsedMilliseconds,
      );
      if (!ref.mounted) return false;
      refreshLearningData(ref);
      state = state.copyWith(
        submitting: false,
        feedback: result,
        results: [...state.results, result],
      );
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(submitting: false, error: e.toString());
      _stopwatch.start();
      return false;
    }
  }

  Future<LessonCompletion?> continueNext() async {
    if (state.feedback == null || state.submitting) return null;
    if (state.currentIndex == state.questions.length - 1) {
      state = state.copyWith(submitting: true, clearError: true);
      try {
        final result = await _repository.complete(lessonId);
        if (!ref.mounted) return null;
        sessionWatch.stop();
        refreshLearningData(ref);
        return result;
      } catch (e) {
        if (ref.mounted) {
          state = state.copyWith(submitting: false, error: e.toString());
        }
        rethrow;
      }
    }
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      answer: null,
      clearFeedback: true,
      clearError: true,
    );
    _stopwatch
      ..reset()
      ..start();
    return null;
  }
}
