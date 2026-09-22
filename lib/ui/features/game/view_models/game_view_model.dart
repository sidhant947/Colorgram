import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/progress_repository.dart';
import '../../../../domain/models/game_level.dart';
import '../../../../domain/use_cases/level_generator.dart';
import '../../../../domain/use_cases/colorgram_rules.dart';

@immutable
class _Snapshot {
  const _Snapshot(this.board, this.moveCount);
  final List<List<int>> board;
  final int moveCount;
}

@immutable
class GameViewModelState {
  const GameViewModelState({
    this.level,
    this.board = const [],
    this.isLoading = false,
    this.isComplete = false,
    this.moveCount = 0,
    this.elapsedSeconds = 0,
    this.canUndo = false,
    this.hintCell,
    this.isRandomMode = false,
    this.randomDifficulty,
    this.randomSeed,
    this.selectedTool = 1,
  });

  final GameLevel? level;
  final List<List<int>> board;
  final bool isLoading;
  final bool isComplete;
  final int moveCount;
  final int elapsedSeconds;
  final bool canUndo;
  final int? hintCell;
  final bool isRandomMode;
  final String? randomDifficulty;
  final int? randomSeed;
  final int selectedTool;

  GameViewModelState copyWith({
    GameLevel? level,
    List<List<int>>? board,
    bool? isLoading,
    bool? isComplete,
    int? moveCount,
    int? elapsedSeconds,
    bool? canUndo,
    int? hintCell,
    bool clearHint = false,
    int? selectedTool,
  }) {
    return GameViewModelState(
      level: level ?? this.level,
      board: board ?? this.board,
      isLoading: isLoading ?? this.isLoading,
      isComplete: isComplete ?? this.isComplete,
      moveCount: moveCount ?? this.moveCount,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      canUndo: canUndo ?? this.canUndo,
      hintCell: clearHint ? null : (hintCell ?? this.hintCell),
      isRandomMode: isRandomMode,
      randomDifficulty: randomDifficulty,
      randomSeed: randomSeed,
      selectedTool: selectedTool ?? this.selectedTool,
    );
  }
}

class GameViewModel extends StateNotifier<GameViewModelState> {
  GameViewModel({
    required this.progressRepository,
    required this.levelGenerator,
  }) : super(const GameViewModelState());

  final ProgressRepository progressRepository;
  final LevelGenerator levelGenerator;

  static const int _maxUndo = 50;
  final List<_Snapshot> _undoStack = [];
  Timer? _timer;
  Timer? _hintTimer;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isComplete) {
        _timer?.cancel();
        return;
      }
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _triggerHaptic(Future<void> Function() hapticAction) {
    if (progressRepository.hapticsEnabled) {
      hapticAction();
    }
  }

  List<List<int>> _emptyBoard(int n) =>
      List.generate(n, (_) => List<int>.filled(n, 0));

  Future<void> loadLevel(int levelNumber) async {
    _undoStack.clear();
    state = const GameViewModelState(isLoading: true);

    try {
      final level = levelGenerator.generate(levelNumber);
      final progress = await progressRepository.getProgress();
      List<List<int>> board;
      int moveCount = 0;
      int elapsed = 0;

      if (progress.savedLevelNumber == levelNumber &&
          progress.savedBoard != null &&
          progress.savedBoard!.length == level.gridSize) {
        board = progress.savedBoard!
            .map((row) => List<int>.from(row))
            .toList();
        moveCount = progress.savedMoveCount;
        elapsed = progress.savedElapsedSeconds;
      } else {
        board = _emptyBoard(level.gridSize);
      }

      final isComplete = ColorgramRules.isComplete(board, level);

      state = GameViewModelState(
        level: level,
        board: board,
        moveCount: moveCount,
        elapsedSeconds: elapsed,
        isComplete: isComplete,
        selectedTool: 1,
      );
      if (!isComplete) _startTimer();
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadRandomLevel(String difficulty, {int? seed}) async {
    _undoStack.clear();
    final int levelSeed = seed ?? DateTime.now().millisecondsSinceEpoch;
    state = GameViewModelState(
      isLoading: true,
      isRandomMode: true,
      randomDifficulty: difficulty,
      randomSeed: levelSeed,
    );

    try {
      int gridSize = 5;
      int colors = 2;
      if (difficulty == 'Medium') {
        gridSize = 7;
        colors = 2;
      } else if (difficulty == 'Hard') {
        gridSize = 8;
        colors = 3;
      } else if (difficulty == 'Master') {
        gridSize = 10;
        colors = 3;
      } else if (difficulty == 'Expert') {
        gridSize = 12;
        colors = 3;
      }

      final level = levelGenerator.generateRandom(
        gridSize: gridSize,
        seed: levelSeed,
        colors: colors,
      );
      final board = _emptyBoard(gridSize);

      state = state.copyWith(
        level: level,
        board: board,
        moveCount: 0,
        elapsedSeconds: 0,
        canUndo: false,
        isLoading: false,
        selectedTool: 1,
      );
      _startTimer();
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void selectTool(int tool) {
    if (state.selectedTool == tool) return;
    _triggerHaptic(HapticFeedback.selectionClick);
    state = state.copyWith(selectedTool: tool);
  }

  void toggleCell(int r, int c) {
    final level = state.level;
    if (state.isComplete || level == null) return;

    _pushUndo();

    final n = level.gridSize;
    final newBoard = List.generate(
      n,
      (row) => List<int>.from(state.board[row]),
    );

    final current = newBoard[r][c];
    int next;
    int movesDelta = 0;

    if (current == state.selectedTool) {
      next = 0;
      _triggerHaptic(HapticFeedback.lightImpact);
    } else {
      next = state.selectedTool;
      if (next > 0) {
        movesDelta = 1;
        _triggerHaptic(HapticFeedback.mediumImpact);
      } else {
        _triggerHaptic(HapticFeedback.lightImpact);
      }
    }

    newBoard[r][c] = next;

    final isComplete = ColorgramRules.isComplete(newBoard, level);

    if (isComplete) {
      _triggerHaptic(HapticFeedback.heavyImpact);
      _stopTimer();
    }

    state = state.copyWith(
      board: newBoard,
      moveCount: state.moveCount + movesDelta,
      isComplete: isComplete,
      canUndo: _undoStack.isNotEmpty,
      clearHint: true,
    );

    _persistInProgress();
  }

  void setCell(int r, int c, int next) {
    final level = state.level;
    if (state.isComplete || level == null) return;

    final current = state.board[r][c];
    if (current == next) return;

    _pushUndo();

    final n = level.gridSize;
    final newBoard = List.generate(
      n,
      (row) => List<int>.from(state.board[row]),
    );

    newBoard[r][c] = next;

    final isComplete = ColorgramRules.isComplete(newBoard, level);

    if (isComplete) {
      _triggerHaptic(HapticFeedback.heavyImpact);
      _stopTimer();
    } else {
      _triggerHaptic(HapticFeedback.selectionClick);
    }

    state = state.copyWith(
      board: newBoard,
      moveCount: state.moveCount + (next > 0 ? 1 : 0),
      isComplete: isComplete,
      canUndo: _undoStack.isNotEmpty,
      clearHint: true,
    );

    _persistInProgress();
  }

  void _pushUndo() {
    final snapshotBoard = state.board
        .map((row) => List<int>.from(row))
        .toList(growable: false);
    _undoStack.add(_Snapshot(snapshotBoard, state.moveCount));
    if (_undoStack.length > _maxUndo) {
      _undoStack.removeAt(0);
    }
  }

  void undo() {
    if (_undoStack.isEmpty || state.level == null || state.isComplete) return;
    final snapshot = _undoStack.removeLast();
    _triggerHaptic(HapticFeedback.lightImpact);
    state = state.copyWith(
      board: snapshot.board,
      moveCount: snapshot.moveCount,
      canUndo: _undoStack.isNotEmpty,
      clearHint: true,
    );
    _persistInProgress();
  }

  void requestHint() {
    final level = state.level;
    if (level == null || state.isComplete) return;
    final hint = ColorgramRules.suggestHint(state.board, level);
    if (hint == null) return;
    final encoded = hint[0] * level.gridSize + hint[1];
    _triggerHaptic(HapticFeedback.selectionClick);
    state = state.copyWith(hintCell: encoded);

    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) state = state.copyWith(clearHint: true);
    });
  }

  void _persistInProgress() {
    final level = state.level;
    if (level == null || state.isRandomMode || state.isComplete) return;
    progressRepository.saveInProgress(
      level.levelNumber,
      state.board,
      state.moveCount,
      state.elapsedSeconds,
    );
  }

  Future<void> completeLevel() async {
    final level = state.level;
    if (level == null || !state.isComplete) return;
    if (state.isRandomMode) {
      await progressRepository.addRandomLevelMoves(state.moveCount);
    } else {
      await progressRepository.completeLevel(level.levelNumber, state.moveCount);
      await progressRepository.recordLevelResult(
        level.levelNumber,
        state.moveCount,
        state.elapsedSeconds,
      );
      await progressRepository.clearInProgress();
    }
  }

  Future<void> resetLevel() async {
    final level = state.level;
    if (level == null) return;
    if (state.isRandomMode) {
      await loadRandomLevel(
        state.randomDifficulty ?? 'Easy',
        seed: state.randomSeed,
      );
    } else {
      await progressRepository.clearInProgress();
      await loadLevel(level.levelNumber);
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _hintTimer?.cancel();
    super.dispose();
  }
}
