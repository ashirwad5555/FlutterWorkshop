import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class FlashcardCard extends StatefulWidget {
  final Flashcard flashcard;
  final bool showAnswer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  FlashcardCard({
    required this.flashcard,
    required this.showAnswer,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  _FlashcardCardState createState() => _FlashcardCardState();
}

class _FlashcardCardState extends State<FlashcardCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _showEditDeleteOptions(context);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: Container(
          height: MediaQuery.of(context).size.height / 2.5,
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              widget.showAnswer ? widget.flashcard.answer : widget.flashcard.question,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDeleteOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit or Delete'),
        content: Text('Choose an option:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onEdit();
            },
            child: Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
