import 'package:flutter/material.dart';

/// Predefined standard construction material categories with default units, icons, and quick-select item presets.
class MaterialCategoryPreset {
  final String name;
  final String defaultUnit;
  final IconData icon;
  final Color color;
  final List<String> commonItems;

  const MaterialCategoryPreset({
    required this.name,
    required this.defaultUnit,
    required this.icon,
    required this.color,
    this.commonItems = const [],
  });
}

/// Standard construction material categories with 1-click selectable item presets
const List<MaterialCategoryPreset> kStandardMaterialCategories = [
  MaterialCategoryPreset(
    name: 'Cement',
    defaultUnit: 'Bags',
    icon: Icons.view_in_ar_rounded,
    color: Color(0xFF64748B),
    commonItems: [
      'UltraTech OPC 53 Grade',
      'PPC 43 Grade Cement',
      'Dalmia DSP Cement',
      'Birla Super 53 Grade',
      'ACC Gold Cement',
      'White Cement 50kg',
    ],
  ),
  MaterialCategoryPreset(
    name: 'Steel / TMT / Rebar',
    defaultUnit: 'Tons',
    icon: Icons.fence_rounded,
    color: Color(0xFF334155),
    commonItems: [
      '8mm Fe550D TMT Rebar',
      '10mm Fe550D TMT Rebar',
      '12mm Fe550D TMT Rebar',
      '16mm Fe550D TMT Rebar',
      '20mm Fe550D TMT Rebar',
      '25mm Fe550D TMT Rebar',
      'Binding Wire 18 Gauge',
      'MS Angles & Channels',
    ],
  ),
  MaterialCategoryPreset(
    name: 'Metal / Blue Metal / Aggregates',
    defaultUnit: 'CFT',
    icon: Icons.landscape_rounded,
    color: Color(0xFF475569),
    commonItems: [
      '20mm Blue Metal Aggregates',
      '40mm Blue Metal Aggregates',
      '12mm Aggregates',
      '6mm Stone Dust / Chips',
      'Wet Mix Macadam (WMM)',
      'Granular Sub-Base (GSB)',
      'Rubble / Quarry Stone',
    ],
  ),
  MaterialCategoryPreset(
    name: 'Sand / M-Sand / River Sand',
    defaultUnit: 'CFT',
    icon: Icons.grain_rounded,
    color: Color(0xFFD97706),
    commonItems: [
      'M-Sand (Manufactured Concrete Sand)',
      'P-Sand (Plastering Sand)',
      'Natural River Sand',
      'Red Earth / Filling Soil',
      'Gravel / Quarry Dust',
    ],
  ),
  MaterialCategoryPreset(
    name: 'Bricks / Solid Blocks / AAC',
    defaultUnit: 'Nos',
    icon: Icons.square_foot_rounded,
    color: Color(0xFFDC2626),
    commonItems: [
      'Wirecut Red Clay Bricks',
      'AAC Lightweight Blocks 6"',
      'AAC Lightweight Blocks 8"',
      'Concrete Solid Blocks 6"',
      'Concrete Solid Blocks 4"',
      'Fly Ash Bricks',
      'Hollow Concrete Blocks',
    ],
  ),
  MaterialCategoryPreset(
    name: 'RMC (Ready Mix Concrete)',
    defaultUnit: 'Cu.m',
    icon: Icons.local_shipping_rounded,
    color: Color(0xFF2563EB),
    commonItems: [
      'RMC M20 Grade Concrete',
      'RMC M25 Grade Concrete',
      'RMC M30 Grade Concrete',
      'RMC M35 Grade Concrete',
      'Self-Compacting Concrete (SCC)',
      'Concrete Boom Pump Charge',
    ],
  ),
  MaterialCategoryPreset(
    name: 'Tiles / Granite / Marble',
    defaultUnit: 'Sq.ft',
    icon: Icons.grid_view_rounded,
    color: Color(0xFF0284C7),
    commonItems: [
      'Vitrified Floor Tiles 2x2',
      'Vitrified Floor Tiles 4x2',
      'Bathroom Ceramic Wall Tiles',
      'Kitchen Black Granite Slab',
      'Kota Stone Slabs',
      'Italian Marble Slabs',
      'Tile Adhesive (Roff / Saint-Gobain)',
      'Epoxy Tile Grout',
    ],
  ),
  MaterialCategoryPreset(
    name: 'Plumbing & Sanitaryware',
    defaultUnit: 'Nos',
    icon: Icons.plumbing_rounded,
    color: Color(0xFF0D9488),
    commonItems: [
      'CPVC Pipe 1" (SDR 11)',
      'CPVC Pipe 3/4" (SDR 11)',
      'UPVC Drainage Pipe 4"',
      'SWR PVC Drainage Pipe 110mm',
      'CPVC Brass Elbows & Tees',
      'Wall Concealed Mixer & Spout',
      'European Water Closet (EWC) Set',
      'Overhead PVC Water Tank 1000L',
    ],
  ),
  MaterialCategoryPreset(
    name: 'Electrical & Cabling',
    defaultUnit: 'Meters',
    icon: Icons.electrical_services_rounded,
    color: Color(0xFFEAB308),
    commonItems: [
      '1.5 sq mm FR Copper Wire',
      '2.5 sq mm FR Power Wire',
      '4.0 sq mm AC Heavy Wire',
      'PVC Heavy Conduit Pipes 25mm',
      'Modular Switch 6M/8M Metal Box',
      '10kA Double Pole MCB',
      'LED Recessed Panel Downlights',
      'Armoured UG Cable 4 Core',
    ],
  ),
  MaterialCategoryPreset(
    name: 'Paint & Putty & Chemicals',
    defaultUnit: 'Litres',
    icon: Icons.format_paint_rounded,
    color: Color(0xFF9333EA),
    commonItems: [
      'Birla White Wall Putty 40kg',
      'Interior Water-Based Primer',
      'Exterior Weatherproof Emulsion',
      'Premium Interior Emulsion',
      'Dr. Fixit Super Latexp Waterproofing',
      'Epoxy Floor Coating',
      'Synthetic Enamel Paint for Grills',
    ],
  ),
  MaterialCategoryPreset(
    name: 'Wood / Timber / Plywood',
    defaultUnit: 'CFT',
    icon: Icons.carpenter_rounded,
    color: Color(0xFF854D0E),
    commonItems: [
      'Teak Wood Main Door Frame',
      'Commercial BWP Plywood 18mm',
      'Commercial MR Plywood 12mm',
      'Laminated Flush Doors',
      'Film-Faced Shuttering Plywood',
      'Wood Adhesive (Fevicol SH)',
    ],
  ),
  MaterialCategoryPreset(
    name: 'Hardware & Fasteners',
    defaultUnit: 'Nos',
    icon: Icons.hardware_rounded,
    color: Color(0xFF4F46E5),
    commonItems: [
      'M12 Heavy Anchor Fasteners',
      'SS 304 Grade Door Hinges & Mortise Lock',
      'SS Tower Bolts & Handles',
      'Self-Tapping Drywall Screws',
      'Steel Wire Nails 2"/3"',
    ],
  ),
  MaterialCategoryPreset(
    name: 'General Material',
    defaultUnit: 'Nos',
    icon: Icons.inventory_2_rounded,
    color: Color(0xFF6B7280),
    commonItems: [
      'Safety Helmets & Reflective Vests',
      'Curing Gunny Hessian Bags',
      'Heavy Duty Tarpaulin Sheet 24x18',
      'Site Construction Water Tanker 6000L',
      'Diesel for Site Generator & JCB',
      'Site Barricading Tape & Caution Boards',
    ],
  ),
];
