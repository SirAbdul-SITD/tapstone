import 'package:flutter/material.dart';

/// Slate-and-chalk theme: cool grey stone board, chalky white shading,
/// cyan clue numerals — evokes a chalkboard / stone-tablet feel.
class Palette {
  // Surfaces
  static const slate = Color(0xFF14181C); // deepest background
  static const panel = Color(0xFF1C2126); // panel
  static const raised = Color(0xFF262C33); // raised surface
  static const board = Color(0xFF20262C); // board bg (white/unshaded cells)

  // Cell states
  static const shadedFill = Color(0xFF0D1013); // shaded/black cell
  static const clueFill = Color(0xFF2A3138); // clue cell background
  static const conflictFill = Color(0xFF3A2226);

  // Text / accents
  static const chalk = Color(0xFFE7EDF2);
  static const cyan = Color(0xFF4FB6C7);
  static const haze = Color(0xFF8A96A3);
  static const line = Color(0xFF343B43);
  static const coral = Color(0xFFC65B4E);
  static const sage = Color(0xFF6FA37B);
  static const amber = Color(0xFFCFA24C);

  static const tierColors = {
    'easy': Color(0xFF6FA37B),
    'medium': Color(0xFFCFA24C),
    'hard': Color(0xFFC65B4E),
  };
}
