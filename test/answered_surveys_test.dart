import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/survey.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/utils/case_status_lookups.dart';

void main() {
  group('answered surveys from the server', () {
    Map<String, dynamic> dto() => {
          'dispatchId': 'd1',
          'responseId': 'r1',
          'titleAr': 'كيف كانت إقامتك؟',
          'titleEn': 'How was your stay?',
          'respondedAtUtc': '2026-11-02T09:30:00Z',
          'answers': [
            {
              'questionId': 'q1',
              'questionType': 'Csat',
              'questionTextAr': 'قيّم الغرفة',
              'questionTextEn': 'Rate the room',
              'numericValue': 5,
              'textValue': null,
            },
            {
              'questionId': 'q2',
              'questionType': 'Comment',
              'questionTextAr': 'ملاحظات',
              'questionTextEn': '',
              'numericValue': null,
              'textValue': 'Great stay',
            },
          ],
        };

    test('the survey is answered and keeps every answer', () {
      final survey = ApiService.answeredSurveyFromJson(dto());

      expect(survey.id, 'd1');
      expect(survey.title, 'How was your stay?');
      expect(survey.status, SurveyStatus.answered);
      expect(survey.answeredAt, isNotNull);
      expect(survey.questions, hasLength(2));
      expect(survey.answers[0].rating, 5);
      expect(survey.answers[1].comment, 'Great stay');
    });

    test('falls back to Arabic text when English is empty', () {
      final survey = ApiService.answeredSurveyFromJson(dto());

      expect(survey.questions[1].text, 'ملاحظات');
    });
  });

  group('case status names', () {
    test('a status code is shown as readable words', () {
      expect(CaseStatusLookups.label('InProgress'), 'In progress');
      expect(CaseStatusLookups.label('WaitingOnGuest'), 'Waiting on guest');
    });
  });
}
