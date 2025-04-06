import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class MalariaQuizScreen extends StatefulWidget {
  @override
  _MalariaQuizScreenState createState() => _MalariaQuizScreenState();
}

class _MalariaQuizScreenState extends State<MalariaQuizScreen> {
  List<Map<String, dynamic>> malariaQuiz = [
    {
      "question": "Como a malária é transmitida ?",
      "options": [
        "Pelo ar",
        "Pessoa através do contato físico",
        "Pelo consumo de água contaminada",
        "Por mosquitos infectados",
        "Hereditário"
      ],
      "correctAnswer": "Por mosquitos infectados"
    },
    {
      "question": "O que causa a malária?",
      "options": ["Vírus", "Bactéria", "Parasita", "Fungo"],
      "correctAnswer": "Parasita"
    },
    {
      "question":
          "Qual gênero de mosquito é o principal transmissor da malária?",
      "options": ["Aedes", "Culex", "Anopheles", "Mansonia"],
      "correctAnswer": "Anopheles"
    },
    {
      "question":
          "Qual parasita é mais comumente associado à forma grave de malária?",
      "options": [
        "Plasmodium vivax",
        "Plasmodium falciparum",
        "Plasmodium ovale",
        "Plasmodium malariae"
      ],
      "correctAnswer": "Plasmodium falciparum"
    },
    {
      "question": "Qual é o principal sintoma inicial da malária?",
      "options": [
        "Tosse seca",
        "Febre",
        "Dor nas articulações",
        "Erupção cutânea"
      ],
      "correctAnswer": "Febre"
    },
    {
      "question":
          "Em que parte do corpo humano o parasita da malária se multiplica inicialmente?",
      "options": ["Pulmões", "Fígado", "Rins", "Coração"],
      "correctAnswer": "Fígado"
    },
    {
      "question": "Qual é uma medida eficaz para prevenir a malária?",
      "options": [
        "Beber água fervida",
        "Usar repelente de insetos",
        "Tomar antibióticos",
        "Evitar frutas tropicais"
      ],
      "correctAnswer": "Usar repelente de insetos"
    },
    {
      "question":
          "Qual medicamento é frequentemente usado no tratamento da malária?",
      "options": ["Penicilina", "Cloroquina", "Ibuprofeno", "Paracetamol"],
      "correctAnswer": "Cloroquina"
    },
    {
      "question": "Em que continente a malária é mais prevalente?",
      "options": ["Ásia", "Europa", "África", "Oceania"],
      "correctAnswer": "África"
    },
    {
      "question":
          "Qual é o nome do ciclo de vida do parasita da malária no mosquito?",
      "options": ["Esporogonia", "Gametogonia", "Merozoítos", "Trofozoítos"],
      "correctAnswer": "Esporogonia"
    },
    {
      "question":
          "Qual complicação grave pode ocorrer em casos de malária não tratada?",
      "options": [
        "Cegueira",
        "Malária cerebral",
        "Perda de audição",
        "Fratura óssea"
      ],
      "correctAnswer": "Malária cerebral"
    },
    {
      "question": "Qual é o vetor da malária?",
      "options": ["Mosca doméstica", "Mosquito Anopheles", "Barata", "Pulga"],
      "correctAnswer": "Mosquito Anopheles"
    },
    {
      "question":
          "Qual espécie de Plasmodium pode permanecer dormente no fígado?",
      "options": [
        "Plasmodium falciparum",
        "Plasmodium vivax",
        "Plasmodium malariae",
        "Plasmodium knowlesi"
      ],
      "correctAnswer": "Plasmodium vivax"
    },
    {
      "question": "Qual é o período típico de incubação da malária?",
      "options": ["1-2 dias", "7-30 dias", "2-3 meses", "6-12 meses"],
      "correctAnswer": "7-30 dias"
    },
    {
      "question": "Qual exame é mais usado para diagnosticar a malária?",
      "options": ["Raio-X", "Gota espessa", "Tomografia", "Ultrassom"],
      "correctAnswer": "Gota espessa"
    },
    {
      "question": "O que o mosquito Anopheles injeta ao picar uma pessoa?",
      "options": ["Vírus", "Esporozoítos", "Bactérias", "Toxinas"],
      "correctAnswer": "Esporozoítos"
    },
    {
      "question": "Qual é um sintoma comum da malária além da febre?",
      "options": [
        "Dor de cabeça",
        "Coceira na pele",
        "Visão dupla",
        "Perda de olfato"
      ],
      "correctAnswer": "Dor de cabeça"
    },
    {
      "question": "Qual é a principal fonte de infecção da malária?",
      "options": [
        "Água contaminada",
        "Picada de mosquito",
        "Alimentos crus",
        "Contato com sangue"
      ],
      "correctAnswer": "Picada de mosquito"
    },
    {
      "question":
          "Qual estação do ano favorece a proliferação do mosquito Anopheles?",
      "options": [
        "Inverno seco",
        "Verão chuvoso",
        "Outono frio",
        "Primavera seca"
      ],
      "correctAnswer": "Verão chuvoso"
    },
    {
      "question":
          "Qual é o nome da célula infectada pelo parasita na corrente sanguínea?",
      "options": ["Leucócito", "Hemácia", "Plaqueta", "Neurônio"],
      "correctAnswer": "Hemácia"
    },
    {
      "question": "Qual é uma consequência da malária grave em crianças?",
      "options": [
        "Anemia severa",
        "Crescimento acelerado",
        "Melhora da visão",
        "Aumento de peso"
      ],
      "correctAnswer": "Anemia severa"
    },
    {
      "question": "Qual é o objetivo da rede mosquiteira no combate à malária?",
      "options": [
        "Filtrar água",
        "Proteger contra picadas",
        "Aquecer o ambiente",
        "Capturar mosquitos"
      ],
      "correctAnswer": "Proteger contra picadas"
    },
  ];

  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answerChecked = false;
  List<Map<String, dynamic>> _shuffledQuestions = [];
  Timer? _timer;
  int _start = 15 * 60; // 15 minutes in seconds

  @override
  void initState() {
    super.initState();
    _shuffleQuestionsList();
    _startTimer();
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _submitQuiz(); // Automatically submit when time is up
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _shuffleQuestionsList() {
    final random = Random();
    _shuffledQuestions = List.from(malariaQuiz);
    if (_shuffledQuestions.length > 10) {
      _shuffledQuestions = _shuffledQuestions.sublist(
          0, 10); // Limit to 10 questions as per the image
    }
    _shuffledQuestions.shuffle(random);
  }

  Future<void> _showAnswerDialog(bool isCorrect, String? correctAnswer) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? 'Correct!' : 'Wrong!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(isCorrect ? '' : 'The answer was: $correctAnswer'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Next'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _nextQuestion();
              },
            ),
          ],
        );
      },
    );
  }

  void _checkAnswer(String selectedOption) {
    if (!_answerChecked) {
      setState(() {
        _selectedAnswer = selectedOption;
        _answerChecked = true;
      });
      bool isCorrect = selectedOption ==
          _shuffledQuestions[_currentQuestionIndex]['correctAnswer'];
      _showAnswerDialog(isCorrect,
          _shuffledQuestions[_currentQuestionIndex]['correctAnswer']);
      if (isCorrect) {
        setState(() {
          _score++;
        });
      }
    }
  }

  void _nextQuestion() {
    setState(() {
      _selectedAnswer = null;
      _answerChecked = false;
      _currentQuestionIndex++;
      if (_currentQuestionIndex >= _shuffledQuestions.length) {
        _submitQuiz();
      }
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0 && !_answerChecked) {
      setState(() {
        _currentQuestionIndex--;
        _selectedAnswer = null;
        _answerChecked = false;
      });
    }
  }

  void _submitQuiz() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
            score: _score, totalQuestions: _shuffledQuestions.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_shuffledQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Quiz Malaria')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = _shuffledQuestions[_currentQuestionIndex];
    final options = currentQuestion['options'] as List<String>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Malaria'),
        automaticallyImplyLeading: false, // To remove the back button
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(child: Text(_formatTime(_start))),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Progress Indicator
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_shuffledQuestions.length, (index) {
                  final questionNumber = index + 1;
                  final isCurrent = index == _currentQuestionIndex;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          isCurrent ? Colors.red : Colors.grey[300],
                      foregroundColor:
                          isCurrent ? Colors.white : Colors.grey[600],
                      child: Text('$questionNumber',
                          style: TextStyle(fontSize: 12)),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 24.0),
            Text(
              currentQuestion['question'] as String,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Column(
              children: options.asMap().entries.map((entry) {
                final int index = entry.key;
                final String option = entry.value;
                final letter = String.fromCharCode(65 + index); // A, B, C...
                final isSelected = _selectedAnswer == option;
                final isCorrect = _answerChecked &&
                    option == currentQuestion['correctAnswer'];
                final isIncorrect = _answerChecked &&
                    isSelected &&
                    option != currentQuestion['correctAnswer'];

                Color backgroundColor = Colors.white;
                Color textColor = Colors.black;
                if (isSelected) {
                  backgroundColor = Colors.blue[100]!;
                }
                if (isCorrect) {
                  backgroundColor = Colors.green[100]!;
                  textColor = Colors.white;
                }
                if (isIncorrect) {
                  backgroundColor = Colors.red[100]!;
                  textColor = Colors.white;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _answerChecked
                          ? (isCorrect
                              ? Colors.green[100]
                              : (isIncorrect ? Colors.red[100] : Colors.white))
                          : (isSelected ? Colors.blue[100] : Colors.white),
                      foregroundColor: _answerChecked
                          ? (isCorrect
                              ? Colors.white
                              : (isIncorrect ? Colors.white : Colors.black))
                          : Colors.black,
                      padding: EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    onPressed: _answerChecked
                        ? null
                        : () {
                            _checkAnswer(option);
                          },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          radius: 12,
                          child: Text(letter,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentQuestionIndex > 0 && !_answerChecked
                      ? _previousQuestion
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: _answerChecked ? _submitQuiz : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text('Enviar Quiz'),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _answerChecked &&
                          _currentQuestionIndex < _shuffledQuestions.length - 1
                      ? () {
                          // _nextQuestion will be called from the dialog
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  QuizResultScreen({required this.score, required this.totalQuestions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resultado do Quiz'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Você acertou:',
              style: TextStyle(fontSize: 24.0),
            ),
            Text(
              '$score / $totalQuestions',
              style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MalariaQuizScreen()),
                );
              },
              child: Text('Refazer o Quiz'),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
