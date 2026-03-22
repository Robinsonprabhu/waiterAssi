// ===========================================================================
// screens/kitchen/kitchen_dashboard_screen.dart
// Screen 3: Kitchen Display System (KDS)
// Shows all PENDING orders in a grid. One big "FOOD READY" button per card.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waiter_assistant/core/app_theme.dart';
import 'package:waiter_assistant/providers/order_provider.dart';
import 'package:waiter_assistant/models/order_model.dart';

class KitchenDashboardScreen extends StatelessWidget {
  const KitchenDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        final pendingOrders = provider.pendingOrders;
        return Scaffold(
          appBar: AppBar(
            title: const Text('👨‍🍳  KITCHEN'),
            backgroundColor: AppTheme.kitchenGreen,
            actions: [
              // Active order count badge
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: pendingOrders.isNotEmpty
                      ? AppTheme.pendingAmber
                      : AppTheme.surfaceGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${pendingOrders.length} ACTIVE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          body: pendingOrders.isEmpty
              ? _EmptyKitchenView()
              : _OrderGrid(orders: pendingOrders, provider: provider),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state — Shown when no active orders
// ---------------------------------------------------------------------------
class _EmptyKitchenView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍳', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 20),
          Text(
            'All Clear!',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppTheme.kitchenGreen,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'No pending orders right now.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders from the waiter will appear here.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Order grid — 1 column on phones, 2 on tablets
// ---------------------------------------------------------------------------
class _OrderGrid extends StatelessWidget {
  final List<Order> orders;
  final OrderProvider provider;

  const _OrderGrid({required this.orders, required this.provider});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 2-column grid on wide screens (tablets), 1-column on phones
    final crossAxisCount = screenWidth > 600 ? 2 : 1;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _KitchenOrderCard(
          order: orders[index],
          provider: provider,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Kitchen Order Card
// Shows table number, all items, time elapsed, and the BIG green button
// ---------------------------------------------------------------------------
class _KitchenOrderCard extends StatelessWidget {
  final Order order;
  final OrderProvider provider;

  const _KitchenOrderCard({required this.order, required this.provider});

  String _getElapsedTime() {
    final diff = DateTime.now().difference(order.createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    return '${diff.inMinutes} min ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.pendingAmber.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Card Header: Table Number ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppTheme.pendingAmber,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.table_restaurant, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'TABLE ${order.tableNumber}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getElapsedTime(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Order Items List ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ITEMS',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.items.length,
                      itemBuilder: (context, i) {
                        final item = order.items[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Text(
                                item.menuItem.emoji,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.menuItem.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.pendingAmber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.pendingAmber.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  'x${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.accentGold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- FOOD READY Button: THE MOST IMPORTANT ELEMENT ---
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: _FoodReadyButton(
              orderId: order.id,
              tableNumber: order.tableNumber,
              provider: provider,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The big green "FOOD READY" button
// Designed to be absolutely unmissable in a busy kitchen environment
// ---------------------------------------------------------------------------
class _FoodReadyButton extends StatefulWidget {
  final String orderId;
  final int tableNumber;
  final OrderProvider provider;

  const _FoodReadyButton({
    required this.orderId,
    required this.tableNumber,
    required this.provider,
  });

  @override
  State<_FoodReadyButton> createState() => _FoodReadyButtonState();
}

class _FoodReadyButtonState extends State<_FoodReadyButton> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppTheme.readyGreen.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _isProcessing ? null : _handleFoodReady,
              child: Center(
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('✅', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 10),
                          Text(
                            'FOOD READY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleFoodReady() async {
    setState(() => _isProcessing = true);

    // Show a confirmation dialog for safety (avoid accidental taps)
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Table ${widget.tableNumber} Ready?',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'This will notify the waiter that food is ready for pickup.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.readyGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'YES, READY!',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // ---------------------------------------------------------------------------
      // This call goes to the Provider → Repository → (Firebase in production)
      // The Waiter's screen will update automatically via notifyListeners()
      // With Firebase, this would be a Firestore stream that triggers automatically
      // ---------------------------------------------------------------------------
      await widget.provider.markOrderAsReady(widget.orderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔔 Table ${widget.tableNumber} notified!'),
            backgroundColor: AppTheme.readyGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      setState(() => _isProcessing = false);
    }
  }
}
