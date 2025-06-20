import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cemungut_app/app/models/quiz_question.dart';
import 'package:cemungut_app/app/services/firestore_service.dart';
import 'dart:math'; // Import untuk fungsi shuffle

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> _questionBatch = [];
  int _currentIndexInBatch = 0;

  bool _isLoading = true;
  String? _error; // State untuk menyimpan pesan error
  bool _isAnswered = false;
  int? _selectedAnswerIndex;

  @override
  void initState() {
    super.initState();
    _fetchNewBatch();
  }

  Future<void> _fetchNewBatch() async {
    setState(() {
      _isLoading = true;
      _error = null; // Hapus error lama saat mencoba lagi
    });

    try {
      final newQuestions = await FirestoreService.getQuizQuestions(limit: 10);
      print("Berhasil mengambil ${newQuestions.length} soal dari Firestore.");

      if (newQuestions.isEmpty && _questionBatch.isEmpty) {
        // Ini hanya terjadi jika dari awal database memang kosong
        throw Exception("Tidak ada soal yang ditemukan di database.");
      }

      // Jika berhasil dapat soal baru, update batch
      if (newQuestions.isNotEmpty) {
        _questionBatch = newQuestions;
      } else {
        // Jika gagal dapat soal baru TAPI sudah punya soal lama, acak saja yang lama
        // Ini menciptakan efek looping tanpa henti
        print("Gagal mengambil batch baru, mengacak ulang batch yang ada.");
        _questionBatch.shuffle(Random());
      }

      setState(() {
        _currentIndexInBatch = 0;
        _resetQuestionState();
      });
    } catch (e) {
      setState(() {
        _error = "Gagal memuat soal. Periksa koneksi internet Anda.";
        print("Error fetching questions: $e");
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _nextQuestion() {
    if (_currentIndexInBatch < _questionBatch.length - 1) {
      setState(() {
        _currentIndexInBatch++;
        _resetQuestionState();
      });
    } else {
      _fetchNewBatch();
    }
  }

  void _resetQuestionState() {
    _isAnswered = false;
    _selectedAnswerIndex = null;
  }

  void _answerQuestion(int selectedIndex) {
    setState(() {
      _isAnswered = true;
      _selectedAnswerIndex = selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/CemEdu.png', height: 32),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      // Tampilkan pesan error jika ada masalah saat memuat
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchNewBatch,
                child: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      );
    }
    return _buildQuizContent();
  }

  Widget _buildQuizContent() {
    final currentQuestion = _questionBatch[_currentIndexInBatch];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Widget pertanyaan dan pilihan jawaban... (Sama seperti sebelumnya)
          Text(
            currentQuestion.questionText,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
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
                onTap: _isAnswered ? null : () => _answerQuestion(index),
              ),
            );
          }),

          const Spacer(),

          if (_isAnswered)
            Column(
              children: [
                // Kotak Penjelasan Edukasi
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

                // Tombol Navigasi
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        child: const Text('Keluar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _nextQuestion,
                        child: const Text('Soal Selanjutnya'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
