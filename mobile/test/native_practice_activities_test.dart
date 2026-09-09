import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammar_agent/features/lesson/domain/lesson_models.dart';
import 'package:grammar_agent/features/lesson/presentation/practice_activities.dart';

void main() {
  test(
    'pilot content has explicit styles and satisfies interaction limits',
    () {
      expect(_pilot, hasLength(10));
      expect(_pilot.where((q) => q.interactionStyle == null), isEmpty);
      expect(
        _pilot.where((q) => q.questionType == QuestionType.singleChoice),
        hasLength(2),
      );
      expect(
        _pilot.where((q) => q.questionType == QuestionType.trueFalse),
        isEmpty,
      );
      expect(
        _pilot.where((q) => q.questionType == QuestionType.sentenceOrder),
        hasLength(1),
      );
      expect(_pilot.map(resolveInteractionStyle).toSet().length, 9);
    },
  );

  testWidgets('sentence spotlight submits the selected stable token id', (
    tester,
  ) async {
    final answers = <Object>[];
    await _pump(tester, _pilot[0], answers.add);
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.byKey(const ValueKey('token-t1')));
    expect(answers.single, {
      'tokenIds': ['t1'],
    });
  });

  testWidgets(
    'grammar paint assigns every role independently of display text',
    (tester) async {
      final answers = <Object>[];
      await _pump(tester, _pilot[2], answers.add);
      for (final pair in [
        ('subject', 't1'),
        ('verb', 't2'),
        ('object', 't3'),
      ]) {
        await tester.tap(find.byKey(ValueKey('labels-${pair.$1}')));
        await tester.tap(find.byKey(ValueKey('token-${pair.$2}')));
        await tester.pump();
      }
      expect(answers.single, {
        'assignments': {'subject': 't1', 'verb': 't2', 'object': 't3'},
      });
    },
  );

  testWidgets('slot puzzle uses tap word then target', (tester) async {
    final answers = <Object>[];
    await _pump(tester, _pilot[3], answers.add);
    for (final pair in [('t1', 'subject'), ('t2', 'verb'), ('t3', 'object')]) {
      await tester.tap(find.byKey(ValueKey('token-${pair.$1}')));
      await tester.tap(find.byKey(ValueKey('slots-${pair.$2}')));
      await tester.pump();
    }
    expect((answers.single as Map)['assignments'], {
      'subject': 't1',
      'verb': 't2',
      'object': 't3',
    });
  });

  testWidgets('sentence surgery selects the problem token and repair action', (
    tester,
  ) async {
    final answers = <Object>[];
    await _pump(tester, _pilot[4], answers.add);
    await tester.tap(find.byKey(const ValueKey('token-t1')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('replacement-after-verb')));
    expect(answers.single, {
      'targetTokenId': 't1',
      'replacementTokenId': 'after-verb',
    });
  });

  testWidgets(
    'sentence transformer replaces one component without a keyboard',
    (tester) async {
      final answers = <Object>[];
      await _pump(tester, _pilot[5], answers.add);
      await tester.tap(find.byKey(const ValueKey('token-t3')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('replacement-r1')));
      expect(find.byType(TextField), findsNothing);
      expect(answers.single, {
        'targetTokenId': 't3',
        'replacementTokenId': 'r1',
      });
    },
  );

  testWidgets('sentence knockout submits the card identity', (tester) async {
    final answers = <Object>[];
    await _pump(tester, _pilot[6], answers.add);
    await tester.tap(find.byKey(const ValueKey('card-c4')));
    expect(answers.single, 'c4');
  });

  testWidgets('pattern complete fills the structural slot', (tester) async {
    final answers = <Object>[];
    await _pump(tester, _pilot[7], answers.add);
    expect(find.text('?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('token-t1')));
    expect(answers.single, {
      'assignments': {'object-3': 't1'},
    });
  });

  testWidgets('context application builds with ids while displaying words', (
    tester,
  ) async {
    final answers = <Object>[];
    await _pump(tester, _pilot[8], answers.add);
    expect(find.byKey(const ValueKey('context-scene')), findsOneWidget);
    for (final id in ['t1', 't2', 't3', 't4']) {
      await tester.tap(find.byKey(ValueKey('token-$id')));
      await tester.pump();
    }
    expect(answers.single, ['t1', 't2', 't3', 't4']);
  });

  testWidgets('all ten pilot renderers avoid keyboard input', (tester) async {
    for (final question in _pilot) {
      await _pump(tester, question, (_) {});
      expect(
        find.byType(TextField),
        findsNothing,
        reason: question.questionCode,
      );
      expect(
        find.byType(EditableText),
        findsNothing,
        reason: question.questionCode,
      );
    }
  });
}

Future<void> _pump(
  WidgetTester tester,
  Question question,
  ValueChanged<Object> onAnswer,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PracticeActivityInput(
            question: question,
            style: resolveInteractionStyle(question),
            enabled: true,
            onChanged: (answer) => onAnswer(answer!),
          ),
        ),
      ),
    ),
  );
}

Question _q(
  int id,
  QuestionType type,
  InteractionStyle style,
  Object options,
) => Question(
  id: id,
  questionCode: 'A1-001-Q${id.toString().padLeft(3, '0')}',
  questionType: type,
  interactionStyle: style,
  questionContent: 'Native grammar activity $id',
  options: options,
  difficulty: 1,
  sortOrder: id,
);

const _tokens = [
  {'id': 't1', 'text': 'I'},
  {'id': 't2', 'text': 'like'},
  {'id': 't3', 'text': 'cats'},
];

final _pilot = <Question>[
  _q(1, QuestionType.tokenSelect, InteractionStyle.sentenceSpotlight, {
    'tokens': _tokens,
  }),
  _q(2, QuestionType.tokenSelect, InteractionStyle.sentenceSpotlight, {
    'tokens': _tokens,
  }),
  _q(3, QuestionType.tokenLabel, InteractionStyle.grammarPaint, {
    'tokens': _tokens,
    'labels': [
      {'id': 'subject', 'text': '主语'},
      {'id': 'verb', 'text': '动词'},
      {'id': 'object', 'text': '宾语'},
    ],
  }),
  _q(4, QuestionType.slotAssignment, InteractionStyle.slotPuzzle, {
    'tokens': _tokens,
    'slots': [
      {'id': 'subject', 'text': 'Subject'},
      {'id': 'verb', 'text': 'Verb'},
      {'id': 'object', 'text': 'Object'},
    ],
  }),
  _q(5, QuestionType.transform, InteractionStyle.sentenceSurgery, {
    'tokens': _tokens,
    'replacements': [
      {'id': 'after-verb', 'text': '移到动词后'},
    ],
  }),
  _q(6, QuestionType.transform, InteractionStyle.sentenceTransform, {
    'tokens': _tokens,
    'replacements': [
      {'id': 'r1', 'text': 'music'},
    ],
  }),
  _q(7, QuestionType.singleChoice, InteractionStyle.sentenceKnockout, {
    'cards': [
      {'id': 'c1', 'text': 'I like cats.'},
      {'id': 'c4', 'text': 'Cats I like.'},
    ],
  }),
  _q(8, QuestionType.slotAssignment, InteractionStyle.patternComplete, {
    'patternRows': [
      ['I', 'like', 'cats'],
      ['They', 'read', null],
    ],
    'tokens': [
      {'id': 't1', 'text': 'books'},
    ],
    'slots': [
      {'id': 'object-3', 'text': 'Object'},
    ],
  }),
  _q(9, QuestionType.sentenceOrder, InteractionStyle.contextApplication, {
    'scene': {
      'speaker': 'Grammar Cat',
      'line': 'I like music.',
      'targetMeaning': '我喜欢猫。',
    },
    'tokens': [
      ..._tokens,
      {'id': 't4', 'text': '.'},
    ],
  }),
  _q(10, QuestionType.singleChoice, InteractionStyle.quickChoice, [
    {'id': 'A', 'text': 'Read books.'},
    {'id': 'B', 'text': 'We read books.'},
  ]),
];
