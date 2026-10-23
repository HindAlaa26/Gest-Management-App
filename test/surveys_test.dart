import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/data/demo_data.dart';
import 'package:gest_managment_app/core/models/survey.dart';
import 'package:gest_managment_app/core/network/api_service.dart';

void main() {
  setUp(() {
    ApiService.mySurveysByRoom
      ..clear()
      ..addAll({
        for (final entry in demoSurveysByRoom.entries)
          entry.key: List<Survey>.from(entry.value),
      });
    ApiService.failNextSurveySubmit = false;
  });

  group('surveys', () {
    test('room 305 has two waiting surveys and one answered', () async {
      Session.currentStay = demoStays.first;

      final list = await ApiService().getSurveys();

      expect(list.where((s) => s.status == SurveyStatus.waiting), hasLength(2));
      expect(list.where((s) => s.status == SurveyStatus.answered), hasLength(1));
      for (var i = 1; i < list.length; i++) {
        expect(list[i].receivedAt.isAfter(list[i - 1].receivedAt), isFalse);
      }
    });

    test('a room without surveys gets an empty list', () async {
      Session.currentStay = demoStays[1];

      expect(await ApiService().getSurveys(), isEmpty);
    });

    test('submitting marks the survey answered', () async {
      Session.currentStay = demoStays.first;

      await ApiService().submitSurvey('survey-1', const [
        SurveyAnswer(questionId: 'q1', rating: 5),
        SurveyAnswer(questionId: 'q2', rating: 9),
        SurveyAnswer(questionId: 'q3', comment: 'Lovely stay'),
      ]);

      final list = await ApiService().getSurveys();
      final survey = list.firstWhere((s) => s.id == 'survey-1');
      expect(survey.status, SurveyStatus.answered);
      expect(survey.answeredAt, isNotNull);
      expect(survey.answers, hasLength(3));
      expect(list.where((s) => s.status == SurveyStatus.waiting), hasLength(1));
    });

    test('answering twice or an unknown survey fails', () async {
      Session.currentStay = demoStays.first;

      await ApiService().submitSurvey('survey-2', const []);

      expect(
        () => ApiService().submitSurvey('survey-2', const []),
        throwsA(isA<SurveyAlreadyAnsweredException>()),
      );
      expect(
        () => ApiService().submitSurvey('nope', const []),
        throwsA(isA<SurveyNotFoundException>()),
      );
    });

    test('a failed submit can be retried', () async {
      Session.currentStay = demoStays.first;
      ApiService.failNextSurveySubmit = true;

      await expectLater(
        ApiService().submitSurvey('survey-1', const []),
        throwsException,
      );
      await ApiService().submitSurvey('survey-1', const []);

      final list = await ApiService().getSurveys();
      expect(
        list.firstWhere((s) => s.id == 'survey-1').status,
        SurveyStatus.answered,
      );
    });
  });
}
