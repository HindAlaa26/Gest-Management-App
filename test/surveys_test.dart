import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/survey.dart';
import 'package:gest_managment_app/core/network/api_service.dart';

Map<String, dynamic> question(
  String id,
  String type,
  int order, {
  bool required = true,
}) {
  return {
    'id': id,
    'questionType': type,
    'textAr': 'سؤال $id',
    'textEn': 'Question $id',
    'sortOrder': order,
    'isRequired': required,
    'minRating': null,
    'maxRating': null,
  };
}

Map<String, dynamic> dto({bool answered = false}) {
  return {
    'dispatchId': 'dispatch-1',
    'surveyId': 'survey-1',
    'titleAr': 'كيف كانت إقامتك؟',
    'titleEn': 'Test - How was your stay?',
    'descriptionAr': null,
    'descriptionEn': 'After your check-out',
    'status': 'Sent',
    'isAlreadyAnswered': answered,
    'questions': [
      question('q3', 'Comment', 3, required: false),
      question('q1', 'Csat', 1),
      question('q2', 'Nps', 2),
    ],
  };
}

void main() {
  final received = DateTime(2026, 11, 1, 10);

  group('surveys from the server', () {
    test('title, description and questions are read and ordered', () {
      final survey = ApiService.surveyFromJson(dto(), receivedAt: received);

      expect(survey.id, 'dispatch-1');
      expect(survey.title, 'Test - How was your stay?');
      expect(survey.contextLabel, 'After your check-out');
      expect(survey.questions.map((q) => q.id), ['q1', 'q2', 'q3']);
      expect(survey.questions.map((q) => q.type), [
        SurveyQuestionType.csat,
        SurveyQuestionType.nps,
        SurveyQuestionType.comment,
      ]);
      expect(survey.questions.first.text, 'Question q1');
      expect(survey.status, SurveyStatus.waiting);
    });

    test('required and optional questions follow the server', () {
      final survey = ApiService.surveyFromJson(dto(), receivedAt: received);

      expect(survey.questions[0].isRequired, isTrue);
      expect(survey.questions[2].isRequired, isFalse);
    });

    test('an answered survey is marked answered', () {
      final survey = ApiService.surveyFromJson(
        dto(answered: true),
        receivedAt: received,
      );

      expect(survey.status, SurveyStatus.answered);
    });

    test('falls back to Arabic text and an empty description', () {
      final json = dto()
        ..['titleEn'] = ''
        ..['descriptionEn'] = null;

      final survey = ApiService.surveyFromJson(json, receivedAt: received);

      expect(survey.title, 'كيف كانت إقامتك؟');
      expect(survey.contextLabel, isEmpty);
    });

    test('only comment questions skip the rating', () {
      final survey = ApiService.surveyFromJson(dto(), receivedAt: received);

      expect(survey.questions[0].needsRating, isTrue);
      expect(survey.questions[1].needsRating, isTrue);
      expect(survey.questions[2].needsRating, isFalse);
    });

    test('copyAnswered keeps the answers and marks the survey answered', () {
      final survey = ApiService.surveyFromJson(dto(), receivedAt: received)
          .copyAnswered(
        DateTime(2026, 11, 1, 11),
        const [SurveyAnswer(questionId: 'q1', rating: 5)],
      );

      expect(survey.status, SurveyStatus.answered);
      expect(survey.answers, hasLength(1));
      expect(survey.answeredAt, isNotNull);
    });
  });
}
