import 'dart:io';
import 'dart:async';

import 'question.dart';
import 'participant.dart';

class Quiz {
  List<Question> questions = [];
  List<Participant> participants = [];
  int quizDuration = 60;

  void addQuestion(Question question) {
    questions.add(question);
  }

  void addParticipant(Participant participant) {
    participants.add(participant);
  }

  Future<void> start() async {
    print('Please enter your first name:');
    String firstName = stdin.readLineSync() ?? '';
    print('Please enter your last name:');
    String lastName = stdin.readLineSync() ?? '';

    var participant = Participant(firstName, lastName);
    addParticipant(participant);

    print('\n${participant.firstName}, get ready for your quiz!');
    print('You have $quizDuration seconds to complete the quiz.');
    print('Press Enter to start the quiz.');
    stdin.readLineSync();

    questions.shuffle(); // Shuffle the order of questions
    var startTime = DateTime.now();
    var endTime = startTime.add(Duration(seconds: quizDuration));
    Timer? countdownTimer;
    List<List<int>> participantAnswers = [];

    for (var i = 0; i < questions.length; i++) {
      var question = questions[i];
      question.answers.shuffle(); // Shuffle answer options
      var remainingTime = endTime.difference(DateTime.now()).inSeconds;
      question.display(i + 1, remainingTime: remainingTime);

      // Start countdown timer for the quiz
      countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        remainingTime = endTime.difference(DateTime.now()).inSeconds;
        stdout.write(
            '\rTime remaining: ${remainingTime.toString().padLeft(2, '0')} seconds');
        if (remainingTime <= 0) {
          timer.cancel();
        }
      });

      var questionStartTime = DateTime.now();
      List<int> selectedAnswers = await _askQuestion(question);
      var answerTime = DateTime.now().difference(questionStartTime);
      participantAnswers.add(selectedAnswers);
      participant.answerQuestion(question, selectedAnswers, answerTime);

      countdownTimer.cancel();

      if (selectedAnswers.isEmpty) {
        print('\nTime\'s up for this question!');
      }

      if (DateTime.now().isAfter(endTime)) {
        print('\nTime\'s up! The quiz has ended.');
        break;
      }
    }

    countdownTimer?.cancel();
    var remainingTime = endTime.difference(DateTime.now()).inSeconds;
    displayResults(participant, remainingTime);
    saveResultsToFile(
        participant, questions, participantAnswers, remainingTime);
  }

  Future<List<int>> _askQuestion(Question question) async {
    print('\nEnter your answer(s):');
    var input = stdin.readLineSync() ?? '';
    var selectedAnswers = input
        .trim()
        .toUpperCase()
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => e.codeUnitAt(0) - 65)
        .where((e) => e >= 0 && e < question.answers.length)
        .toList();

    return selectedAnswers;
  }

  void displayResults(Participant participant, int remainingTime) {
    print('\n┌${'─' * 50}┐');
    print('│ QUIZ RESULTS                                    │');
    print('├${'─' * 50}┤');
    print(
        '│ ${participant.firstName} ${participant.lastName}: ${participant.score}/${questions.length}'
                .padRight(50) +
            '│');
    print(
        '│ Time Remaining: ${remainingTime.toString().padLeft(2, '0')} seconds'
                .padRight(50) +
            '│');
    for (var i = 0; i < questions.length; i++) {
      var question = questions[i];
      var isCorrect = participant.correctAnswers[i] ? "Correct" : "Incorrect";
      print('│ Question ${i + 1}: $isCorrect'.padRight(50) + '│');
    }
    print('└${'─' * 50}┘');
  }

  void saveResultsToFile(Participant participant, List<Question> questions,
      List<List<int>> participantAnswers, int remainingTime) {
    var file = File('quiz_results.txt');
    var sink = file.openWrite(mode: FileMode.append);
    sink.writeln('________________________________________________________');
    sink.writeln('Quiz Results');
    sink.writeln('Date: ${DateTime.now()}');
    sink.writeln(
        'Participant: ${participant.firstName} ${participant.lastName}');
    sink.writeln('Score: ${participant.score}/${questions.length}');
    sink.writeln(
        'Time Remaining: ${remainingTime.toString().padLeft(2, '0')} seconds');

    sink.writeln('Answers Given:');
    for (var i = 0; i < questions.length; i++) {
      var question = questions[i];
      var givenAnswers = participantAnswers[i]
          .map((index) => String.fromCharCode(65 + index))
          .join(', ');
      var correctAnswers = question.answers
          .asMap()
          .entries
          .where((entry) => entry.value.isCorrect)
          .map((entry) => String.fromCharCode(65 + entry.key))
          .join(', ');
      var timeTaken = participant.answerTimes[i].inSeconds;
      var isCorrect = participant.correctAnswers[i] ? "Correct" : "Incorrect";

      sink.writeln('  Question ${i + 1}: ${question.title}');
      sink.writeln('    Given: $givenAnswers');
      sink.writeln('    Correct: $correctAnswers');
      sink.writeln('    Time Taken: ${timeTaken}s');
      sink.writeln('    Result: $isCorrect');
      sink.writeln('________________________________________________________');
    }
    sink.writeln('');

    sink.close();
    print('\nYour Results have been saved');
  }
}
