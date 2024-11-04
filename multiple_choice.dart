import 'question.dart';
import 'answer.dart';

class MultipleChoice extends Question {
  MultipleChoice(String title, List<Answer> answers) : super(title, answers);

  @override
  bool checkAnswer(List<int> selectedAnswers) {
    for (var i = 0; i < answers.length; i++) {
      if (answers[i].isCorrect != selectedAnswers.contains(i)) {
        return false;
      }
    }
    return true;
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
    print('|Select multiple answers by separating with commas like A,C |');
  }
}
