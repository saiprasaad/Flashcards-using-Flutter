import 'package:flutter/material.dart';
import 'package:mp3/models/flashcard.dart';

class AddorEditCard extends StatefulWidget {
  final Flashcard flashcard;
  final bool ifEdit;
  const AddorEditCard(this.flashcard, this.ifEdit, {super.key});

  @override
  State<AddorEditCard> createState() => _AddorEditCardState();
}

class _AddorEditCardState extends State<AddorEditCard> {
  final _questioncontroller = TextEditingController();
  final _answercontroller = TextEditingController();
  late Flashcard editedCard;
  bool _validateQuestion = false;
  bool _validateAnswer = false;

  @override
  void initState() {
    super.initState();
    editedCard = Flashcard.from(widget.flashcard);
    _questioncontroller.text = widget.flashcard.question;
    _answercontroller.text = widget.flashcard.answer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Edit Card')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: TextFormField(
                  controller: _questioncontroller,
                  decoration: InputDecoration(
                      labelText: 'Question',
                      errorText:
                          _validateQuestion ? "Question Can't Be Empty" : null),
                  onChanged: (value) => editedCard.question = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: TextFormField(
                  controller: _answercontroller,
                  decoration: InputDecoration(
                      labelText: 'Answer',
                      errorText:
                          _validateAnswer ? "Answer Can't Be Empty" : null),
                  onChanged: (value) => editedCard.answer = value,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    if (editedCard.question.isEmpty ||
                        editedCard.answer.isEmpty) {
                      setState(() {
                        _validateQuestion = _questioncontroller.text.isEmpty;
                        _validateAnswer = _answercontroller.text.isEmpty;
                      });
                    } else {
                      Navigator.of(context).pop((editedCard, 'save'));
                    }
                  },
                ),
                if (widget.ifEdit)
                  TextButton(
                    child: const Text('Delete'),
                    onPressed: () {
                      Navigator.of(context).pop((editedCard, 'delete'));
                    },
                  ),
              ])
            ],
          ),
        ));
  }
}
