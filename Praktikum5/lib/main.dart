import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 242, 161, 188),
        appBar: AppBar(
          title: Text(
            "Dice",
            style: TextStyle(color: const Color.fromARGB(255, 8, 0, 0)),
          )
        ),
        body: MyWidget(),
      )
    ),
  );
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int leftDiceNumber = 1;
  int rightDiceNumber = 1;

  void changeLeftDice() {
    setState(() {
      leftDiceNumber = Random().nextInt(6) + 1;
    });
  }

  void changeRightDice() {
    setState(() {
      rightDiceNumber = Random().nextInt(6) + 1;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                changeLeftDice();
              },
              child: Image.asset('images/dice$leftDiceNumber.png')
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () {
                changeRightDice();
              },
                child: Image.asset('images/dice$rightDiceNumber.png')
            ),
          ),
        ],
      ),
    );
  }
}