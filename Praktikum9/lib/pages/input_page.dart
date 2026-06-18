// ignore_for_file: prefer_const_constructors
import 'package:bmi/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'result_page.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text("Kalkulator BMI"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [

                SizedBox(height: 30),

                //BERAT BADAN
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon isi data ini'; // Pesan error jika kosong
                    }
                    if (int.parse(value) <= 0) {
                      return 'Berat harus lebih dari 0';
                    }
                    return null; // Valid jika isi
                  },
                  controller: _weightController,
                  decoration: InputDecoration(
                    labelText: 'Berat Badan',
                    hintText: 'Contoh: 65',
                    suffixText: 'kg',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),

                SizedBox(height: 30),

                //TINGGI BADAN
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon isi data ini'; // Pesan error jika kosong
                    }
                    if (int.parse(value) <= 0) {
                      return 'Tinggi harus lebih dari 0';
                    }
                    return null; // Valid jika isi
                  },
                  controller: _heightController,
                  decoration: InputDecoration(
                    labelText: 'Tinggi Badan',
                    hintText: 'Contoh: 170',
                    suffixText: 'cm',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),

                SizedBox(height: 30),

                //HITUNG
                SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final berat =
                          double.parse(_weightController.text);

                      final tinggi =
                          double.parse(_heightController.text) / 100;

                      final bmi = berat / (tinggi * tinggi);
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultPage(
                            bmi: bmi,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Hitung BMI",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
             