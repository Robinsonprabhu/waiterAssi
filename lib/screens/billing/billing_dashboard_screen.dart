import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waiter_assistant/core/app_theme.dart';
import 'package:waiter_assistant/providers/order_provider.dart';
import 'package:waiter_assistant/models/order_model.dart';

class BillingDashboardScreen extends StatelessWidget {
  const BillingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧾  BILLING & CASHIER'),
        backgroundColor: Colors.blueAccent.shade700,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          final groupedOrders = provider.deliveredOrdersByTable;

          if (groupedOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🥱', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  Text(
                    'No open bills right now',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Orders marked as Delivered by waiters will appear here',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedOrders.length,
            itemBuilder: (context, index) {
              final tableNumber = groupedOrders.keys.elementAt(index);
              final tableOrders = groupedOrders[tableNumber]!;
              return _BillingTableCard(
                tableNumber: tableNumber,
                orders: tableOrders,
                provider: provider,
              );
            },
          );
        },
      ),
    );
  }
}

class _BillingTableCard extends StatelessWidget {
  final int tableNumber;
  final List<Order> orders;
  final OrderProvider provider;

  const _BillingTableCard({
    required this.tableNumber,
    required this.orders,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final totalAmount = orders.fold(0.0, (sum, o) => sum + o.totalAmount);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blueAccent.shade700.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.table_restaurant, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Text(
                      'TABLE $tableNumber',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.shade100.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₹${totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.blueAccent.shade100,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppTheme.divider),
            const SizedBox(height: 12),
            ...orders.expand((order) => order.items).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.quantity}x ${item.menuItem.name}',
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                      ),
                      Text(
                        '₹${item.subtotal.toStringAsFixed(0)}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _confirmCloseBill(context),
              icon: const Icon(Icons.receipt_long),
              label: const Text(
                'CLOSE BILL & CLEAN UP',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCloseBill(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Close Bill?', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Closing the bill for Table $tableNumber will permanently delete all associated orders from the database. Make sure payment is collected.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent.shade700),
            child: const Text('YES, CLOSE IT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final orderIds = orders.map((o) => o.id).toList();
      await provider.deleteTableOrders(orderIds);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Bill closed and order deleted.'),
          backgroundColor: Colors.blueAccent,
        ),
      );
    }
  }
}
