import 'package:flutter/material.dart';
import 'package:mp3/models/deck.dart';

class AddorEditDeck extends StatefulWidget {
  final Deck deck;
  final bool ifEdit;
  const AddorEditDeck(this.deck, this.ifEdit, {super.key});

  @override
  State<AddorEditDeck> createState() => _AddorEditDeckState();
}

class _AddorEditDeckState extends State<AddorEditDeck> {
  late Deck editedDeck;
  final _titlecontroller = TextEditingController();
  bool _validateTitle = false;

  @override
  void initState() {
    super.initState();
    editedDeck = Deck.from(widget.deck);
    _titlecontroller.text = editedDeck.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Edit Deck')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: TextFormField(
                  controller: _titlecontroller,
                  decoration: InputDecoration(
                      labelText: 'Title',
                      errorText:
                          _validateTitle ? "Title Can't Be Empty" : null),
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Can\'t be empty';
                    }
                    return null;
                  },
                  onChanged: (value) => editedDeck.title = value,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                TextButton(
                    child: const Text('Save'),
                    onPressed: () {
                      if (editedDeck.title.isEmpty) {
                        setState(() {
                          _validateTitle = _titlecontroller.text.isEmpty;
                        });
                      } else {
                        Navigator.of(context).pop((editedDeck, 'save'));
                      }
                    }),
                if (widget.ifEdit)
                  TextButton(
                    child: const Text('Delete'),
                    onPressed: () {
                      Navigator.of(context).pop((editedDeck, 'delete'));
                    },
                  ),
              ])
            ],
          ),
        ));
  }
}
