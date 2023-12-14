import 'package:flutter/material.dart';
import 'package:mp3/models/deck.dart';
import 'package:mp3/models/flashcard.dart';
import 'package:mp3/utils/db_helper.dart';
import 'package:mp3/views/addoreditcard.dart';
import 'package:mp3/views/quizpage.dart';

class CardsList extends StatefulWidget {
  final Deck deck;
  const CardsList(this.deck, {super.key});

  @override
  State<CardsList> createState() => _CardsListState();
}

class _CardsListState extends State<CardsList> {
  late Future<List<Flashcard>> _flashCards;
  bool _showSortByAlphabeticalOrder = false;

  @override
  void initState() {
    super.initState();
    _flashCards = _loadDataFromDB();
  }

  Future<List<Flashcard>> _loadDataFromDB() async {
    final flashCards =
        await DBHelper().query('cards', where: 'decksId = ${widget.deck.id!}');
    return flashCards
        .map((e) => Flashcard(
            id: e['id'] as int,
            question: e['question'] as String,
            answer: e['answer'] as String,
            decksId: e['decksId'] as int))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    int crossAxiCount = 3;
    double minTileWidth = 130;
    double availableWidth = MediaQuery.of(context).size.width;
    crossAxiCount = availableWidth ~/ minTileWidth;
    return FutureBuilder(
        future: _flashCards,
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            var flashCards = snapshot.data as List<Flashcard>;
            if (_showSortByAlphabeticalOrder) {
              flashCards.sort((a, b) =>
                  a.question.toLowerCase().compareTo(b.question.toLowerCase()));
            } else {
              flashCards.sort((a, b) => a.id!.compareTo(b.id!));
            }
            return Scaffold(
                appBar: AppBar(
                  title: FittedBox(
                      fit: BoxFit.fitWidth, child: Text(widget.deck.title)),
                  actions: <Widget>[
                    !_showSortByAlphabeticalOrder
                        ? IconButton(
                            icon: const Icon(
                              Icons.sort_by_alpha,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                flashCards.sort((a, b) => a.question
                                    .toLowerCase()
                                    .compareTo(b.question.toLowerCase()));
                                _showSortByAlphabeticalOrder =
                                    !_showSortByAlphabeticalOrder;
                              });
                            },
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.access_time_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                flashCards
                                    .sort((a, b) => a.id!.compareTo(b.id!));
                                _showSortByAlphabeticalOrder =
                                    !_showSortByAlphabeticalOrder;
                              });
                            },
                          ),
                    IconButton(
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute<Flashcard>(builder: (context) {
                              List<Flashcard> shuffledList = flashCards.toList();
                              shuffledList.shuffle();
                          return QuizPage(
                            flashcards: shuffledList,
                            quizTitle: widget.deck.title,
                          );
                        }));
                      },
                    )
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                    child: const Icon(Icons.add),
                    onPressed: () {
                      _addFlashCard(flashCards, widget.deck.id!);
                    }),
                body: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxiCount),
                    padding: const EdgeInsets.all(4),
                    itemCount: flashCards.length,
                    itemBuilder: (context, index) {
                      return Card(
                          color: Colors.purple[100],
                          child: Container(
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  InkWell(onTap: () {
                                    _editCard(flashCards, flashCards[index]);
                                  }),
                                  Center(
                                      child: Text(flashCards[index].question,
                                          textAlign: TextAlign.center)),
                                ],
                              )));
                    }));
          }
        });
  }

  Future<void> _editCard(List<Flashcard> cards, Flashcard card) async {
    var result = await Navigator.of(context)
        .push(MaterialPageRoute<(Flashcard, String)>(builder: (context) {
      return AddorEditCard(card, true);
    }));

    if (!mounted) return;
    if (result != null) {
      if (result.$2 == "save") {
        setState(() {
          card.question = result.$1.question;
          card.answer = result.$1.answer;
        });
        await card.dbUpdate();
      } else if (result.$2 == "delete") {
        setState(() {
          widget.deck.cardsCount = widget.deck.cardsCount! - 1;
          cards.remove(card);
        });
        await card.dbDelete();
      }
    }
  }

  Future<void> _addFlashCard(List<Flashcard> flashCards, int deckId) async {
    var result = await Navigator.of(context)
        .push(MaterialPageRoute<(Flashcard, String)>(builder: (context) {
      return AddorEditCard(
          Flashcard(question: '', answer: '', decksId: deckId), false);
    }));

    if (!mounted) return;
    if (result != null) {
      await result.$1.dbSave();
      setState(() {
        widget.deck.cardsCount = widget.deck.cardsCount! + 1;
        flashCards.add(result.$1);
      });
    }
  }
}
