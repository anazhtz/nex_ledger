import 'package:nex_ledger/core/database/daos/purchase_dao.dart';

/// Represents a distinct material item consumed in a project with all-time inward deliveries.
class ProjectMaterialItem {
  final String itemDescription;
  final String materialCategory;
  final double totalQuantity;
  final String unit;
  final double avgUnitRate;
  final double totalAmount;
  final int inwardCount;
  final DateTime? lastDeliveryDate;
  final String? primaryVendor;
  final List<PurchaseDetail> deliveryHistory;

  const ProjectMaterialItem({
    required this.itemDescription,
    required this.materialCategory,
    required this.totalQuantity,
    required this.unit,
    required this.avgUnitRate,
    required this.totalAmount,
    required this.inwardCount,
    this.lastDeliveryDate,
    this.primaryVendor,
    required this.deliveryHistory,
  });
}

/// Aggregated project material register summary.
class ProjectMaterialSummary {
  final int? projectId;
  final String projectName;
  final String? projectCode;
  final String? clientName;
  final double totalMaterialSpend;
  final int totalDeliveriesCount;
  final int totalCategoriesCount;
  final int totalDistinctItemsCount;
  final List<ProjectMaterialItem> items;

  const ProjectMaterialSummary({
    this.projectId,
    required this.projectName,
    this.projectCode,
    this.clientName,
    required this.totalMaterialSpend,
    required this.totalDeliveriesCount,
    required this.totalCategoriesCount,
    required this.totalDistinctItemsCount,
    required this.items,
  });
}
