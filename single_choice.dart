import 'question.dart';
import 'answer.dart';

class SingleChoice extends Question {
  SingleChoice(String title, List<Answer> answers) : super(title, answers);

  @override
  bool checkAnswer(List<int> selectedAnswers) {
    if (selectedAnswers.length != 1) return false;
    return answers[selectedAnswers[0]].isCorrect;
  }

  @override
  void display(int questionNumber, {int? remainingTime}) {
    print('\n┌${'─' * 54}┐');
    print('│ Question $questionNumber: $title'.padRight(55) + '│');
    if (remainingTime != null) {
      print('│ Time Remaining: ${remainingTime.toString().padLeft(2, '0')}s'
              .padRight(55) +
          '│');
    }
    print('├${'─' * 54}┤');
    for (var i = 0; i < answers.length; i++) {
      print(
          '│ ${String.fromCharCode(65 + i)}. ${answers[i].text}'.padRight(55) +
              '│');
    }
    print('└${'─' * 54}┘');
    print('|Select one answer|');
  }
}
