import 'package:mp3/utils/db_helper.dart';

class Flashcard {
  int? id;
  String question;
  String answer;
  bool? visited;
  bool? peeked;

  int? decksId;

  Flashcard(
      {this.id, required this.question, required this.answer, this.decksId});

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
        question: json['question'] as String, answer: json['answer'] as String);
  }

  Future<void> dbSave() async {
    id = await DBHelper().insert('cards', {
      'question': question,
      'answer': answer,
      'decksId': decksId,
    });
  }

  Future<void> dbUpdate() async {
    await DBHelper()
        .update('cards', {'id': id, 'question': question, 'answer': answer});
  }

  Future<void> dbDelete() async {
    await DBHelper().delete('cards', id!);
  }

  Flashcard.from(Flashcard other)
      : id = other.id,
        question = other.question,
        answer = other.answer,
        decksId = other.decksId;
}
