// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations

import 'package:bmi/utils/theme.dart';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final double bmi;

  const ResultPage(
      {required this.bmi,
      super.key});

  String getKategori() {
    if (bmi < 18.5) return 'Kurus';
    if (bmi < 25.0) return 'Normal';
    if (bmi <= 30.0) return 'Gemuk';
    return "Obesitas";
  }

  double getPointerPosition() {
  if (bmi < 18.5) return 0.1;
  if (bmi < 25) return 0.35;
  if (bmi < 30) return 0.65;
  return 0.9;
}

  // TIPS BMI
  List<String> getTips() {
    if (bmi < 18.5) {
      return [
        "Perbanyak makanan bergizi",
        "Tidur yang cukup",
        "Konsumsi protein lebih banyak"
      ];
    }

    if (bmi < 25) {
      return [
        "Tetap aktif setiap hari",
        "Pertahankan pola makan sehat",
        "Minum air putih yang cukup"
      ];
    }

    if (bmi < 30) {
      return [
        "Kurangi makanan manis",
        "Mulai rutin berolahraga",
        "Perbanyak konsumsi sayur"
      ];
    }

    return [
      "Kurangi gula dan lemak",
      "Olahraga secara rutin",
      "Jaga pola makan sehat"
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tips = getTips();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text("Hasil BMI"),
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [

              SizedBox(height: 20),

              /// JUDUL
              Text(
                "Indeks Massa Tubuh Anda",
                style: TextStyle(
                  color: fontColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 25),

              /// ANGKA BMI
              Text(
                bmi.toStringAsFixed(1),
                style: TextStyle(
                  color: fontColor,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),

               SizedBox(height: 20),

              /// BAR BMI
              SizedBox(
              width: double.infinity,
              height: 50,

              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      /// POINTER
                      Positioned(
                        left: constraints.maxWidth * getPointerPosition(),

                        child: Icon(
                          Icons.arrow_drop_down,
                          color: const Color.fromARGB(255, 224, 10, 10),
                          size: 40,
                        ),
                      ),

              // BAR BMI
              Positioned(
                top: 30,

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),

                  child: Row(
                    children: [
                      Container(
                        width: constraints.maxWidth / 4,
                        height: 14,
                        color: Colors.blue,
                      ),

                      Container(
                        width: constraints.maxWidth / 4,
                        height: 14,
                        color: Colors.green,
                      ),

                      Container(
                        width: constraints.maxWidth / 4,
                        height: 14,
                        color: Colors.orange,
                      ),

                      Container(
                        width: constraints.maxWidth / 4,
                        height: 14,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),

              SizedBox(height: 40),

              /// ICON
              Icon(
                Icons.accessibility_new,
                color: fontColor,
                size: 140,
              ),

              SizedBox(height: 20),

              /// STATUS BMI
              Text(
                getKategori(),
                style: TextStyle(
                  color: fontColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 35),

              /// CARD TIPS
              ...List.generate(
                tips.length,
                (index) => Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: fontColor,
                        size: 28,
                      ),

                      SizedBox(width: 15),

                      Expanded(
                        child: Text(
                          tips[index],
                          style: TextStyle(
                            color: fontColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: Text(
                    "Hitung Ulang",
                    style: TextStyle(
                      color: fontColor,
                      fontSize: 18,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}