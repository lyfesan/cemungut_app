import 'package:cemungut_app/presentation/screens/education/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    String message;
    IconData icon;
    Color iconColor;

    double percentage = totalQuestions > 0 ? (score / totalQuestions) : 0;
    if (percentage >= 0.8) {
      message = "Luar Biasa!";
      icon = Icons.workspace_premium;
      iconColor = Colors.amber;
    } else if (percentage >= 0.5) {
      message = "Kerja Bagus!";
      icon = Icons.thumb_up;
      iconColor = Colors.blue;
    } else {
      message = "Terus Belajar Ya!";
      icon = Icons.school;
      iconColor = Colors.green;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hasil Kuis"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 100, color: iconColor),
              const SizedBox(height: 24),
              Text(
                message,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Kamu berhasil menjawab $score dari $totalQuestions soal dengan benar.",
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text('Kembali ke Edukasi'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Get.off(() => const QuizScreen());
                      },
                      child: const Text('Ulangi Kuis'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
