enum SurveyQuestionType { csat, nps, comment }

enum SurveyStatus { waiting, answered }

class SurveyQuestion {
  const SurveyQuestion({
    required this.id,
    required this.type,
    required this.text,
    this.isRequired = true,
  });

  final String id;
  final SurveyQuestionType type;
  final String text;

  final bool isRequired;

  bool get needsRating => type != SurveyQuestionType.comment;
}

class Survey {
  const Survey({
    required this.id,
    required this.title,
    required this.contextLabel,
    required this.questions,
    required this.receivedAt,
    this.status = SurveyStatus.waiting,
    this.answeredAt,
    this.answers = const [],
  });

  final String id;
  final String title;

  final String contextLabel;
  final List<SurveyQuestion> questions;
  final DateTime receivedAt;
  final SurveyStatus status;
  final DateTime? answeredAt;
  final List<SurveyAnswer> answers;

  Survey copyAnswered(DateTime at, [List<SurveyAnswer> answers = const []]) {
    return Survey(
      id: id,
      title: title,
      contextLabel: contextLabel,
      questions: questions,
      receivedAt: receivedAt,
      status: SurveyStatus.answered,
      answeredAt: at,
      answers: answers,
    );
  }
}

class SurveyAnswer {
  const SurveyAnswer({required this.questionId, this.rating, this.comment});

  final String questionId;

  final int? rating;
  final String? comment;
}

class SurveyNotFoundException implements Exception {}

class SurveyAlreadyAnsweredException implements Exception {}
