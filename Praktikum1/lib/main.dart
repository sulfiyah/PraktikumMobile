import 'package:flutter/material.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 189, 89),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 100,
                color: const Color.fromARGB(255, 105, 255, 68),
                child: Text("Jeon Jungkook")
              ),
              SizedBox(width:20),
              Container(
                height: 100,
                color: Colors.blueAccent,
                child: Text("Jeon Supil")
              ),
              Container(
                height: double.infinity,
                color: const Color.fromARGB(255, 249, 255, 68),
                child: Text("Jeon Falikha")
              ),
            ],
          ),
        ),
      ),
    );
  }
}

