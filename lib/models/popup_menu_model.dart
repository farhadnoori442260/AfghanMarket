import 'package:flutter/material.dart';

class PopUpMenuModel<T> {
  final T value;
  final String title;
  final IconData icon;

  const PopUpMenuModel({
    required this.value,
    required this.title,
    required this.icon,
  });
}
