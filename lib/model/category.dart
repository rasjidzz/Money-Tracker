import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon; // You can use IconData if you want to use Flutter icons

  Category({
    required this.id,
    required this.name,
    required this.icon,
  });
}
