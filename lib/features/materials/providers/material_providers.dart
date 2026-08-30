import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/database/daos/purchase_dao.dart';
import 'package:nex_ledger/features/materials/models/project_material_entry.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_providers.dart';

/// Currently selected project in the Material Register screen.
final materialSelectedProjectIdProvider = StateProvider<int?>((ref) => null);

/// Search filter query for material description or brand.
final materialSearchQueryProvider = StateProvider<String>((ref) => '');

/// Optional date range filter for material deliveries.
final materialDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Optional category filter (e.g. Cement, Steel, Sand, etc.).
final materialSelectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Reactive stream provider that aggregates material quantities and deliveries for the selected project.
final projectMaterialSummaryProvider =
    StreamProvider<ProjectMaterialSummary>((ref) {
  final repo = ref.watch(purchaseRepositoryProvider);
  final selectedProjectId = ref.watch(materialSelectedProjectIdProvider);
  final projectsAsync = ref.watch(projectListProvider);
  final searchQuery = ref.watch(materialSearchQueryProvider).trim().toLowerCase();
  final dateRange = ref.watch(materialDateRangeProvider);
  final selectedCategory = ref.watch(materialSelectedCategoryProvider);

  // Watch purchase details from DB
  final baseStream = selectedProjectId != null
      ? repo.watchPurchasesByProject(selectedProjectId)
      : repo.watchAllPurchases();

  return baseStream.map((allPurchases) {
    // 1. Filter by date range
    var filtered = allPurchases;
    if (dateRange != null) {
      filtered = filtered.where((p) {
        final d = p.transaction.date;
        return d.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
            d.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
    }

    // 2. Filter by category
    if (selectedCategory != null && selectedCategory.isNotEmpty) {
      filtered = filtered.where((p) {
        final cat = p.purchase.materialCategory?.trim().toLowerCase() ?? 'general material';
        return cat == selectedCategory.toLowerCase();
      }).toList();
    }

    // 3. Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        final descMatch = p.purchase.itemDescription.toLowerCase().contains(searchQuery);
        final catMatch = (p.purchase.materialCategory ?? '').toLowerCase().contains(searchQuery);
        final vendorMatch = p.vendor.name.toLowerCase().contains(searchQuery);
        final refMatch = (p.transaction.referenceNo ?? '').toLowerCase().contains(searchQuery);
        return descMatch || catMatch || vendorMatch || refMatch;
      }).toList();
    }

    // 4. Group items by itemDescription + unit
    final Map<String, List<PurchaseDetail>> groupedMap = {};
    for (final pd in filtered) {
      final desc = pd.purchase.itemDescription.trim();
      final unit = (pd.purchase.unit?.trim().isNotEmpty == true)
          ? pd.purchase.unit!.trim()
          : 'Units';
      final key = '${desc.toLowerCase()}__${unit.toLowerCase()}';
      groupedMap.putIfAbsent(key, () => []).add(pd);
    }

    final List<ProjectMaterialItem> items = [];
    final Set<String> distinctCategories = {};

    for (final entry in groupedMap.entries) {
      final list = entry.value;
      // Sort inward deliveries newest first
      list.sort((a, b) => b.transaction.date.compareTo(a.transaction.date));

      final first = list.first;
      final desc = first.purchase.itemDescription.trim();
      final category = (first.purchase.materialCategory?.trim().isNotEmpty == true)
          ? first.purchase.materialCategory!.trim()
          : 'General Materials';
      final unit = (first.purchase.unit?.trim().isNotEmpty == true)
          ? first.purchase.unit!.trim()
          : 'Units';

      distinctCategories.add(category);

      double totalQty = 0.0;
      double totalAmt = 0.0;

      for (final p in list) {
        totalQty += p.purchase.quantity;
        totalAmt += p.transaction.amount;
      }

      final avgRate = totalQty > 0 ? (totalAmt / totalQty) : 0.0;

      items.add(ProjectMaterialItem(
        itemDescription: desc,
        materialCategory: category,
        totalQuantity: totalQty,
        unit: unit,
        avgUnitRate: avgRate,
        totalAmount: totalAmt,
        inwardCount: list.length,
        lastDeliveryDate: first.transaction.date,
        primaryVendor: first.vendor.name,
        deliveryHistory: list,
      ));
    }

    // Sort items by total spend descending
    items.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    final totalSpend = items.fold<double>(0.0, (sum, i) => sum + i.totalAmount);
    final totalDeliveries = filtered.length;

    // Resolve project details
    String projectName = 'All Projects Material Register';
    String? projectCode;
    String? clientName;

    if (selectedProjectId != null) {
      projectsAsync.whenData((projects) {
        final match = projects.where((p) => p.id == selectedProjectId).firstOrNull;
        if (match != null) {
          projectName = match.name;
          projectCode = match.code;
          clientName = match.clientName;
        }
      });
    }

    return ProjectMaterialSummary(
      projectId: selectedProjectId,
      projectName: projectName,
      projectCode: projectCode,
      clientName: clientName,
      totalMaterialSpend: totalSpend,
      totalDeliveriesCount: totalDeliveries,
      totalCategoriesCount: distinctCategories.length,
      totalDistinctItemsCount: items.length,
      items: items,
    );
  });
});
