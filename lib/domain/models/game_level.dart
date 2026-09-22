import 'package:flutter/material.dart';

@immutable
class ColorClue {
  const ColorClue({
    required this.count,
    required this.colorIndex,
  });

  final int count;
  final int colorIndex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorClue &&
          runtimeType == other.runtimeType &&
          count == other.count &&
          colorIndex == other.colorIndex;

  @override
  int get hashCode => count.hashCode ^ colorIndex.hashCode;
}

@immutable
class GameLevel {
  const GameLevel({
    required this.levelNumber,
    required this.name,
    required this.gridSize,
    required this.palette,
    required this.solutionGrid,
    required this.rowClues,
    required this.colClues,
  });

  final int levelNumber;
  final String name;
  final int gridSize;
  final List<Color> palette;
  final List<List<int>> solutionGrid;
  final List<List<ColorClue>> rowClues;
  final List<List<ColorClue>> colClues;
}
