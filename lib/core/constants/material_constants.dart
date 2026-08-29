import 'package:flutter/material.dart';

/// Predefined standard construction material categories with default units & icons.
class MaterialCategoryPreset {
  final String name;
  final String defaultUnit;
  final IconData icon;
  final Color color;

  const MaterialCategoryPreset({
    required this.name,
    required this.defaultUnit,
    required this.icon,
    required this.color,
  });
}

/// Standard construction material categories
const List<MaterialCategoryPreset> kStandardMaterialCategories = [
  MaterialCategoryPreset(
    name: 'Cement',
    defaultUnit: 'Bags',
    icon: Icons.view_in_ar_rounded,
    color: Color(0xFF64748B),
  ),
  MaterialCategoryPreset(
    name: 'Steel / TMT / Rebar',
    defaultUnit: 'Tons',
    icon: Icons.fence_rounded,
    color: Color(0xFF334155),
  ),
  MaterialCategoryPreset(
    name: 'Metal / Blue Metal / Aggregates',
    defaultUnit: 'CFT',
    icon: Icons.landscape_rounded,
    color: Color(0xFF475569),
  ),
  MaterialCategoryPreset(
    name: 'Sand / M-Sand / River Sand',
    defaultUnit: 'CFT',
    icon: Icons.grain_rounded,
    color: Color(0xFFD97706),
  ),
  MaterialCategoryPreset(
    name: 'Bricks / Solid Blocks / AAC',
    defaultUnit: 'Nos',
    icon: Icons.square_foot_rounded,
    color: Color(0xFFDC2626),
  ),
  MaterialCategoryPreset(
    name: 'Tiles / Granite / Marble',
    defaultUnit: 'Sq.ft',
    icon: Icons.grid_view_rounded,
    color: Color(0xFF0284C7),
  ),
  MaterialCategoryPreset(
    name: 'Wood / Timber / Plywood',
    defaultUnit: 'CFT',
    icon: Icons.carpenter_rounded,
    color: Color(0xFF854D0E),
  ),
  MaterialCategoryPreset(
    name: 'Plumbing & Sanitaryware',
    defaultUnit: 'Nos',
    icon: Icons.plumbing_rounded,
    color: Color(0xFF0D9488),
  ),
  MaterialCategoryPreset(
    name: 'Electrical & Cabling',
    defaultUnit: 'Meters',
    icon: Icons.electrical_services_rounded,
    color: Color(0xFFEAB308),
  ),
  MaterialCategoryPreset(
    name: 'Paint & Putty & Chemicals',
    defaultUnit: 'Litres',
    icon: Icons.format_paint_rounded,
    color: Color(0xFF9333EA),
  ),
  MaterialCategoryPreset(
    name: 'RMC (Ready Mix Concrete)',
    defaultUnit: 'Cu.m',
    icon: Icons.local_shipping_rounded,
    color: Color(0xFF2563EB),
  ),
  MaterialCategoryPreset(
    name: 'Hardware & Fasteners',
    defaultUnit: 'Nos',
    icon: Icons.hardware_rounded,
    color: Color(0xFF4F46E5),
  ),
  MaterialCategoryPreset(
    name: 'General Material',
    defaultUnit: 'Nos',
    icon: Icons.inventory_2_rounded,
    color: Color(0xFF6B7280),
  ),
];
