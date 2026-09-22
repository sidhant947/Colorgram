import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/tangible_button.dart';
import '../../../../domain/models/game_level.dart';
import '../../../../domain/use_cases/colorgram_rules.dart';
import '../../../providers.dart';
import '../view_models/game_view_model.dart';

class GameView extends ConsumerStatefulWidget {
  const GameView({
    super.key,
    required this.levelNumber,
    this.isRandom = false,
    this.randomDifficulty,
    this.randomSeed,
  });

  final int levelNumber;
  final bool isRandom;
  final String? randomDifficulty;
  final int? randomSeed;

  @override
  ConsumerState<GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView> {
  int? _lastDraggedCell;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final vm = ref.read(gameViewModelProvider.notifier);
      if (widget.isRandom) {
        vm.loadRandomLevel(
          widget.randomDifficulty ?? 'Easy',
          seed: widget.randomSeed,
        );
      } else {
        vm.loadLevel(widget.levelNumber);
      }
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameViewModelProvider);
    final vm = ref.read(gameViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.headingDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isRandom ? '' : 'LEVEL ${widget.levelNumber}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.headingDark,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: AppColors.headingDark,
            ),
            tooltip: 'RESTART',
            onPressed: vm.resetLevel,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: state.isLoading || state.level == null
            ? Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              )
            : Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 90),
                      Expanded(
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black,
                                Colors.black,
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.08, 0.92, 1.0],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: InteractiveViewer(
                            minScale: 0.8,
                            maxScale: 4.0,
                            boundaryMargin: const EdgeInsets.all(40.0),
                            clipBehavior: Clip.none,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: _buildColorgramGrid(context, state, vm),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: state.isComplete ? 240 : 85,
                      ),
                    ],
                  ),

                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.bg,
                            AppColors.bg.withValues(alpha: 0.95),
                            AppColors.bg.withValues(alpha: 0.6),
                            AppColors.bg.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.55, 0.8, 1.0],
                        ),
                      ),
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      color: AppColors.subtext,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatTime(state.elapsedSeconds),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.subtext,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.touch_app_outlined,
                                      color: AppColors.subtext,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'MOVES: ${state.moveCount}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.subtext,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(
                                  icon: Icons.undo_rounded,
                                  label: 'UNDO',
                                  onPressed: state.canUndo && !state.isComplete
                                      ? vm.undo
                                      : null,
                                ),
                                _buildActionButton(
                                  icon: Icons.lightbulb_outline_rounded,
                                  label: 'HINT',
                                  iconColor: AppColors.gold,
                                  onPressed: state.isComplete
                                      ? null
                                      : vm.requestHint,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: state.isComplete
                          ? KeyedSubtree(
                              key: const ValueKey('completion_panel'),
                              child: _buildCompletionBottomPanel(
                                context,
                                state,
                                vm,
                              ),
                            )
                          : KeyedSubtree(
                              key: const ValueKey('mode_buttons'),
                              child: _buildPaletteSelector(state, vm),
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPaletteSelector(
    GameViewModelState state,
    GameViewModel vm,
  ) {
    final palette = state.level?.palette ?? [];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.bg,
            AppColors.bg.withValues(alpha: 0.95),
            AppColors.bg.withValues(alpha: 0.6),
            AppColors.bg.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.55, 0.8, 1.0],
        ),
      ),
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < palette.length; i++) ...[
            _buildColorToolButton(
              toolIndex: i + 1,
              color: palette[i],
              isSelected: state.selectedTool == (i + 1),
              onTap: () => vm.selectTool(i + 1),
            ),
            const SizedBox(width: 14),
          ],
          _buildCrossToolButton(
            isSelected: state.selectedTool == -1,
            onTap: () => vm.selectTool(-1),
          ),
        ],
      ),
    );
  }

  Widget _buildColorToolButton({
    required int toolIndex,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: isSelected ? 52 : 46,
        height: isSelected ? 52 : 46,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: isSelected ? 3.0 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: isSelected
            ? Center(
                child: Icon(
                  Icons.check_rounded,
                  color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  size: 24,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildCrossToolButton({
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: isSelected ? 52 : 46,
        height: isSelected ? 52 : 46,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : AppColors.border,
            width: isSelected ? 3.0 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.cellCross.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Icon(
            Icons.close_rounded,
            color: AppColors.cellCross,
            size: isSelected ? 26 : 22,
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionBottomPanel(
    BuildContext context,
    GameViewModelState state,
    GameViewModel vm,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.bg,
            AppColors.bg.withValues(alpha: 0.95),
            AppColors.bg.withValues(alpha: 0.6),
            AppColors.bg.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.55, 0.8, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'CONGRATULATIONS!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.headingDark,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          TangibleButton(
            text: widget.isRandom ? 'Play Again' : 'Next Level',
            height: 44,
            fontSize: 13,
            onPressed: () async {
              await vm.completeLevel();
              if (!context.mounted) return;
              if (widget.isRandom) {
                vm.loadRandomLevel(widget.randomDifficulty ?? 'Easy');
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GameView(levelNumber: widget.levelNumber + 1),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 8),
          TangibleButton(
            text: 'Home',
            isSecondary: true,
            icon: Icons.home_rounded,
            height: 44,
            fontSize: 13,
            onPressed: () async {
              await vm.completeLevel();
              if (!context.mounted) return;
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
          TangibleButton(
            text: 'Buy Me a Coffee',
            isSecondary: true,
            icon: Icons.coffee_rounded,
            height: 44,
            fontSize: 13,
            onPressed: () async {
              final Uri url = Uri.parse('https://ko-fi.com/sidhant947');
              if (!await launchUrl(
                url,
                mode: LaunchMode.externalApplication,
              )) {
                throw Exception('Could not launch $url');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    Color? iconColor,
  }) {
    final bool isDisabled = onPressed == null;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDisabled
                  ? AppColors.subtext.withValues(alpha: 0.4)
                  : (iconColor ?? AppColors.headingDark),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isDisabled
                    ? AppColors.subtext.withValues(alpha: 0.4)
                    : AppColors.headingDark,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClueBadge(
    ColorClue clue,
    List<Color> palette,
    double badgeSize, {
    bool isSatisfied = false,
  }) {
    final color = palette[clue.colorIndex - 1];
    final textColor = ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Opacity(
      opacity: isSatisfied ? 0.30 : 1.0,
      child: Container(
        width: badgeSize,
        height: badgeSize,
        margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          boxShadow: isSatisfied
              ? []
              : const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Text(
          '${clue.count}',
          style: TextStyle(
            fontSize: (badgeSize * 0.65).clamp(9.0, 16.0),
            fontWeight: FontWeight.w900,
            color: textColor,
            decoration: isSatisfied ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }

  Widget _buildColorgramGrid(
    BuildContext context,
    GameViewModelState state,
    GameViewModel vm,
  ) {
    final level = state.level!;
    final size = level.gridSize;

    final maxColClueLen = level.colClues
        .map((c) => c.length)
        .fold(1, (a, b) => a > b ? a : b);
    final maxRowClueLen = level.rowClues
        .map((r) => r.length)
        .fold(1, (a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availWidth = constraints.maxWidth;
        final availHeight = constraints.maxHeight;

        final double maxClueWidthRatio = 0.35;
        final double maxClueHeightRatio = 0.30;

        final estimatedCellSizeWidth =
            (availWidth * (1.0 - maxClueWidthRatio)) / size;
        final estimatedCellSizeHeight =
            (availHeight * (1.0 - maxClueHeightRatio)) / (size + 1);

        double cellSize =
            (estimatedCellSizeWidth < estimatedCellSizeHeight
                    ? estimatedCellSizeWidth
                    : estimatedCellSizeHeight)
                .floorToDouble();

        cellSize = cellSize.clamp(24.0, 68.0);
        final badgeSize = (cellSize * 0.72).clamp(16.0, 28.0);

        final rowClueWidth = (maxRowClueLen * (badgeSize + 4.0)).clamp(
          cellSize * 1.2,
          availWidth * maxClueWidthRatio,
        );
        final clueHeight = (maxColClueLen * (badgeSize + 4.0)).clamp(
          cellSize * 1.2,
          availHeight * maxClueHeightRatio,
        );

        return FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: Table(
            columnWidths: {
              0: FixedColumnWidth(rowClueWidth),
              for (int c = 0; c < size; c++) c + 1: FixedColumnWidth(cellSize),
            },
            children: [
              TableRow(
                children: [
                  const SizedBox.shrink(),
                  for (int c = 0; c < size; c++)
                    Builder(
                      builder: (context) {
                        final isColComplete = ColorgramRules.isColSatisfied(
                          state.board,
                          level.colClues[c],
                          c,
                        );
                        return Container(
                          height: clueHeight,
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.only(bottom: 4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: level.colClues[c]
                                  .map(
                                    (clue) => _buildClueBadge(
                                      clue,
                                      level.palette,
                                      badgeSize,
                                      isSatisfied: isColComplete,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),

              for (int r = 0; r < size; r++)
                TableRow(
                  children: [
                    Builder(
                      builder: (context) {
                        final isRowComplete = ColorgramRules.isRowSatisfied(
                          state.board[r],
                          level.rowClues[r],
                        );
                        return Container(
                          height: cellSize,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 6),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: level.rowClues[r]
                                  .map(
                                    (clue) => _buildClueBadge(
                                      clue,
                                      level.palette,
                                      badgeSize,
                                      isSatisfied: isRowComplete,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        );
                      },
                    ),

                    for (int c = 0; c < size; c++)
                      GestureDetector(
                        onTap: () {
                          vm.toggleCell(r, c);
                        },
                        onPanStart: (_) {
                          _lastDraggedCell = r * size + c;
                        },
                        onPanUpdate: (_) {
                          final cellId = r * size + c;
                          if (_lastDraggedCell != cellId) {
                            _lastDraggedCell = cellId;
                            vm.setCell(r, c, state.selectedTool);
                          }
                        },
                        onLongPress: ref.read(progressRepositoryProvider).longPressToCrossEnabled
                            ? () {
                                if (ref.read(progressRepositoryProvider).hapticsEnabled) {
                                  HapticFeedback.mediumImpact();
                                }
                                if (state.board[r][c] == -1) {
                                  vm.setCell(r, c, 0);
                                } else {
                                  vm.setCell(r, c, -1);
                                }
                              }
                            : null,
                        child: Container(
                          width: cellSize,
                          height: cellSize,
                          margin: const EdgeInsets.all(1.0),
                          decoration: BoxDecoration(
                            color: _getCellColor(r, c, state),
                            borderRadius: BorderRadius.circular(
                              size > 8 ? 4 : 6,
                            ),
                            border: Border.all(
                              color: state.hintCell == (r * size + c)
                                  ? AppColors.gold
                                  : AppColors.border,
                              width: state.hintCell == (r * size + c) ? 2.5 : 1,
                            ),
                          ),
                          child: _buildCellContent(state.board[r][c], cellSize),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getCellColor(int r, int c, GameViewModelState state) {
    final cellValue = state.board[r][c];
    if (cellValue > 0 && state.level != null && cellValue <= state.level!.palette.length) {
      return state.level!.palette[cellValue - 1];
    }
    return AppColors.surface;
  }

  Widget? _buildCellContent(int cellValue, double cellSize) {
    if (cellValue == -1) {
      return Icon(
        Icons.close_rounded,
        size: (cellSize * 0.65).clamp(12.0, 36.0),
        color: AppColors.cellCross,
      );
    }
    return null;
  }
}
