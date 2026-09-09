import 'package:flutter/material.dart';

class CategoryModel {
  final int? id;
  final String name;
  final int colorValue;
  final int iconCode;

  CategoryModel({
    this.id,
    required this.name,
    required this.colorValue,
    required this.iconCode,
  });

  Color get color => Color(colorValue);
  // ignore: non_const_argument_for_const_parameter
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconCode': iconCode,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      colorValue: map['colorValue'] as int,
      iconCode: map['iconCode'] as int,
    );
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    int? colorValue,
    int? iconCode,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconCode: iconCode ?? this.iconCode,
    );
  }
}
