import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const FruitCatcherApp());
}

class FruitCatcherApp extends StatelessWidget {
  const FruitCatcherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Fruit Catcher Game",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const FruitCatcherGame(),
    );
  }
}

class FruitCatcherGame extends StatefulWidget {
  const FruitCatcherGame({super.key});

  @override
  State<FruitCatcherGame> createState() => _FruitCatcherGameState();
}

class _FruitCatcherGameState extends State<FruitCatcherGame> {
  double basketX = 0; 
  double fruitX = 0;
  double fruitY = -1.0;
  int score = 0;
  int lives = 3;

  late Timer gameTimer;
  Random random = Random();
  List<String> fruits = ["🍎", "🍌", "🍇", "🍓", "🍒", "🍍"];

  String currentFruit = "🍎";
  bool gameStarted = false; // 👈 नया variable

  void startGame() {
    setState(() {
      gameStarted = true;
      score = 0;
      lives = 3;
      basketX = 0;
      resetFruit();
    });

    gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        fruitY += 0.02;

        if (fruitY > 1) {
          lives--;
          resetFruit();
          if (lives == 0) {
            gameTimer.cancel();
            _showGameOverDialog();
          }
        }

        if ((fruitY > 0.85) && ((fruitX - basketX).abs() < 0.2)) {
          score++;
          resetFruit();
        }
      });
    });
  }

  void resetFruit() {
    fruitX = (random.nextDouble() * 2 - 1); 
    fruitY = -1.0;
    currentFruit = fruits[random.nextInt(fruits.length)];
  }

  void moveBasket(double dx) {
    setState(() {
      basketX += dx;
      if (basketX < -1) basketX = -1;
      if (basketX > 1) basketX = 1;
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("Your Score: $score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                gameStarted = false; // 👈 दुबारा start screen पर जाए
              });
            },
            child: const Text("Main Menu"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startGame(); // दुबारा start
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (gameStarted) {
      gameTimer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🍎 Fruit Catcher Game"),
        centerTitle: true,
      ),
      body: gameStarted
          ? GestureDetector(
              onHorizontalDragUpdate: (details) {
                moveBasket(details.delta.dx /
                    MediaQuery.of(context).size.width *
                    2);
              },
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Text("Score: $score",
                        style: const TextStyle(fontSize: 22)),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Text("❤ $lives",
                        style: const TextStyle(fontSize: 22)),
                  ),
                  Align(
                    alignment: Alignment(fruitX, fruitY),
                    child:
                        Text(currentFruit, style: const TextStyle(fontSize: 40)),
                  ),
                  Align(
                    alignment: Alignment(basketX, 0.9),
                    child: Container(
                      width: 80,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text("🧺", style: TextStyle(fontSize: 28)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : // 👇 Start Screen UI
          Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("🍎 Welcome to Fruit Catcher 🍎",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: startGame,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15)),
                    child: const Text("Start Game",
                        style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ),
    );
  }
}