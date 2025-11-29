import 'package:flutter/material.dart';

class Contact {
  String name;
  String phone;
  String date;
  Color color;
  String? filePath;

  Contact({
    required this.name,
    required this.phone,
    required this.date,
    required this.color,
    this.filePath,
  });
}
