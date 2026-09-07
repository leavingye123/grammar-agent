import 'course_models.dart';

/// Presentation-only groupings. These are neither prerequisites nor unlock rules.
enum GrammarDomain {
  foundations('foundations', '基础语法', 'Grammar Foundations'),
  parts('parts', '词类森林', 'Parts of Speech'),
  tenses('tenses', '时态世界', 'Tenses'),
  voice('voice', '被动语态', 'Voice'),
  clauses('clauses', '从句之岛', 'Clauses'),
  structure('structure', '句子结构', 'Sentence Structure'),
  advanced('advanced', '高级语法', 'Advanced Grammar'),
  other('other', '其他语法', 'More to Explore');

  const GrammarDomain(this.id, this.title, this.subtitle);
  final String id, title, subtitle;
  static GrammarDomain? fromId(String id) =>
      values.where((value) => value.id == id).firstOrNull;
}

// Explicit editorial mapping, keyed by language + course code. Unknown content
// remains reachable under Other, rather than being classified by title guessing.
const _domainsByCode = <String, GrammarDomain>{
  'en:EN_A1_BE_001': GrammarDomain.foundations,
  'en:BE': GrammarDomain.foundations,
  'en:EN_A1_SIMPLE_PRESENT_001': GrammarDomain.tenses,
  'en:EN_A1_PRESENT_CONTINUOUS_001': GrammarDomain.tenses,
};

GrammarDomain domainFor(String language, GrammarPointSummary point) =>
    _domainsByCode['$language:${point.code}'] ?? GrammarDomain.other;

List<GrammarPointSummary> pointsInLevel(LevelModel level) =>
    level.chapters.expand((chapter) => chapter.grammarPoints).toList();

List<GrammarPointSummary> pointsInDomain(
  LearningPath path,
  LevelModel level,
  GrammarDomain domain,
) =>
    pointsInLevel(level)
        .where((p) => domainFor(path.language.code, p) == domain)
        .toList();

GrammarPointSummary? findPoint(LearningPath? path, int id) =>
    path?.levels.expand(pointsInLevel).where((p) => p.id == id).firstOrNull;

enum GrowthStage {
  seed('未探索'),
  learning('正在学习'),
  practicing('继续巩固'),
  mastered('熟练掌握'),
  dueForReview('待复习');

  const GrowthStage(this.label);
  final String label;
}

/// A display hint only: a completed lesson does not imply mastery.
GrowthStage growthFor(GrammarPointSummary point) {
  if (point.status == 'COMPLETED' && (point.masteryScore ?? 0) >= 90) {
    return GrowthStage.mastered;
  }
  if (point.status == 'COMPLETED') return GrowthStage.practicing;
  if (point.status == 'IN_PROGRESS' || (point.masteryScore ?? 0) > 0) {
    return GrowthStage.learning;
  }
  return GrowthStage.seed;
}

class TreeProgress {
  TreeProgress(List<GrammarPointSummary> points)
    : total = points.length,
      completed = points.where((p) => p.status == 'COMPLETED').length,
      lessonTotal = points.fold(
        0,
        (n, p) => n + (p.totalLessons ?? p.lessons.length),
      ),
      lessonCompleted = points.fold(0, (n, p) => n + (p.completedLessons ?? 0));
  final int total, completed, lessonTotal, lessonCompleted;
  double get fraction => total == 0 ? 0 : completed / total;
}
