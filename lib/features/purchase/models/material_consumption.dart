/// Represents aggregated consumption metrics for a specific material category within a project.
class MaterialConsumptionSummary {
  final String categoryName;
  final double totalQuantity;
  final String unit;
  final double totalAmount;
  final double avgUnitRate;
  final int billCount;
  final DateTime? lastPurchaseDate;
  final String? lastVendorName;

  MaterialConsumptionSummary({
    required this.categoryName,
    required this.totalQuantity,
    required this.unit,
    required this.totalAmount,
    required this.avgUnitRate,
    required this.billCount,
    this.lastPurchaseDate,
    this.lastVendorName,
  });
}
