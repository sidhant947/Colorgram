import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/game_level.dart';
import 'colorgram_rules.dart';

class LevelGenerator {
  final Map<int, GameLevel> _cache = {};
  final Set<int> _generating = {};

  static const List<List<Color>> _palettes = [
    [Color(0xFF4CAF50), Color(0xFFE53935), Color(0xFFFFBE0B)],
    [Color(0xFFEF233C), Color(0xFFFF758F), Color(0xFF5E60CE)],
    [Color(0xFFE63946), Color(0xFFF4A261), Color(0xFF2A9D8F)],
    [Color(0xFFE0E1DD), Color(0xFF1D3557), Color(0xFFE63946)],
    [Color(0xFFFFD166), Color(0xFFF77F00), Color(0xFF06D6A0)],
    [Color(0xFF8B5E3C), Color(0xFF48CAE4), Color(0xFFFFB703)],
    [Color(0xFFFFD166), Color(0xFF9B5DE5), Color(0xFF2A9D8F)],
    [Color(0xFFFFB703), Color(0xFFD90429), Color(0xFF00B4D8)],
    [Color(0xFF38B000), Color(0xFF7F4F24), Color(0xFFFFD166)],
    [Color(0xFFFB8500), Color(0xFF219EBC), Color(0xFF8338EC)],
    [Color(0xFF00B4D8), Color(0xFFFFB703), Color(0xFFD90429)],
    [Color(0xFF06D6A0), Color(0xFF118AB2), Color(0xFFEF476F)],
  ];

  LevelGenerator({bool pregenerate = true}) {
    if (pregenerate) {
      pregenerateBatch(1, count: 3);
    }
  }

  void pregenerateBatch(int startLevel, {int count = 3}) {
    for (int i = 0; i < count; i++) {
      final levelNumber = startLevel + i;
      if (!_cache.containsKey(levelNumber) && !_generating.contains(levelNumber)) {
        _generating.add(levelNumber);
        compute(_isolateGenerate, levelNumber).then((level) {
          _cache[levelNumber] = level;
          _generating.remove(levelNumber);
        }).catchError((e) {
          _generating.remove(levelNumber);
        });
      }
    }
  }

  GameLevel generate(int levelNumber) {
    GameLevel level;
    if (_cache.containsKey(levelNumber)) {
      level = _cache.remove(levelNumber)!;
    } else {
      level = _generateInternal(levelNumber);
    }
    _generating.remove(levelNumber);
    pregenerateBatch(levelNumber + 1, count: 2);
    return level;
  }

  GameLevel _generateInternal(int levelNumber) {
    final gridSize = _getGridSize(levelNumber);
    final colorCount = _getColorCount(levelNumber);
    final paletteIndex = (levelNumber - 1).abs() % _palettes.length;
    final selectedPalette = _palettes[paletteIndex];
    final palette = selectedPalette.sublist(0, min(colorCount, selectedPalette.length));
    return _generateProceduralLevel(
      levelNumber: levelNumber,
      name: 'LEVEL $levelNumber',
      gridSize: gridSize,
      palette: palette,
    );
  }

  static GameLevel _isolateGenerate(int levelNumber) {
    return LevelGenerator(pregenerate: false)._generateInternal(levelNumber);
  }

  GameLevel generateRandom({
    required int gridSize,
    required int seed,
    int? colors,
  }) {
    final colorCount = colors ?? (gridSize <= 5 ? 2 : 3);
    final paletteIndex = seed.abs() % _palettes.length;
    final selectedPalette = _palettes[paletteIndex];
    final palette = selectedPalette.sublist(0, min(colorCount, selectedPalette.length));
    return _generateProceduralLevel(
      levelNumber: -1,
      name: 'MYSTERY ${(seed % 999).abs()}',
      gridSize: gridSize,
      palette: palette,
      seedOverride: seed,
    );
  }

  int _getGridSize(int level) {
    if (level <= 5) return 5;
    if (level <= 10) return 6;
    if (level <= 15) return 7;
    if (level <= 25) return 8;
    if (level <= 40) return 10;
    return 12;
  }

  int _getColorCount(int level) {
    if (level <= 6) return 2;
    return 3;
  }

  GameLevel _generateProceduralLevel({
    required int levelNumber,
    required String name,
    required int gridSize,
    required List<Color> palette,
    int? seedOverride,
  }) {
    int seedOffset = 0;
    final colorCount = palette.length;
    final isAsymmetric = gridSize > 5 || levelNumber > 5;
    final minRounds = gridSize <= 5 && levelNumber <= 5
        ? 1
        : ((gridSize <= 7 && levelNumber <= 15) ? 2 : 3);
    GameLevel? fallbackLevel;

    while (true) {
      final seed = seedOverride != null
          ? (seedOverride + seedOffset) & 0x7FFFFFFF
          : ((levelNumber * 31337 + seedOffset * 7919) & 0x7FFFFFFF);
      seedOffset++;
      final random = Random(seed);

      final grid = List.generate(
        gridSize,
        (_) => List<int>.filled(gridSize, 0),
      );
      final fillProb = 0.44 + random.nextDouble() * 0.12;

      if (!isAsymmetric) {
        final half = (gridSize / 2).ceil();
        for (int r = 0; r < gridSize; r++) {
          for (int c = 0; c < half; c++) {
            if (random.nextDouble() < fillProb) {
              final color = 1 + random.nextInt(colorCount);
              grid[r][c] = color;
              grid[r][gridSize - 1 - c] = color;
            }
          }
        }
      } else {
        for (int r = 0; r < gridSize; r++) {
          for (int c = 0; c < gridSize; c++) {
            if (random.nextDouble() < fillProb) {
              grid[r][c] = 1 + random.nextInt(colorCount);
            }
          }
        }
        for (int r = 0; r < gridSize; r++) {
          for (int c = 1; c < gridSize; c++) {
            if (grid[r][c - 1] > 0 && grid[r][c] == 0 && random.nextDouble() < 0.42) {
              grid[r][c] = grid[r][c - 1];
            }
          }
        }
      }

      final usedColors = <int>{};
      for (final row in grid) {
        for (final cell in row) {
          if (cell > 0) usedColors.add(cell);
        }
      }
      if (usedColors.length < colorCount) continue;

      final rowClues = ColorgramRules.computeRowClues(grid, gridSize);
      final colClues = ColorgramRules.computeColClues(grid, gridSize);

      bool valid = true;
      for (final r in rowClues) {
        if (r.isEmpty) {
          valid = false;
          break;
        }
      }
      for (final c in colClues) {
        if (c.isEmpty) {
          valid = false;
          break;
        }
      }
      if (!valid) continue;

      fallbackLevel ??= GameLevel(
        levelNumber: levelNumber,
        name: name,
        gridSize: gridSize,
        palette: palette,
        solutionGrid: grid,
        rowClues: rowClues,
        colClues: colClues,
      );

      final effectiveMinRounds = seedOffset > 30 ? 1 : minRounds;
      if (_countSolutions(gridSize, rowClues, colClues, minRounds: effectiveMinRounds) == 1) {
        return GameLevel(
          levelNumber: levelNumber,
          name: name,
          gridSize: gridSize,
          palette: palette,
          solutionGrid: grid,
          rowClues: rowClues,
          colClues: colClues,
        );
      }

      if (seedOffset > 50) {
        return fallbackLevel;
      }
    }
  }

  int _countSolutions(
    int size,
    List<List<ColorClue>> rowClues,
    List<List<ColorClue>> colClues, {
    int minRounds = 1,
  }) {
    int solutionsFound = 0;
    int statesVisited = 0;
    bool searchAborted = false;

    final rowPossibilities = <List<List<int>>>[];
    for (int r = 0; r < size; r++) {
      rowPossibilities.add(_generateLinePossibilities(size, rowClues[r]));
    }

    final colPossibilities = <List<List<int>>>[];
    for (int c = 0; c < size; c++) {
      colPossibilities.add(_generateLinePossibilities(size, colClues[c]));
    }

    bool changed = true;
    int rounds = 0;
    while (changed) {
      changed = false;
      rounds++;
      for (int r = 0; r < size; r++) {
        if (rowPossibilities[r].isEmpty) return 0;
        for (int c = 0; c < size; c++) {
          final firstVal = rowPossibilities[r].first[c];
          bool allSame = true;
          for (final rp in rowPossibilities[r]) {
            if (rp[c] != firstVal) {
              allSame = false;
              break;
            }
          }
          if (allSame) {
            final prevLen = colPossibilities[c].length;
            colPossibilities[c].removeWhere((cp) => cp[r] != firstVal);
            if (colPossibilities[c].length < prevLen) {
              changed = true;
              if (colPossibilities[c].isEmpty) return 0;
            }
          }
        }
      }

      for (int c = 0; c < size; c++) {
        if (colPossibilities[c].isEmpty) return 0;
        for (int r = 0; r < size; r++) {
          final firstVal = colPossibilities[c].first[r];
          bool allSame = true;
          for (final cp in colPossibilities[c]) {
            if (cp[r] != firstVal) {
              allSame = false;
              break;
            }
          }
          if (allSame) {
            final prevLen = rowPossibilities[r].length;
            rowPossibilities[r].removeWhere((rp) => rp[c] != firstVal);
            if (rowPossibilities[r].length < prevLen) {
              changed = true;
              if (rowPossibilities[r].isEmpty) return 0;
            }
          }
        }
      }
    }

    if (rounds < minRounds) return 0;

    bool allSingle = true;
    for (int r = 0; r < size; r++) {
      if (rowPossibilities[r].length != 1) {
        allSingle = false;
        break;
      }
    }
    if (allSingle) {
      for (int c = 0; c < size; c++) {
        if (colPossibilities[c].length != 1) {
          allSingle = false;
          break;
        }
      }
    }
    if (allSingle) return 1;

    final colHasValue = List.generate(
      size,
      (c) => List.generate(
        size,
        (r) {
          final vals = <int>{};
          for (final p in colPossibilities[c]) {
            vals.add(p[r]);
          }
          return vals;
        },
      ),
    );

    void solveRow(int rowIndex, List<List<int>> currentGrid) {
      if (solutionsFound >= 2 || searchAborted) return;
      statesVisited++;
      if (statesVisited > 800) {
        searchAborted = true;
        return;
      }

      if (rowIndex == size) {
        for (int c = 0; c < size; c++) {
          bool matched = false;
          for (final cp in colPossibilities[c]) {
            bool colMatch = true;
            for (int r = 0; r < size; r++) {
              if (cp[r] != currentGrid[r][c]) {
                colMatch = false;
                break;
              }
            }
            if (colMatch) {
              matched = true;
              break;
            }
          }
          if (!matched) return;
        }
        solutionsFound++;
        return;
      }

      for (final candidateRow in rowPossibilities[rowIndex]) {
        bool candidateValid = true;
        for (int c = 0; c < size; c++) {
          final val = candidateRow[c];
          if (!colHasValue[c][rowIndex].contains(val)) {
            candidateValid = false;
            break;
          }
        }

        if (!candidateValid) continue;

        currentGrid.add(candidateRow);
        solveRow(rowIndex + 1, currentGrid);
        currentGrid.removeLast();

        if (solutionsFound >= 2 || searchAborted) return;
      }
    }

    solveRow(0, []);
    if (searchAborted) return 0;
    return solutionsFound;
  }

  static List<List<int>> _generateLinePossibilities(int size, List<ColorClue> clues) {
    final results = <List<int>>[];
    if (clues.isEmpty) {
      results.add(List<int>.filled(size, 0));
      return results;
    }

    final minSuffixLengths = List<int>.filled(clues.length + 1, 0);
    for (int i = clues.length - 1; i >= 0; i--) {
      int len = clues[i].count;
      if (i < clues.length - 1) {
        final sep = clues[i].colorIndex == clues[i + 1].colorIndex ? 1 : 0;
        len += sep + minSuffixLengths[i + 1];
      }
      minSuffixLengths[i] = len;
    }

    void build(int clueIdx, int currentPos, List<int> line) {
      if (clueIdx == clues.length) {
        results.add(List<int>.from(line));
        return;
      }

      final clue = clues[clueIdx];
      final blockLen = clue.count;
      final color = clue.colorIndex;
      final maxStart = size - minSuffixLengths[clueIdx];
      final isLast = clueIdx == clues.length - 1;
      final nextColor = isLast ? -1 : clues[clueIdx + 1].colorIndex;
      final sep = (!isLast && color == nextColor) ? 1 : 0;

      for (int start = currentPos; start <= maxStart; start++) {
        for (int i = start; i < start + blockLen; i++) {
          line[i] = color;
        }

        final nextPos = start + blockLen + sep;
        build(clueIdx + 1, nextPos, line);

        for (int i = start; i < start + blockLen; i++) {
          line[i] = 0;
        }
      }
    }

    build(0, 0, List<int>.filled(size, 0));
    return results;
  }
}
