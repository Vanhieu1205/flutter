import 'package:flutter/material.dart';

abstract class Transaction {
  final String title;
  final double amount;
  final DateTime date;
  final String? note;

  Transaction({
    required this.title,
    required this.amount,
    required this.date,
    this.note,
  });
}

class Income extends Transaction {
  final String category;
  final String? source;

  Income({
    required super.title,
    required super.amount,
    required super.date,
    super.note,
    required this.category,
    this.source,
  });
}

class Expense extends Transaction {
  final String category;
  final String? paymentMethod;

  Expense({
    required super.title,
    required super.amount,
    required super.date,
    super.note,
    required this.category,
    this.paymentMethod,
  });
}
