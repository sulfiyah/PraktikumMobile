import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.purpleAccent,
        body: SafeArea(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                  "image/jungkook.jpeg",
                ),
              ),
              Text("Jeon Jungkook",
                  style: GoogleFonts.pacifico(
                    fontSize: 40,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  )),
              Text(
                "BTS Main Vocalist",
                style: GoogleFonts.sourceSans3(
                  fontSize: 20,
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.5,
                ),
              ),
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 25,
                  ),
                  child: Row(
                    children: [
                  Icon(
                    Icons.phone,
                    color: Colors.purpleAccent,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "087777777777",
                    style: GoogleFonts.sourceSans3(fontSize: 20),
                  ),],
                ),),
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 25,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.email,
                        color: Colors.purpleAccent,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "jungkook@gmail.com",
                        style: GoogleFonts.sourceSans3(
                          fontSize: 20, color: Colors.black
                        ),
                      ),],
                  ),),
            ],
          ),
        ),
      ),
    );
  }
}