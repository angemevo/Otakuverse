import 'package:flutter/material.dart';

// ============================================
// TEXTE
// ============================================
class StoryText {
  String text;
  Offset position;
  Color color;
  Color backgroundColor;
  double fontSize;
  String fontStyle; // 'normal', 'bold', 'italic', 'neon', 'outlined'
  TextAlign alignment;
  String id;
  double rotation;
  double scale;

  StoryText({
    required this.text,
    required this.position,
    this.color = Colors.white,
    this.backgroundColor = Colors.transparent,
    this.fontSize = 24.0,
    this.fontStyle = 'normal',
    this.alignment = TextAlign.center,
    required this.id,
    this.rotation = 0.0,
    this.scale = 1.0,
  });
}

// ============================================
// STICKER
// ============================================
class StorySticker {
  String emoji;
  Offset position;
  double size;
  String id;
  double rotation;

  StorySticker({
    required this.emoji,
    required this.position,
    this.size = 80.0,
    required this.id,
    this.rotation = 0.0,
  });
}

// ============================================
// DESSIN
// ============================================
class DrawingPath {
  List<Offset> points;
  Color color;
  double strokeWidth;
  String id;

  DrawingPath({
    required this.points,
    required this.color,
    this.strokeWidth = 3.0,
    required this.id,
  });
}

// ============================================
// FORME
// ============================================
enum ShapeType { rectangle, circle, arrow, line, heart }

class StoryShape {
  ShapeType type;
  Offset position;
  Size size;
  Color color;
  double strokeWidth;
  bool filled;
  String id;
  double rotation;

  StoryShape({
    required this.type,
    required this.position,
    required this.size,
    required this.color,
    this.strokeWidth = 3.0,
    this.filled = false,
    required this.id,
    this.rotation = 0.0,
  });
}

// ============================================
// MUSIQUE (pour vidéos)
// ============================================
class StoryMusic {
  String name;
  String path;
  Duration duration;

  StoryMusic({
    required this.name,
    required this.path,
    required this.duration,
  });
}