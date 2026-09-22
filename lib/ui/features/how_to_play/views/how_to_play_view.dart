import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HowToPlayView extends StatelessWidget {
  const HowToPlayView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'HOW TO PLAY',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.headingDark,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.headingDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          children: [
            _buildRuleSection(
              number: '01',
              title: 'COLOR CLUES',
              description:
                  'Numbers indicate consecutive blocks of that color in the row or column. They must appear in the exact order shown.',
              demo: _buildClueDemo(),
            ),
            _buildDivider(),
            _buildRuleSection(
              number: '02',
              title: 'SAME COLOR GAP',
              description:
                  'Consecutive blocks of the SAME color must be separated by at least one empty square (X).',
              caption: 'AT LEAST 1 SPACE BETWEEN SAME COLORS',
              captionColor: AppColors.accent,
              demo: _buildSameColorDemo(),
            ),
            _buildDivider(),
            _buildRuleSection(
              number: '03',
              title: 'DIFFERENT COLORS',
              description:
                  'Blocks of DIFFERENT colors can touch each other directly without any empty spaces in between.',
              caption: 'NO SPACE REQUIRED BETWEEN DIFFERENT COLORS',
              captionColor: const Color(0xFF81C784),
              demo: _buildDiffColorDemo(),
            ),
            _buildDivider(),
            _buildRuleSection(
              number: '04',
              title: 'PALETTE & CROSSES',
              description:
                  'Select a color from the bottom bar to paint cells. Select "X" to mark cells you know must stay blank.',
              demo: _buildPaletteDemo(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Divider(
        color: AppColors.border.withValues(alpha: 0.25),
        height: 1,
      ),
    );
  }

  Widget _buildRuleSection({
    required String number,
    required String title,
    required String description,
    required Widget demo,
    String? caption,
    Color? captionColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.accent,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.headingDark,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.subtext,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: demo,
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              caption,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: captionColor ?? AppColors.subtext,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildClueDemo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPill('2', const Color(0xFFEF5350)),
        const SizedBox(width: 6),
        _buildPill('1', const Color(0xFF42A5F5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(Icons.arrow_forward_rounded, color: AppColors.subtext.withValues(alpha: 0.6), size: 18),
        ),
        _buildCell(color: const Color(0xFFEF5350)),
        _buildCell(color: const Color(0xFFEF5350)),
        _buildCell(isCross: true),
        _buildCell(color: const Color(0xFF42A5F5)),
        _buildCell(isCross: true),
      ],
    );
  }

  Widget _buildSameColorDemo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPill('2', const Color(0xFF66BB6A)),
        const SizedBox(width: 6),
        _buildPill('1', const Color(0xFF66BB6A)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(Icons.arrow_forward_rounded, color: AppColors.subtext.withValues(alpha: 0.6), size: 18),
        ),
        _buildCell(color: const Color(0xFF66BB6A)),
        _buildCell(color: const Color(0xFF66BB6A)),
        _buildCell(isCross: true, isAccent: true),
        _buildCell(color: const Color(0xFF66BB6A)),
      ],
    );
  }

  Widget _buildDiffColorDemo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPill('2', const Color(0xFFEF5350)),
        const SizedBox(width: 6),
        _buildPill('2', const Color(0xFFFFEE58), textColor: Colors.black87),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(Icons.arrow_forward_rounded, color: AppColors.subtext.withValues(alpha: 0.6), size: 18),
        ),
        _buildCell(color: const Color(0xFFEF5350)),
        _buildCell(color: const Color(0xFFEF5350)),
        _buildCell(color: const Color(0xFFFFEE58)),
        _buildCell(color: const Color(0xFFFFEE58)),
      ],
    );
  }

  Widget _buildPaletteDemo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPaletteButton(
          child: const Icon(Icons.close_rounded, color: Color(0xFFEF5350), size: 20),
          label: 'MARK X',
          isSelected: false,
        ),
        const SizedBox(width: 20),
        _buildPaletteButton(
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Color(0xFFEF5350),
              shape: BoxShape.circle,
            ),
          ),
          label: 'RED',
          isSelected: true,
        ),
        const SizedBox(width: 20),
        _buildPaletteButton(
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Color(0xFF42A5F5),
              shape: BoxShape.circle,
            ),
          ),
          label: 'BLUE',
          isSelected: false,
        ),
      ],
    );
  }

  Widget _buildPaletteButton({
    required Widget child,
    required String label,
    required bool isSelected,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.border,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: child,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isSelected ? AppColors.accent : AppColors.subtext,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPill(String text, Color color, {Color textColor = Colors.white}) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildCell({
    Color? color,
    bool isCross = false,
    bool isAccent = false,
  }) {
    return Container(
      width: 26,
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isAccent ? AppColors.accent : AppColors.border,
          width: isAccent ? 1.5 : 0.8,
        ),
      ),
      child: isCross
          ? Icon(
              Icons.close_rounded,
              color: isAccent ? AppColors.accent : const Color(0xFFEF5350),
              size: 16,
            )
          : null,
    );
  }
}
