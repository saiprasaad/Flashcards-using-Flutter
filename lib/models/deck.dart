import 'package:mp3/models/flashcard.dart';
import 'package:mp3/utils/db_helper.dart';

class Deck {
  int? id;
  String title;
  List<Flashcard>? flashCards;
  int? cardsCount;

  Deck({this.id, required this.title, this.flashCards, this.cardsCount});

  Future<void> dbSave() async {
    id = await DBHelper().insert('decks', {
      'title': title,
    });
  }

  Future<void> dbUpdate() async {
    await DBHelper().update('decks', {
      'id': id,
      'title': title,
    });
  }

  Future<void> dbDelete() async {
    await DBHelper().delete('decks', id!);
  }

  factory Deck.fromJson(Map<String, dynamic> json) {
    final flashCardsJson = json['flashcards'] as List<dynamic>;
    return Deck(
        title: json['title'] as String,
        flashCards: flashCardsJson
            .map((flashCard) => Flashcard.fromJson(flashCard))
            .toList());
  }

  Deck.from(Deck other)
      : id = other.id,
        title = other.title;

  @override
  String toString() {
    return "$id $title";
  }
}
