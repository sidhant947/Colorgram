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

  static final List<GameLevel> _handcraftedLevels = [
    _buildHandcrafted(
      number: 1,
      name: 'CHERRY',
      size: 5,
      palette: const [Color(0xFF4CAF50), Color(0xFFE53935)],
      grid: [
        [0, 1, 0, 1, 0],
        [0, 1, 0, 1, 0],
        [0, 0, 1, 0, 0],
        [2, 2, 0, 2, 2],
        [2, 2, 0, 2, 2],
      ],
    ),
    _buildHandcrafted(
      number: 2,
      name: 'HEART',
      size: 5,
      palette: const [Color(0xFFEF233C), Color(0xFFFF758F)],
      grid: [
        [1, 0, 0, 0, 1],
        [1, 1, 0, 1, 1],
        [0, 1, 0, 1, 0],
        [0, 2, 2, 2, 0],
        [0, 0, 2, 0, 0],
      ],
    ),
    _buildHandcrafted(
      number: 3,
      name: 'MUSHROOM',
      size: 5,
      palette: const [Color(0xFFE63946), Color(0xFFF4A261)],
      grid: [
        [0, 1, 1, 1, 0],
        [1, 1, 1, 1, 1],
        [0, 0, 0, 0, 0],
        [0, 2, 2, 2, 0],
        [0, 2, 2, 2, 0],
      ],
    ),
    _buildHandcrafted(
      number: 4,
      name: 'SAILBOAT',
      size: 5,
      palette: const [Color(0xFFE0E1DD), Color(0xFF1D3557)],
      grid: [
        [0, 0, 1, 0, 0],
        [0, 1, 1, 0, 0],
        [1, 1, 1, 0, 0],
        [0, 0, 0, 0, 0],
        [2, 2, 2, 2, 2],
      ],
    ),
    _buildHandcrafted(
      number: 5,
      name: 'DUCK',
      size: 5,
      palette: const [Color(0xFFFFD166), Color(0xFFF77F00)],
      grid: [
        [0, 1, 1, 0, 2],
        [0, 1, 1, 0, 0],
        [0, 0, 0, 0, 0],
        [1, 1, 1, 1, 0],
        [0, 1, 1, 0, 0],
      ],
    ),
    _buildHandcrafted(
      number: 6,
      name: 'COFFEE',
      size: 6,
      palette: const [Color(0xFF8B5E3C), Color(0xFF48CAE4)],
      grid: [
        [0, 2, 0, 2, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [1, 1, 1, 1, 0, 1],
        [1, 1, 1, 1, 0, 1],
        [1, 1, 1, 1, 0, 0],
        [0, 1, 1, 0, 0, 0],
      ],
    ),
    _buildHandcrafted(
      number: 7,
      name: 'FLOWER',
      size: 6,
      palette: const [Color(0xFFFFD166), Color(0xFF9B5DE5), Color(0xFF2A9D8F)],
      grid: [
        [0, 2, 0, 0, 2, 0],
        [2, 0, 1, 1, 0, 2],
        [0, 2, 0, 0, 2, 0],
        [0, 0, 3, 0, 0, 0],
        [0, 3, 3, 0, 0, 0],
        [0, 0, 3, 0, 0, 0],
      ],
    ),
    _buildHandcrafted(
      number: 8,
      name: 'CROWN',
      size: 6,
      palette: const [Color(0xFFFFB703), Color(0xFFD90429)],
      grid: [
        [2, 0, 2, 0, 2, 0],
        [1, 0, 1, 0, 1, 0],
        [1, 1, 1, 1, 1, 0],
        [0, 0, 0, 0, 0, 0],
        [1, 1, 1, 1, 1, 0],
        [0, 2, 0, 2, 0, 0],
      ],
    ),
    _buildHandcrafted(
      number: 9,
      name: 'TREE',
      size: 6,
      palette: const [Color(0xFF38B000), Color(0xFF7F4F24)],
      grid: [
        [0, 0, 1, 1, 0, 0],
        [0, 1, 1, 1, 1, 0],
        [1, 1, 1, 1, 1, 1],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 2, 2, 0, 0],
        [0, 0, 2, 2, 0, 0],
      ],
    ),
    _buildHandcrafted(
      number: 10,
      name: 'FISH',
      size: 6,
      palette: const [Color(0xFFFB8500), Color(0xFF219EBC)],
      grid: [
        [0, 0, 1, 1, 0, 2],
        [0, 1, 1, 1, 0, 2],
        [1, 1, 1, 1, 0, 2],
        [0, 1, 1, 1, 0, 2],
        [0, 0, 1, 1, 0, 2],
        [0, 0, 0, 0, 0, 0],
      ],
    ),
    _buildHandcrafted(
      number: 11,
      name: 'ROCKET',
      size: 7,
      palette: const [Color(0xFFEF233C), Color(0xFFEDF2F4), Color(0xFFFF7900)],
      grid: [
        [0, 0, 0, 1, 0, 0, 0],
        [0, 0, 1, 1, 1, 0, 0],
        [0, 0, 2, 2, 2, 0, 0],
        [0, 0, 2, 2, 2, 0, 0],
        [0, 1, 0, 2, 0, 1, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 3, 0, 0, 0],
      ],
    ),
    _buildHandcrafted(
      number: 12,
      name: 'SWORD',
      size: 7,
      palette: const [Color(0xFF00B4D8), Color(0xFFFFB703), Color(0xFFD90429)],
      grid: [
        [0, 0, 0, 0, 0, 0, 1],
        [0, 0, 0, 0, 0, 1, 0],
        [0, 0, 0, 0, 1, 0, 0],
        [0, 0, 0, 1, 0, 0, 0],
        [0, 2, 2, 0, 0, 0, 0],
        [0, 0, 3, 2, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
      ],
    ),
    _buildHandcrafted(
      number: 13,
      name: 'HOUSE',
      size: 7,
      palette: const [Color(0xFFE63946), Color(0xFFF4A261), Color(0xFF457B9D)],
      grid: [
        [0, 0, 0, 1, 0, 0, 0],
        [0, 0, 1, 1, 1, 0, 0],
        [0, 1, 1, 1, 1, 1, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 2, 0, 3, 0, 2, 0],
        [0, 2, 0, 3, 0, 2, 0],
        [0, 2, 2, 2, 2, 2, 0],
      ],
    ),
    _buildHandcrafted(
      number: 14,
      name: 'CACTUS',
      size: 7,
      palette: const [Color(0xFF2A9D8F), Color(0xFFE9C46A)],
      grid: [
        [0, 0, 0, 1, 0, 0, 0],
        [0, 1, 0, 1, 0, 0, 0],
        [0, 1, 1, 1, 0, 1, 0],
        [0, 0, 0, 1, 1, 1, 0],
        [0, 0, 0, 1, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0],
        [0, 2, 2, 2, 2, 2, 0],
      ],
    ),
    _buildHandcrafted(
      number: 15,
      name: 'DIAMOND',
      size: 7,
      palette: const [Color(0xFF48CAE4), Color(0xFF023E8A)],
      grid: [
        [0, 0, 0, 1, 0, 0, 0],
        [0, 0, 1, 0, 1, 0, 0],
        [0, 1, 0, 2, 0, 1, 0],
        [1, 0, 2, 2, 2, 0, 1],
        [0, 1, 0, 2, 0, 1, 0],
        [0, 0, 1, 0, 1, 0, 0],
        [0, 0, 0, 1, 0, 0, 0],
      ],
    ),
    _buildHandcrafted(
      number: 16,
      name: 'SHIELD',
      size: 8,
      palette: const [Color(0xFFFFB703), Color(0xFF1D3557)],
      grid: [
        [0, 1, 1, 1, 1, 1, 1, 0],
        [1, 2, 2, 0, 0, 2, 2, 1],
        [1, 2, 2, 0, 0, 2, 2, 1],
        [1, 0, 0, 2, 2, 0, 0, 1],
        [0, 1, 2, 2, 2, 2, 1, 0],
        [0, 0, 1, 2, 2, 1, 0, 0],
        [0, 0, 0, 1, 1, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0],
      ],
    ),
    _buildHandcrafted(
      number: 17,
      name: 'BUTTERFLY',
      size: 8,
      palette: const [Color(0xFF9B5DE5), Color(0xFF00F5D4)],
      grid: [
        [1, 1, 0, 2, 2, 0, 1, 1],
        [1, 0, 1, 0, 0, 1, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 1],
        [0, 1, 1, 0, 0, 1, 1, 0],
        [0, 2, 0, 0, 0, 0, 2, 0],
        [0, 1, 2, 0, 0, 2, 1, 0],
        [0, 0, 1, 0, 0, 1, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0],
      ],
    ),
    _buildHandcrafted(
      number: 18,
      name: 'APPLE',
      size: 8,
      palette: const [Color(0xFF06D6A0), Color(0xFFEF233C)],
      grid: [
        [0, 0, 0, 0, 1, 1, 0, 0],
        [0, 0, 0, 1, 0, 0, 0, 0],
        [0, 2, 2, 0, 2, 2, 0, 0],
        [2, 2, 2, 2, 2, 2, 2, 0],
        [2, 2, 2, 2, 2, 2, 2, 0],
        [2, 2, 2, 2, 2, 2, 2, 0],
        [0, 2, 2, 2, 2, 2, 0, 0],
        [0, 0, 2, 0, 2, 0, 0, 0],
      ],
    ),
    _buildHandcrafted(
      number: 19,
      name: 'POTION',
      size: 8,
      palette: const [Color(0xFFD4A373), Color(0xFF7209B7)],
      grid: [
        [0, 0, 0, 1, 1, 0, 0, 0],
        [0, 0, 0, 1, 1, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 1, 1, 1, 0, 0],
        [0, 1, 2, 2, 2, 2, 1, 0],
        [1, 2, 2, 2, 2, 2, 2, 1],
        [1, 2, 2, 2, 2, 2, 2, 1],
        [0, 1, 1, 1, 1, 1, 1, 0],
      ],
    ),
    _buildHandcrafted(
      number: 20,
      name: 'GHOST',
      size: 8,
      palette: const [Color(0xFFF8F9FA), Color(0xFF1D3557)],
      grid: [
        [0, 0, 1, 1, 1, 1, 0, 0],
        [0, 1, 1, 1, 1, 1, 1, 0],
        [1, 1, 2, 1, 1, 2, 1, 1],
        [1, 1, 2, 1, 1, 2, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 2, 2, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 0, 1, 0, 0, 1, 0, 1],
      ],
    ),
  ];

  static final Map<int, List<GameLevel>> _catalogByGridSize = {
    8: [
      _handcraftedLevels[15],
      _handcraftedLevels[16],
      _handcraftedLevels[17],
      _handcraftedLevels[18],
      _handcraftedLevels[19],
    ],
    10: [
      _buildHandcrafted(
        number: 101,
        name: 'CASTLE',
        size: 10,
        palette: const [Color(0xFF90A4AE), Color(0xFFEF5350), Color(0xFF1E88E5)],
        grid: [
          [1, 0, 1, 0, 2, 2, 0, 1, 0, 1],
          [1, 1, 1, 0, 2, 2, 0, 1, 1, 1],
          [1, 1, 1, 0, 1, 1, 0, 1, 1, 1],
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
          [1, 3, 1, 1, 1, 1, 1, 1, 3, 1],
          [1, 3, 1, 0, 3, 3, 0, 1, 3, 1],
          [1, 1, 1, 0, 3, 3, 0, 1, 1, 1],
          [1, 1, 1, 0, 3, 3, 0, 1, 1, 1],
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        ],
      ),
      _buildHandcrafted(
        number: 102,
        name: 'SPACESHIP',
        size: 10,
        palette: const [Color(0xFF00B4D8), Color(0xFFFFB703), Color(0xFFF72585)],
        grid: [
          [0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
          [0, 0, 0, 1, 2, 2, 1, 0, 0, 0],
          [0, 0, 1, 1, 2, 2, 1, 1, 0, 0],
          [0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
          [0, 1, 1, 1, 1, 1, 1, 1, 1, 0],
          [1, 1, 0, 1, 1, 1, 1, 0, 1, 1],
          [1, 0, 0, 1, 1, 1, 1, 0, 0, 1],
          [0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 3, 0, 0, 3, 0, 0, 0],
        ],
      ),
      _buildHandcrafted(
        number: 103,
        name: 'LIGHTHOUSE',
        size: 10,
        palette: const [Color(0xFFE63946), Color(0xFFF1FAEE), Color(0xFFFFD166)],
        grid: [
          [0, 0, 0, 0, 3, 3, 0, 0, 0, 0],
          [0, 0, 0, 3, 2, 2, 3, 0, 0, 0],
          [0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
          [0, 0, 0, 0, 2, 2, 0, 0, 0, 0],
          [0, 0, 0, 1, 1, 1, 1, 0, 0, 0],
          [0, 0, 0, 2, 2, 2, 2, 0, 0, 0],
          [0, 0, 1, 1, 1, 1, 1, 1, 0, 0],
          [0, 0, 2, 2, 2, 2, 2, 2, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        ],
      ),
      _buildHandcrafted(
        number: 104,
        name: 'SWORD_SHIELD',
        size: 10,
        palette: const [Color(0xFFCFD8DC), Color(0xFFFFB300), Color(0xFF0288D1)],
        grid: [
          [0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
          [0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
          [0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
          [0, 2, 2, 2, 2, 2, 2, 2, 2, 0],
          [0, 0, 0, 0, 2, 2, 0, 0, 0, 0],
          [0, 0, 0, 3, 3, 3, 3, 0, 0, 0],
          [0, 0, 3, 3, 2, 2, 3, 3, 0, 0],
          [0, 0, 3, 3, 2, 2, 3, 3, 0, 0],
          [0, 0, 0, 3, 3, 3, 3, 0, 0, 0],
          [0, 0, 0, 0, 3, 3, 0, 0, 0, 0],
        ],
      ),
    ],
    12: [
      _buildHandcrafted(
        number: 201,
        name: 'GALLEON',
        size: 12,
        palette: const [Color(0xFF8D6E63), Color(0xFFECEFF1), Color(0xFF0288D1)],
        grid: [
          [0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 2, 2, 0, 0, 2, 0, 0, 0, 0],
          [0, 0, 2, 2, 2, 0, 2, 2, 0, 0, 0, 0],
          [0, 2, 2, 2, 2, 0, 2, 2, 2, 0, 0, 0],
          [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0],
          [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0],
          [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
          [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
          [0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
          [0, 3, 3, 0, 3, 3, 0, 3, 3, 0, 3, 3],
        ],
      ),
      _buildHandcrafted(
        number: 202,
        name: 'PHOENIX',
        size: 12,
        palette: const [Color(0xFFD00000), Color(0xFFFF7900), Color(0xFFFFBA08)],
        grid: [
          [0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 1, 3, 3, 1, 0, 0, 0, 0],
          [1, 0, 0, 1, 1, 2, 2, 1, 1, 0, 0, 1],
          [1, 1, 0, 2, 2, 2, 2, 2, 2, 0, 1, 1],
          [0, 1, 2, 2, 3, 3, 3, 3, 2, 2, 1, 0],
          [0, 0, 1, 2, 3, 2, 2, 3, 2, 1, 0, 0],
          [0, 0, 0, 1, 2, 2, 2, 2, 1, 0, 0, 0],
          [0, 0, 0, 0, 1, 2, 2, 1, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 2, 3, 3, 2, 0, 0, 0, 0],
          [0, 0, 0, 2, 0, 0, 0, 0, 2, 0, 0, 0],
          [0, 0, 2, 0, 0, 0, 0, 0, 0, 2, 0, 0],
        ],
      ),
      _buildHandcrafted(
        number: 203,
        name: 'TEMPLE',
        size: 12,
        palette: const [Color(0xFFD4A373), Color(0xFFB7094C), Color(0xFF0077B6)],
        grid: [
          [0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 2, 2, 2, 2, 0, 0, 0, 0],
          [0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0],
          [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
          [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
          [0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0],
          [0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0],
          [0, 0, 1, 0, 1, 3, 3, 1, 0, 1, 0, 0],
          [0, 0, 1, 0, 1, 3, 3, 1, 0, 1, 0, 0],
          [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        ],
      ),
    ],
  };

  static GameLevel _buildHandcrafted({
    required int number,
    required String name,
    required int size,
    required List<Color> palette,
    required List<List<int>> grid,
  }) {
    final rowClues = ColorgramRules.computeRowClues(grid, size);
    final colClues = ColorgramRules.computeColClues(grid, size);
    return GameLevel(
      levelNumber: number,
      name: name,
      gridSize: size,
      palette: palette,
      solutionGrid: grid,
      rowClues: rowClues,
      colClues: colClues,
    );
  }

  static GameLevel _getHandcraftedForGridSize(int targetSize, int seed) {
    List<GameLevel>? list = _catalogByGridSize[targetSize];
    if (list == null || list.isEmpty) {
      int closestSize = 5;
      for (final s in [5, 6, 7, 8, 10, 12]) {
        if ((s - targetSize).abs() < (closestSize - targetSize).abs()) {
          closestSize = s;
        }
      }
      if (closestSize == 5) {
        list = _handcraftedLevels.sublist(0, 5);
      } else if (closestSize == 6) {
        list = _handcraftedLevels.sublist(5, 10);
      } else if (closestSize == 7) {
        list = _handcraftedLevels.sublist(10, 15);
      } else {
        list = _catalogByGridSize[closestSize] ?? _handcraftedLevels.sublist(0, 5);
      }
    }

    final template = list[seed.abs() % list.length];
    final palIdx = seed.abs() % _palettes.length;
    final selectedPalette = _palettes[palIdx];
    final newPalette = selectedPalette.sublist(0, min(template.palette.length, selectedPalette.length));

    return GameLevel(
      levelNumber: -1,
      name: template.name,
      gridSize: template.gridSize,
      palette: newPalette,
      solutionGrid: template.solutionGrid,
      rowClues: template.rowClues,
      colClues: template.colClues,
    );
  }

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
    if (levelNumber >= 1 && levelNumber <= _handcraftedLevels.length) {
      return _handcraftedLevels[levelNumber - 1];
    }

    final gridSize = _getGridSize(levelNumber);
    final colorCount = _getColorCount(levelNumber);
    final paletteIndex = (levelNumber - 1).abs() % _palettes.length;
    final selectedPalette = _palettes[paletteIndex];
    final palette = selectedPalette.sublist(0, min(colorCount, selectedPalette.length));
    return _generateProceduralLevel(
      levelNumber: levelNumber,
      name: 'PUZZLE $levelNumber',
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
    if (gridSize > 8) {
      final fallbackSeed = seedOverride ?? (levelNumber * 31337);
      return _getHandcraftedForGridSize(gridSize, fallbackSeed);
    }

    int seedOffset = 0;
    final colorCount = palette.length;
    int attempts = 0;

    while (attempts < 20) {
      attempts++;
      final seed = seedOverride != null
          ? (seedOverride + seedOffset) & 0x7FFFFFFF
          : ((levelNumber * 31337 + seedOffset * 7919) & 0x7FFFFFFF);
      seedOffset++;
      final random = Random(seed);

      final half = (gridSize / 2).ceil();
      final grid = List.generate(
        gridSize,
        (_) => List<int>.filled(gridSize, 0),
      );

      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < half; c++) {
          if (random.nextDouble() < 0.50) {
            final color = 1 + random.nextInt(colorCount);
            grid[r][c] = color;
            grid[r][gridSize - 1 - c] = color;
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

      if (valid && _countSolutions(gridSize, rowClues, colClues) == 1) {
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
    }

    final fallbackSeed = seedOverride ?? (levelNumber * 31337);
    return _getHandcraftedForGridSize(gridSize, fallbackSeed);
  }

  int _countSolutions(
    int size,
    List<List<ColorClue>> rowClues,
    List<List<ColorClue>> colClues,
  ) {
    if (size > 8) return 0;

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
    while (changed) {
      changed = false;
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
        len += 1 + minSuffixLengths[i + 1];
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

      for (int start = currentPos; start <= maxStart; start++) {
        for (int i = start; i < start + blockLen; i++) {
          line[i] = color;
        }

        final nextPos = start + blockLen + 1;
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
