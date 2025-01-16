class Flashcard {
  String id;
  String question;
  String answer;

  Flashcard({required this.id, required this.question, required this.answer});

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
    };
  }

  static Flashcard fromMap(String id, Map<String, dynamic> data) {
    return Flashcard(id: id, question: data['question'], answer: data['answer']);
  }
}
