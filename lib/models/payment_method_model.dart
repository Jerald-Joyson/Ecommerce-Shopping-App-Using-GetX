import 'package:flutter/material.dart';

class PaymentMethodModel {
  final String id;
  final String name;
  final IconData icon;
  final String description;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });
}
    