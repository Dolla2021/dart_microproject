import 'quiz.dart';
import 'single_choice.dart';
import 'multiple_choice.dart';
import 'answer.dart';

void main() {
  var quiz = Quiz();

  quiz.addQuestion(SingleChoice("What is the capital of France?", [
    Answer("Paris", true),
    Answer("Berlin", false),
    Answer("Rome", false),
    Answer("Madrid", false)
  ]));

  quiz.addQuestion(MultipleChoice("Select the prime numbers", [
    Answer("2", true),
    Answer("3", true),
    Answer("4", false),
    Answer("5", true)
  ]));
  quiz.start();
}
