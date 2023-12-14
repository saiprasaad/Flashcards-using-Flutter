import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:mp3/models/deck.dart';
import 'package:mp3/models/flashcard.dart';
import 'package:mp3/utils/db_helper.dart';
import 'package:mp3/views/addoreditdeck.dart';
import 'package:mp3/views/cardslist.dart';

class DeckList extends StatefulWidget {
  const DeckList({super.key});

  @override
  State<DeckList> createState() => _DeckListState();
}

class _DeckListState extends State<DeckList> {
  late Future<List<Deck>> _data;

  @override
  void initState() {
    super.initState();
    _data = _loadDataFromDB();
  }

  List<Deck> deckListFromJson(String str) {
    final jsonData = json.decode(str);
    return List<Deck>.from(jsonData.map((x) => Deck.fromJson(x)));
  }

  Future<List<Deck>> _loadDataFromJSONToDB() async {
    final data = await rootBundle.loadString('assets/flashcards.json');
    List<Deck> decksFromJson = deckListFromJson(data);
    if (decksFromJson.isNotEmpty) {
      for (Deck deck in decksFromJson) {
        await deck.dbSave();
        for (Flashcard flashcard in deck.flashCards!) {
          flashcard.decksId = deck.id;
          await flashcard.dbSave();
        }
      }
    }
    return decksFromJson;
  }

  Future<List<Deck>> _loadDataFromDB() async {
    final decks = await DBHelper().query('decks');
    final cardsCount = await DBHelper().getCountOfCards();
    return decks
        .map((e) => Deck(
            id: e['id'] as int,
            title: e['title'] as String,
            cardsCount: (cardsCount[e['id']] ?? 0)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    int crossAxiCount = 2;
    double minTileWidth = 190;
    double availableWidth = MediaQuery.of(context).size.width;
    crossAxiCount = availableWidth ~/ minTileWidth;
    return FutureBuilder<List<Deck>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            final decks = snapshot.data as List<Deck>;
            return Scaffold(
              appBar: AppBar(
                title: const Text("Flashcard Decks"),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.download,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      _loadDataFromJSONToDB().then((value) => {
                            setState(() {
                              _data = _loadDataFromDB();
                            })
                          });
                    },
                  )
                ],
              ),
              body: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxiCount),
                  padding: const EdgeInsets.all(4),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Card(
                        color: Colors.purple[100],
                        child: Container(
                            alignment: Alignment.center,
                            child: Stack(
                              children: [
                                InkWell(onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<Deck>(builder: (context) {
                                      return CardsList(decks[index]);
                                    }),
                                  ).then((_) => setState(() => {}));
                                }),
                                Center(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                      Text(decks[index].title,
                                          textAlign: TextAlign.center),
                                      if (decks[index].cardsCount != null)
                                        Text(
                                            "(${decks[index].cardsCount} cards)",
                                            textAlign: TextAlign.center)
                                      else
                                        const Text("(0 cards)",
                                            textAlign: TextAlign.center)
                                    ])),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _editDeck(decks, decks[index]);
                                    },
                                  ),
                                ),
                              ],
                            )));
                  }),
              floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () {
                  _addDeck(decks);
                },
              ),
            );
          }
        });
  }

  Future<void> _editDeck(List<Deck> decks, Deck deck) async {
    var result = await Navigator.of(context)
        .push(MaterialPageRoute<(Deck, String)>(builder: (context) {
      return AddorEditDeck(deck, true);
    }));

    if (!mounted) return;
    if (result != null) {
      if (result.$2 == "save") {
        setState(() {
          deck.title = result.$1.title;
        });
        await deck.dbUpdate();
      } else if (result.$2 == "delete") {
        await deck.dbDelete();
        await DBHelper().deleteFlashCardByDeckId('cards', deck.id!);
        setState(() {
          decks.remove(deck);
        });
      }
    }
  }

  Future<void> _addDeck(List<Deck> decks) async {
    var result = await Navigator.of(context)
        .push(MaterialPageRoute<(Deck, String)>(builder: (context) {
      return AddorEditDeck(Deck(title: '', cardsCount: 0), false);
    }));

    if (!mounted) return;
    if (result != null) {
      setState(() {
        result.$1.cardsCount = 0;
        decks.add(result.$1);
      });
      await result.$1.dbSave();
    }
  }
}
