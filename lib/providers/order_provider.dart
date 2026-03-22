// ===========================================================================
// providers/order_provider.dart
// The single source of truth for all app state.
// Uses ChangeNotifier (Provider package) to broadcast updates to the UI.
//
// The UI calls methods on this class. This class calls the repository.
// The UI never touches the repository directly.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:waiter_assistant/models/order_model.dart';
import 'package:waiter_assistant/repositories/i_order_repository.dart';
import 'package:waiter_assistant/repositories/mock_order_repository.dart';

class OrderProvider extends ChangeNotifier {

  // ---------------------------------------------------------------------------
  // FIREBASE SWAP POINT #2 (Dependency Injection):
  // The repository is injected here. To swap to Firebase:
  //   final IOrderRepository _repository;
  //   OrderProvider([IOrderRepository? repo])
  //     : _repository = repo ?? FirebaseOrderRepository();
  // Or pass it from main.dart via the Provider constructor.
  // ---------------------------------------------------------------------------
  final IOrderRepository _repository;

  OrderProvider([IOrderRepository? repository])
      : _repository = repository ?? MockOrderRepository();

  // --- Internal State ---
  bool _isLoading = false;

  // Cart state (local, not persisted — lives only during the waiter's session)
  final Map<String, int> _cart = {}; // menuItem.id → quantity
  int _selectedTable = 1;

  // --- Public Getters ---

  bool get isLoading => _isLoading;

  int get selectedTable => _selectedTable;

  Map<String, int> get cart => Map.unmodifiable(_cart);

  List<MenuItem> get menu => _repository.getMenu();

  List<Order> get allOrders => _repository.getAllOrders();

  /// Orders the kitchen is working on
  List<Order> get pendingOrders =>
      allOrders.where((o) => o.status == OrderStatus.pending).toList();

  /// Orders the waiter needs to pick up and deliver
  List<Order> get readyOrders =>
      allOrders.where((o) => o.status == OrderStatus.ready).toList();

  int get cartItemCount =>
      _cart.values.fold(0, (sum, qty) => sum + qty);

  double get cartTotal {
    double total = 0;
    _cart.forEach((menuId, qty) {
      final item = menu.firstWhere((m) => m.id == menuId);
      total += item.price * qty;
    });
    return total;
  }

  // ---------------------------------------------------------------------------
  // CART ACTIONS
  // ---------------------------------------------------------------------------

  void setTable(int tableNumber) {
    _selectedTable = tableNumber;
    notifyListeners();
  }

  void addToCart(String menuItemId) {
    _cart[menuItemId] = (_cart[menuItemId] ?? 0) + 1;
    notifyListeners();
  }

  void removeFromCart(String menuItemId) {
    if (_cart.containsKey(menuItemId)) {
      if (_cart[menuItemId]! <= 1) {
        _cart.remove(menuItemId);
      } else {
        _cart[menuItemId] = _cart[menuItemId]! - 1;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // ORDER ACTIONS
  // ---------------------------------------------------------------------------

  /// Converts the current cart into an Order and sends it to the repository.
  Future<bool> sendOrderToKitchen() async {
    if (_cart.isEmpty) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final orderItems = _cart.entries.map((entry) {
        final menuItem = menu.firstWhere((m) => m.id == entry.key);
        return OrderItem(menuItem: menuItem, quantity: entry.value);
      }).toList();

      await _repository.placeOrder(
        tableNumber: _selectedTable,
        items: orderItems,
      );

      clearCart(); // Reset cart after successful send
      return true;
    } catch (e) {
      debugPrint('Error placing order: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Marks an order as Ready — called from the Kitchen screen.
  Future<void> markOrderAsReady(String orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updateOrderStatus(orderId, OrderStatus.ready);
      // ---------------------------------------------------------------------------
      // FIREBASE SWAP POINT #3 (Real-time):
      // With Firebase, you would use a Firestore Stream listener instead of
      // calling notifyListeners() manually. The stream fires automatically when
      // the Firestore document changes, even from another device.
      // Example in provider:
      //   FirebaseFirestore.instance.collection('orders')
      //     .where('status', isEqualTo: 'pending')
      //     .snapshots()
      //     .listen((snapshot) { ... notifyListeners(); });
      // ---------------------------------------------------------------------------
    } catch (e) {
      debugPrint('Error updating order: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // This makes the Waiter's screen update instantly
    }
  }

  /// Marks an order as Delivered — called from the Waiter's Ready screen.
  Future<void> markOrderAsDelivered(String orderId) async {
    await _repository.updateOrderStatus(orderId, OrderStatus.delivered);
    notifyListeners();
  }
}
