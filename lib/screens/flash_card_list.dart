import 'package:flash_card/screens/add_edit_flash_card.dart';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import 'dart:math' show pi;

class FlashcardListScreen extends StatefulWidget {
  const FlashcardListScreen({Key? key}) : super(key: key);

  @override
  _FlashcardListScreenState createState() => _FlashcardListScreenState();
}

class _FlashcardListScreenState extends State<FlashcardListScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showAnswer = false;
  AnimationController? _animationController;
  Animation<double>? _flipAnimation;
  List<Flashcard> _flashcards = []; // Local list to store flashcards

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ),
    );

    _flipAnimation?.addListener(() {
      setState(() {});
    });
  }

  void _toggleCard() {
    setState(() {
      _showAnswer = !_showAnswer;
      if (_showAnswer) {
        _animationController?.forward();
      } else {
        _animationController?.reverse();
      }
    });
  }

  void _nextCard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _flashcards.length;
      _showAnswer = false;
    });
    _animationController?.reset();
  }

  void _previousCard() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _flashcards.length) % _flashcards.length;
      _showAnswer = false;
    });
    _animationController?.reset();
  }

  void _addFlashcard(Flashcard flashcard) {
    setState(() {
      _flashcards.add(flashcard);
    });
  }

  void _editFlashcard(Flashcard updatedFlashcard) {
    setState(() {
      final index = _flashcards.indexWhere((fc) => fc.id == updatedFlashcard.id);
      if (index != -1) {
        _flashcards[index] = updatedFlashcard;
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Flashcards', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade100, Colors.indigo.shade100],
          ),
        ),
        child: _flashcards.isEmpty
            ? const Center(
          child: Text(
            'No flashcards yet!\nTap + to add one.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        )
            : Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildFlippableCard(_flashcards[_currentIndex]),
                ),
              ),
            ),
            _buildControlBar(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
        onPressed: () async {
          final newFlashcard = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditFlashcardScreen(),
            ),
          );
          if (newFlashcard != null && newFlashcard is Flashcard) {
            _addFlashcard(newFlashcard);
          }
        },
      ),
    );
  }

  Widget _buildFlippableCard(Flashcard flashcard) {
    final angle = (_flipAnimation?.value ?? 0);

    return GestureDetector(
      onTap: _toggleCard,
      onLongPress: () => _showEditDeleteOptions(context, flashcard),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle),
        child: angle >= pi / 2
            ? Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..rotateY(pi),
          child: _buildCardSide(flashcard, true),
        )
            : _buildCardSide(flashcard, false),
      ),
    );
  }

  Widget _buildCardSide(Flashcard flashcard, bool isAnswer) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.width * 1.2,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isAnswer ? 'Answer' : 'Question',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            Text(
              isAnswer ? flashcard.answer : flashcard.question,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: _previousCard,
            color: Colors.blue,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${_currentIndex + 1} / ${_flashcards.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: _nextCard,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }


  void _deleteFlashcard(String flashcardId) {
    setState(() {
      final indexToDelete = _flashcards.indexWhere((fc) => fc.id == flashcardId);
      if (indexToDelete != -1) {
        _flashcards.removeAt(indexToDelete);
        if (_flashcards.isEmpty) {
          _currentIndex = 0; // Reset to the first card when list is empty
        } else if (_currentIndex >= _flashcards.length) {
          _currentIndex = _flashcards.length - 1; // Adjust index if it goes out of range
        }
        _showAnswer = false; // Reset the flip state
        _animationController?.reset(); // Reset the animation
      }
    });
  }


  void _showEditDeleteOptions(BuildContext context, Flashcard flashcard) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () async {
              Navigator.pop(context);
              final updatedFlashcard = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditFlashcardScreen(flashcard: flashcard),
                ),
              );
              if (updatedFlashcard != null && updatedFlashcard is Flashcard) {
                _editFlashcard(updatedFlashcard);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () {
              Navigator.pop(context);
              _deleteFlashcard(flashcard.id);
            },
          ),
        ],
      ),
    );
  }
}
