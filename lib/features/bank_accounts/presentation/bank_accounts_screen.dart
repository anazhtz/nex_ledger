import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/bank_accounts/data/bank_account_repository.dart';
import 'package:nex_ledger/features/bank_accounts/providers/bank_account_providers.dart';
import 'package:nex_ledger/shared/widgets/confirm_dialog.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';
import 'package:nex_ledger/shared/widgets/stat_card.dart';

class BankAccountsScreen extends ConsumerWidget {
  const BankAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final liquidityAsync = ref.watch(liquiditySummaryProvider);
    final accountsAsync = ref.watch(bankAccountsWithBalancesProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar Title & Actions
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/cash-book'),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bank & Cash Accounts Master',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Track physical cash drawers, bank accounts, opening balances, and contra transfers',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                OutlinedButton.icon(
                  onPressed: () => _showTransferDialog(context, ref),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: const Text('Transfer Funds (Contra)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4F46E5),
                    side: const BorderSide(color: Color(0xFF4F46E5)),
                  ),
                ),
                SizedBox(width: 12.w),
                FilledButton.icon(
                  onPressed: () => _showAccountFormDialog(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Account'),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Liquidity Summary Cards
            liquidityAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (liq) => Column(
                children: [
                  if (liq.totalLiquidity < 0 || liq.cashInHand < 0)
                    Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.red.shade700, size: 22.sp),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Negative Balance Warning: Your total cash/bank liquidity is currently negative (${CurrencyFormatter.format(liq.totalLiquidity)}). Consider updating opening balances or recording customer deposits/income.',
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Total Cash & Bank Balance',
                          value: CurrencyFormatter.format(liq.totalLiquidity),
                          icon: Icons.account_balance_wallet_rounded,
                          iconColor: liq.totalLiquidity < 0
                              ? Colors.red.shade700
                              : const Color(0xFF059669),
                          valueColor: liq.totalLiquidity < 0
                              ? Colors.red.shade700
                              : const Color(0xFF059669),
                          subtitle: 'Available liquid funds across all accounts',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: StatCard(
                          label: 'Petty Cash in Hand',
                          value: CurrencyFormatter.format(liq.cashInHand),
                          icon: Icons.payments_rounded,
                          iconColor: liq.cashInHand < 0
                              ? Colors.red.shade700
                              : const Color(0xFF2563EB),
                          valueColor: liq.cashInHand < 0
                              ? Colors.red.shade700
                              : const Color(0xFF2563EB),
                          subtitle: 'Physical cash held in office/site drawers',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: StatCard(
                          label: 'Total in Bank Accounts',
                          value: CurrencyFormatter.format(liq.inBanks),
                          icon: Icons.account_balance_rounded,
                          iconColor: liq.inBanks < 0
                              ? Colors.red.shade700
                              : const Color(0xFF7C3AED),
                          valueColor: liq.inBanks < 0
                              ? Colors.red.shade700
                              : const Color(0xFF7C3AED),
                          subtitle: 'Combined balance across all bank accounts',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Accounts Table
            accountsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading accounts: $e')),
              data: (list) => DataTableCard(
                title: 'All Cash Drawers & Bank Accounts',
                emptyMessage:
                    'No accounts registered yet. Click "Add Account" to configure your bank accounts and cash drawers.',
                columns: const [
                  DataColumn(label: Text('Account Name')),
                  DataColumn(label: Text('Bank / Type')),
                  DataColumn(label: Text('Account No. / IFSC')),
                  DataColumn(label: Text('Opening Balance'), numeric: true),
                  DataColumn(label: Text('Total Inflow'), numeric: true),
                  DataColumn(label: Text('Total Outflow'), numeric: true),
                  DataColumn(label: Text('Current Balance'), numeric: true),
                  DataColumn(label: Text('Actions')),
                ],
                rows: list.map((item) {
                  final acc = item.account;
                  final isNegative = item.currentBalance < 0;

                  return DataRow(cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            acc.isCashAccount
                                ? Icons.payments_outlined
                                : Icons.account_balance_outlined,
                            size: 18.sp,
                            color: acc.isCashAccount
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF7C3AED),
                          ),
                          SizedBox(width: 8.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                acc.accountName,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              if (acc.isDefault)
                                Container(
                                  margin: EdgeInsets.only(top: 2.h),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    'Default',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: const Color(0xFF4F46E5),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(
                      acc.isCashAccount
                          ? 'Cash Drawer'
                          : (acc.bankName?.isNotEmpty == true
                              ? acc.bankName!
                              : 'Bank Account'),
                    )),
                    DataCell(Text(
                      acc.accountNumber?.isNotEmpty == true
                          ? '${acc.accountNumber}${acc.ifscCode != null ? ' (${acc.ifscCode})' : ''}'
                          : '—',
                    )),
                    DataCell(Text(
                      CurrencyFormatter.format(acc.openingBalance),
                      style: const TextStyle(color: Color(0xFF64748B)),
                    )),
                    DataCell(Text(
                      '+${CurrencyFormatter.format(item.totalInflow)}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                    DataCell(Text(
                      '-${CurrencyFormatter.format(item.totalOutflow)}',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isNegative)
                            Padding(
                              padding: EdgeInsets.only(right: 4.w),
                              child: Icon(Icons.error_outline,
                                  color: Colors.red.shade700, size: 14.sp),
                            ),
                          Text(
                            CurrencyFormatter.format(item.currentBalance),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isNegative
                                  ? Colors.red.shade700
                                  : const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 17),
                            tooltip: 'Edit Account',
                            onPressed: () => _showAccountFormDialog(
                              context,
                              ref,
                              account: acc,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 17),
                            tooltip: 'Delete Account',
                            color: theme.colorScheme.error,
                            onPressed: () async {
                              final confirmed = await ConfirmDialog.show(
                                context,
                                title: 'Delete Account?',
                                message:
                                    'Delete account "${acc.accountName}"? Transactions previously tagged to this account will remain in ledger.',
                                confirmLabel: 'Delete Account',
                              );
                              if (confirmed) {
                                await ref
                                    .read(bankAccountRepositoryProvider)
                                    .deleteAccount(acc.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountFormDialog(
    BuildContext context,
    WidgetRef ref, {
    BankAccount? account,
  }) {
    final isEditing = account != null;
    final nameCtrl = TextEditingController(text: account?.accountName ?? '');
    final bankCtrl = TextEditingController(text: account?.bankName ?? '');
    final noCtrl = TextEditingController(text: account?.accountNumber ?? '');
    final ifscCtrl = TextEditingController(text: account?.ifscCode ?? '');
    final branchCtrl = TextEditingController(text: account?.branch ?? '');
    final opCtrl = TextEditingController(
      text: account?.openingBalance != null
          ? (account!.openingBalance % 1 == 0
              ? account.openingBalance.toInt().toString()
              : account.openingBalance.toString())
          : '0',
    );
    bool isCash = account?.isCashAccount ?? false;
    bool isDef = account?.isDefault ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Account' : 'Add Bank / Cash Account'),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 460.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    value: isCash,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Is this a Cash in Hand / Petty Cash Drawer?'),
                    subtitle: Text(
                      isCash
                          ? 'Physical cash drawer (no bank account number required)'
                          : 'Bank account (current / savings / overdraft)',
                      style: TextStyle(fontSize: 11.sp),
                    ),
                    onChanged: (v) => setState(() => isCash = v),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: isCash ? 'Drawer / Cash Name *' : 'Account Display Name *',
                      hintText: isCash ? 'e.g. Office Petty Cash Drawer' : 'e.g. HDFC Main Current A/c',
                    ),
                  ),
                  if (!isCash) ...[
                    SizedBox(height: 12.h),
                    TextField(
                      controller: bankCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Bank Name',
                        hintText: 'e.g. HDFC Bank, SBI',
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: noCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Account Number',
                        hintText: 'e.g. 50200012345678',
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ifscCtrl,
                            decoration: const InputDecoration(
                              labelText: 'IFSC Code',
                              hintText: 'e.g. HDFC0001234',
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextField(
                            controller: branchCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Branch Name',
                              hintText: 'e.g. MG Road',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 12.h),
                  TextField(
                    controller: opCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Initial Opening Balance (₹)',
                      prefixText: '₹ ',
                      hintText: '0.00',
                    ),
                  ),
                  SizedBox(height: 12.h),
                  CheckboxListTile(
                    value: isDef,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Set as Default Account'),
                    subtitle: Text(
                      'Auto-select this account for transactions of this type',
                      style: TextStyle(fontSize: 11.sp),
                    ),
                    onChanged: (v) => setState(() => isDef = v ?? false),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final opBalance = double.tryParse(
                        opCtrl.text.replaceAll(',', '').trim()) ??
                    0.0;
                final repo = ref.read(bankAccountRepositoryProvider);

                if (isEditing) {
                  await repo.updateAccount(
                    id: account.id,
                    accountName: nameCtrl.text.trim(),
                    bankName: bankCtrl.text.isNotEmpty ? bankCtrl.text.trim() : null,
                    accountNumber: noCtrl.text.isNotEmpty ? noCtrl.text.trim() : null,
                    ifscCode: ifscCtrl.text.isNotEmpty ? ifscCtrl.text.trim() : null,
                    branch: branchCtrl.text.isNotEmpty ? branchCtrl.text.trim() : null,
                    openingBalance: opBalance,
                    isCashAccount: isCash,
                    isDefault: isDef,
                  );
                } else {
                  await repo.addAccount(
                    accountName: nameCtrl.text.trim(),
                    bankName: bankCtrl.text.isNotEmpty ? bankCtrl.text.trim() : null,
                    accountNumber: noCtrl.text.isNotEmpty ? noCtrl.text.trim() : null,
                    ifscCode: ifscCtrl.text.isNotEmpty ? ifscCtrl.text.trim() : null,
                    branch: branchCtrl.text.isNotEmpty ? branchCtrl.text.trim() : null,
                    openingBalance: opBalance,
                    isCashAccount: isCash,
                    isDefault: isDef,
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(isEditing ? 'Update Account' : 'Save Account'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransferDialog(BuildContext context, WidgetRef ref) async {
    final accounts =
        await ref.read(bankAccountRepositoryProvider).getAllAccounts();
    if (accounts.length < 2) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'You need at least 2 accounts (e.g. Cash in Hand and a Bank Account) to make a transfer.'),
          ),
        );
      }
      return;
    }

    int fromId = accounts.first.id;
    int toId = accounts.length > 1 ? accounts[1].id : accounts.first.id;
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    DateTime date = DateTime.now();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.swap_horiz_rounded, color: Color(0xFF4F46E5)),
              SizedBox(width: 8.w),
              const Text('Transfer Funds (Contra Entry)'),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 440.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Record a cash deposit into bank, cash withdrawal, or internal bank-to-bank transfer. This moves money between accounts without affecting operating profit/loss.',
                    style: TextStyle(
                        fontSize: 12.sp, color: const Color(0xFF64748B)),
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<int>(
                    value: fromId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Transfer From (Source)',
                    ),
                    items: accounts.map((a) {
                      return DropdownMenuItem(
                        value: a.id,
                        child: Text(
                          '${a.accountName} (${a.isCashAccount ? 'Cash' : 'Bank'})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => fromId = v);
                    },
                  ),
                  SizedBox(height: 12.h),
                  DropdownButtonFormField<int>(
                    value: toId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Transfer To (Destination)',
                    ),
                    items: accounts.map((a) {
                      return DropdownMenuItem(
                        value: a.id,
                        child: Text(
                          '${a.accountName} (${a.isCashAccount ? 'Cash' : 'Bank'})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => toId = v);
                    },
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Transfer Amount (₹) *',
                      prefixText: '₹ ',
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: refCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Reference / Cheque / UTR No.',
                      hintText: 'e.g. CHEQUE-9021 or UTR-2026',
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Transfer Narration / Reason',
                      hintText: 'e.g. Cash deposited into current account',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (fromId == toId) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Source and destination accounts must be different.')),
                  );
                  return;
                }
                final amount = double.tryParse(
                        amountCtrl.text.replaceAll(',', '').trim()) ??
                    0.0;
                if (amount <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a valid positive transfer amount.')),
                  );
                  return;
                }

                await ref.read(bankAccountRepositoryProvider).transferFunds(
                      fromAccountId: fromId,
                      toAccountId: toId,
                      amount: amount,
                      date: date,
                      narration: noteCtrl.text.isNotEmpty ? noteCtrl.text : null,
                      referenceNo: refCtrl.text.isNotEmpty ? refCtrl.text : null,
                    );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Funds transfer recorded successfully.'),
                      backgroundColor: Color(0xFF059669),
                    ),
                  );
                }
              },
              child: const Text('Complete Transfer'),
            ),
          ],
        ),
      ),
    );
  }
}
