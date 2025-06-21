// Lokasi: lib/presentation/screens/education/quiz_screen.dart
// --- KODE DENGAN PERBAIKAN UNTUK MENAMPILKAN KOTAK EDUKASI ---

import 'package:cemungut_app/app/models/quiz_question.dart';
import 'package:cemungut_app/app/services/firestore_service.dart';
import 'package:cemungut_app/presentation/screens/education/quiz_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<QuizQuestion>> _questionsFuture;
  List<QuizQuestion> _questions = [];

  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = FirestoreService.getQuizQuestions(limit: 10);
  }

  void _answerQuestion(int selectedIndex, int correctIndex) {
    setState(() {
      _isAnswered = true;
      _selectedAnswerIndex = selectedIndex;
      if (selectedIndex == correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedAnswerIndex = null;
      });
    } else {
      Get.off(
        () =>
            QuizResultScreen(score: _score, totalQuestions: _questions.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/CemEdu.png', height: 32),
        centerTitle: true,
      ),
      body: FutureBuilder<List<QuizQuestion>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text('Gagal memuat soal kuis.'));
          }
          if (snapshot.data!.length < 10) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Soal kuis tidak cukup (kurang dari 10). Harap hubungi admin.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          _questions = snapshot.data!;
          final currentQuestion = _questions[_currentQuestionIndex];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ... (Indikator Progres dan Teks Pertanyaan tetap sama)
                Text(
                  "Soal ${_currentQuestionIndex + 1} dari ${_questions.length}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  currentQuestion.questionText,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // ... (Pilihan Jawaban tetap sama)
                ...List.generate(currentQuestion.options.length, (index) {
                  final isCorrect = index == currentQuestion.correctAnswerIndex;
                  final isSelected = index == _selectedAnswerIndex;
                  Color borderColor = Colors.grey.shade300;
                  Color tileColor = Colors.transparent;

                  if (_isAnswered) {
                    if (isSelected) {
                      tileColor =
                          isCorrect ? Colors.green.shade50 : Colors.red.shade50;
                      borderColor = isCorrect ? Colors.green : Colors.red;
                    } else if (isCorrect) {
                      tileColor = Colors.green.shade50;
                      borderColor = Colors.green;
                    }
                  }
                  return Card(
                    elevation: 0,
                    color: tileColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: borderColor, width: 1.5),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(currentQuestion.options[index]),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap:
                          _isAnswered
                              ? null
                              : () => _answerQuestion(
                                index,
                                currentQuestion.correctAnswerIndex,
                              ),
                    ),
                  );
                }),

                const Spacer(),

                // === PERBAIKAN DI SINI: BAGIAN EDUKASI & TOMBOL ===
                if (_isAnswered)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. KOTAK PENJELASAN EDUKASI (YANG SEBELUMNYA HILANG)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedAnswerIndex ==
                                      currentQuestion.correctAnswerIndex
                                  ? "Benar!"
                                  : "Kurang Tepat!",
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color:
                                    _selectedAnswerIndex ==
                                            currentQuestion.correctAnswerIndex
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 16),
                            Text(currentQuestion.explanation),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2. TOMBOL LANJUT
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _nextQuestion,
                        child: Text(
                          _currentQuestionIndex < _questions.length - 1
                              ? 'Soal Selanjutnya'
                              : 'Lihat Hasil',
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
