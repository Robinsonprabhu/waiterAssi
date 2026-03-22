// ===========================================================================
// screens/waiter/waiter_dashboard_screen.dart
// Screen 2: Waiter Dashboard
// Tab 1: Menu (to build cart) | Tab 2: Ready for Pickup
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waiter_assistant/core/app_theme.dart';
import 'package:waiter_assistant/providers/order_provider.dart';
import 'package:waiter_assistant/models/order_model.dart';

class WaiterDashboardScreen extends StatefulWidget {
  const WaiterDashboardScreen({super.key});

  @override
  State<WaiterDashboardScreen> createState() => _WaiterDashboardScreenState();
}

class _WaiterDashboardScreenState extends State<WaiterDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Consumer listens to provider and rebuilds on notifyListeners()
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        final readyCount = provider.readyOrders.length;
        return Scaffold(
          appBar: AppBar(
            title: const Text('🛎️  WAITER'),
            actions: [
              // Table selector in the AppBar for quick access
              _TableSelector(
                selectedTable: provider.selectedTable,
                onTableChanged: provider.setTable,
              ),
              const SizedBox(width: 12),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryOrange,
              labelColor: AppTheme.primaryOrange,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              tabs: [
                const Tab(icon: Icon(Icons.restaurant_menu), text: 'MENU'),
                Tab(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_active),
                      if (readyCount > 0)
                        Positioned(
                          right: -8, top: -8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$readyCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  text: 'READY TO SERVE',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _MenuTab(provider: provider),
              _ReadyPickupTab(provider: provider),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1: Menu + Cart
// ---------------------------------------------------------------------------
class _MenuTab extends StatelessWidget {
  final OrderProvider provider;
  const _MenuTab({required this.provider});

  // Group menu items by category for a cleaner UI
  Map<String, List<MenuItem>> get _groupedMenu {
    final grouped = <String, List<MenuItem>>{};
    for (final item in provider.menu) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Scrollable menu list
        ListView(
          padding: const EdgeInsets.only(
            left: 16, right: 16, top: 16, bottom: 120,
          ),
          children: [
            // Table indicator chip
            _TableIndicatorBanner(tableNumber: provider.selectedTable),
            const SizedBox(height: 16),

            // Menu grouped by category
            ..._groupedMenu.entries.map((entry) => _CategorySection(
              category: entry.key,
              items: entry.value,
              cart: provider.cart,
              onAdd: provider.addToCart,
              onRemove: provider.removeFromCart,
            )),
          ],
        ),

        // --- Floating "Send to Kitchen" Button ---
        if (provider.cartItemCount > 0)
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: _SendToKitchenButton(provider: provider),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// A banner showing which table is selected — important for busy waiters
// ---------------------------------------------------------------------------
class _TableIndicatorBanner extends StatelessWidget {
  final int tableNumber;
  const _TableIndicatorBanner({required this.tableNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryOrange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.table_restaurant, color: AppTheme.primaryOrange, size: 20),
          const SizedBox(width: 8),
          Text(
            'Adding order for  TABLE $tableNumber',
            style: const TextStyle(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category section with its menu items
// ---------------------------------------------------------------------------
class _CategorySection extends StatelessWidget {
  final String category;
  final List<MenuItem> items;
  final Map<String, int> cart;
  final Function(String) onAdd;
  final Function(String) onRemove;

  const _CategorySection({
    required this.category,
    required this.items,
    required this.cart,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            category.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.accentGold,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
        ...items.map((item) => _MenuItemCard(
          item: item,
          quantity: cart[item.id] ?? 0,
          onAdd: () => onAdd(item.id),
          onRemove: () => onRemove(item.id),
        )),
        const Divider(color: AppTheme.divider, height: 24),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual Menu Item Card — Large touch targets
// ---------------------------------------------------------------------------
class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _MenuItemCard({
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: quantity > 0
            ? AppTheme.primaryOrange.withValues(alpha: 0.12)
            : AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: quantity > 0
            ? Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.5))
            : Border.all(color: AppTheme.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Emoji icon
            Text(item.emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 14),

            // Name & Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '₹${item.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity controller (shows just ADD if 0, shows +/- if > 0)
            if (quantity == 0)
              _AddButton(onTap: onAdd)
            else
              _QuantityController(
                quantity: quantity,
                onAdd: onAdd,
                onRemove: onRemove,
              ),
          ],
        ),
      ),
    );
  }
}

// Large ADD button (44px min height for easy tapping)
class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text('ADD', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

// +/- quantity controller
class _QuantityController extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QuantityController({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleButton(
          icon: Icons.remove,
          onTap: onRemove,
          color: AppTheme.surfaceGrey,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '$quantity',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryOrange,
            ),
          ),
        ),
        _CircleButton(
          icon: Icons.add,
          onTap: onAdd,
          color: AppTheme.primaryOrange,
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Send to Kitchen Button — Prominent, full-width CTA
// ---------------------------------------------------------------------------
class _SendToKitchenButton extends StatelessWidget {
  final OrderProvider provider;
  const _SendToKitchenButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryOrange, Color(0xFFBF360C)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryOrange.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: provider.isLoading ? null : () => _sendOrder(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.send_rounded, color: Colors.white, size: 26),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SEND TO KITCHEN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'Table ${provider.selectedTable} • ${provider.cartItemCount} items',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '₹${provider.cartTotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendOrder(BuildContext context) async {
    final success = await provider.sendOrderToKitchen();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '✅ Order sent to kitchen for Table ${provider.selectedTable}!'
              : '⚠️ Cart is empty. Add items first.',
        ),
        backgroundColor: success ? AppTheme.readyGreen : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Table Selector Dropdown in AppBar
// ---------------------------------------------------------------------------
class _TableSelector extends StatelessWidget {
  final int selectedTable;
  final Function(int) onTableChanged;

  const _TableSelector({
    required this.selectedTable,
    required this.onTableChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryOrange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.5)),
      ),
      child: DropdownButton<int>(
        value: selectedTable,
        dropdownColor: AppTheme.cardBg,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryOrange),
        style: const TextStyle(
          color: AppTheme.primaryOrange,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
        items: List.generate(10, (i) => i + 1)
            .map((t) => DropdownMenuItem<int>(
                  value: t,
                  child: Text('Table $t'),
                ))
            .toList(),
        onChanged: (val) {
          if (val != null) onTableChanged(val);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2: Ready for Pickup
// Listens to readyOrders from provider — updates in real time when kitchen acts
// ---------------------------------------------------------------------------
class _ReadyPickupTab extends StatelessWidget {
  final OrderProvider provider;
  const _ReadyPickupTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final readyOrders = provider.readyOrders;

    if (readyOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✅', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              'No orders ready yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kitchen will update you here',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: readyOrders.length,
      itemBuilder: (context, index) {
        final order = readyOrders[index];
        return _ReadyOrderCard(order: order, provider: provider);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Ready Order Card — Bright green, unmissable
// ---------------------------------------------------------------------------
class _ReadyOrderCard extends StatelessWidget {
  final Order order;
  final OrderProvider provider;

  const _ReadyOrderCard({required this.order, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.readyGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.readyGreen, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.readyGreen.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🔔', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TABLE ${order.tableNumber}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'FOOD IS READY!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.greenAccent.shade100,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              order.itemSummary,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => provider.markOrderAsDelivered(order.id),
                icon: const Icon(Icons.check_circle_outline, size: 22),
                label: const Text(
                  'MARK AS DELIVERED',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.readyGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
