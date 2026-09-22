import '../models/game_level.dart';

class ColorgramRules {
  ColorgramRules._();

  static bool isComplete(List<List<int>> board, GameLevel level) {
    final size = level.gridSize;

    for (int r = 0; r < size; r++) {
      if (!isRowSatisfied(board[r], level.rowClues[r])) {
        return false;
      }
    }

    for (int c = 0; c < size; c++) {
      if (!isColSatisfied(board, level.colClues[c], c)) {
        return false;
      }
    }

    return true;
  }

  static bool isRowSatisfied(List<int> boardRow, List<ColorClue> expectedClues) {
    final clues = <ColorClue>[];
    int count = 0;
    int currentColor = 0;

    for (int c = 0; c < boardRow.length; c++) {
      final val = boardRow[c];
      if (val > 0) {
        if (val == currentColor) {
          count++;
        } else {
          if (count > 0) {
            clues.add(ColorClue(count: count, colorIndex: currentColor));
          }
          currentColor = val;
          count = 1;
        }
      } else {
        if (count > 0) {
          clues.add(ColorClue(count: count, colorIndex: currentColor));
          count = 0;
          currentColor = 0;
        }
      }
    }
    if (count > 0) {
      clues.add(ColorClue(count: count, colorIndex: currentColor));
    }

    if (clues.length != expectedClues.length) return false;
    for (int i = 0; i < clues.length; i++) {
      if (clues[i].count != expectedClues[i].count ||
          clues[i].colorIndex != expectedClues[i].colorIndex) {
        return false;
      }
    }
    return true;
  }

  static bool isColSatisfied(
    List<List<int>> board,
    List<ColorClue> expectedClues,
    int col,
  ) {
    final clues = <ColorClue>[];
    int count = 0;
    int currentColor = 0;

    for (int r = 0; r < board.length; r++) {
      final val = board[r][col];
      if (val > 0) {
        if (val == currentColor) {
          count++;
        } else {
          if (count > 0) {
            clues.add(ColorClue(count: count, colorIndex: currentColor));
          }
          currentColor = val;
          count = 1;
        }
      } else {
        if (count > 0) {
          clues.add(ColorClue(count: count, colorIndex: currentColor));
          count = 0;
          currentColor = 0;
        }
      }
    }
    if (count > 0) {
      clues.add(ColorClue(count: count, colorIndex: currentColor));
    }

    if (clues.length != expectedClues.length) return false;
    for (int i = 0; i < clues.length; i++) {
      if (clues[i].count != expectedClues[i].count ||
          clues[i].colorIndex != expectedClues[i].colorIndex) {
        return false;
      }
    }
    return true;
  }

  static List<int>? suggestHint(
    List<List<int>> board,
    GameLevel level,
  ) {
    final size = level.gridSize;

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (board[r][c] > 0 && board[r][c] != level.solutionGrid[r][c]) {
          return [r, c];
        }
      }
    }

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (level.solutionGrid[r][c] > 0 && board[r][c] != level.solutionGrid[r][c]) {
          return [r, c];
        }
      }
    }

    return null;
  }

  static List<List<ColorClue>> computeRowClues(List<List<int>> grid, int size) {
    final clues = <List<ColorClue>>[];
    for (int r = 0; r < size; r++) {
      final rowClue = <ColorClue>[];
      int count = 0;
      int currentColor = 0;
      for (int c = 0; c < size; c++) {
        final val = grid[r][c];
        if (val > 0) {
          if (val == currentColor) {
            count++;
          } else {
            if (count > 0) {
              rowClue.add(ColorClue(count: count, colorIndex: currentColor));
            }
            currentColor = val;
            count = 1;
          }
        } else {
          if (count > 0) {
            rowClue.add(ColorClue(count: count, colorIndex: currentColor));
            count = 0;
            currentColor = 0;
          }
        }
      }
      if (count > 0) {
        rowClue.add(ColorClue(count: count, colorIndex: currentColor));
      }
      clues.add(rowClue);
    }
    return clues;
  }

  static List<List<ColorClue>> computeColClues(List<List<int>> grid, int size) {
    final clues = <List<ColorClue>>[];
    for (int c = 0; c < size; c++) {
      final colClue = <ColorClue>[];
      int count = 0;
      int currentColor = 0;
      for (int r = 0; r < size; r++) {
        final val = grid[r][c];
        if (val > 0) {
          if (val == currentColor) {
            count++;
          } else {
            if (count > 0) {
              colClue.add(ColorClue(count: count, colorIndex: currentColor));
            }
            currentColor = val;
            count = 1;
          }
        } else {
          if (count > 0) {
            colClue.add(ColorClue(count: count, colorIndex: currentColor));
            count = 0;
            currentColor = 0;
          }
        }
      }
      if (count > 0) {
        colClue.add(ColorClue(count: count, colorIndex: currentColor));
      }
      clues.add(colClue);
    }
    return clues;
  }
}
