// ===========================================================================
// repositories/mock_order_repository.dart
// In-memory mock implementation of IOrderRepository.
// All data lives in Dart lists — no backend, no persistence.
//
// FIREBASE SWAP POINT: When Firebase is added, create a new class
// FirebaseOrderRepository that implements IOrderRepository.
// No UI files or Provider files need to change.
// ===========================================================================

import 'package:uuid/uuid.dart';

import 'package:waiter_assistant/models/order_model.dart';
import 'package:waiter_assistant/repositories/i_order_repository.dart';

class MockOrderRepository implements IOrderRepository {
  // UUID generator for creating unique order IDs
  // FIREBASE SWAP POINT: Firebase will use auto-generated Firestore document IDs
  static const _uuid = Uuid();

  // ---------------------------------------------------------------------------
  // Seeded menu items — 12 items across 4 categories
  // FIREBASE SWAP POINT: In production, fetch this from a Firestore 'menu' collection
  // ---------------------------------------------------------------------------
  final List<MenuItem> _menu = const [
    // — Main Course —
    MenuItem(id: 'item_01', name: 'Chicken Biryani',      emoji: '🍗', price: 180, category: 'Main Course'),
    MenuItem(id: 'item_02', name: 'Veg Biryani',          emoji: '🍚', price: 140, category: 'Main Course'),
    MenuItem(id: 'item_03', name: 'Butter Chicken',       emoji: '🍛', price: 200, category: 'Main Course'),
    MenuItem(id: 'item_04', name: 'Paneer Butter Masala', emoji: '🧀', price: 170, category: 'Main Course'),

    // — Snacks —
    MenuItem(id: 'item_05', name: 'Masala Dosa',  emoji: '🥞', price: 80,  category: 'Snacks'),
    MenuItem(id: 'item_06', name: 'Idli Sambar',  emoji: '🫓', price: 60,  category: 'Snacks'),
    MenuItem(id: 'item_07', name: 'Vada',         emoji: '🍩', price: 50,  category: 'Snacks'),

    // — Breads —
    MenuItem(id: 'item_08', name: 'Chapati',  emoji: '🫓', price: 40, category: 'Breads'),
    MenuItem(id: 'item_09', name: 'Naan',     emoji: '🍞', price: 50, category: 'Breads'),

    // — Drinks —
    MenuItem(id: 'item_10', name: 'Chai',       emoji: '☕', price: 20, category: 'Drinks'),
    MenuItem(id: 'item_11', name: 'Lassi',      emoji: '🥛', price: 60, category: 'Drinks'),
    MenuItem(id: 'item_12', name: 'Cold Drink', emoji: '🥤', price: 40, category: 'Drinks'),
  ];

  // In-memory order storage
  // FIREBASE SWAP POINT: Replace with Firestore reads/writes
  final List<Order> _orders = [];

  @override
  List<MenuItem> getMenu() => _menu;

  @override
  List<Order> getAllOrders() => _orders;

  @override
  Future<Order> placeOrder({
    required int tableNumber,
    required List<OrderItem> items,
  }) async {
    // Simulate a brief network delay (helps test loading indicators)
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final order = Order(
      id: _uuid.v4(),
      tableNumber: tableNumber,
      items: items,
      createdAt: DateTime.now(),
    );

    _orders.add(order);
    return order;
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    // Simulate a brief network delay
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final order = _orders.firstWhere((o) => o.id == orderId);
    order.status = newStatus;
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _orders.removeWhere((o) => o.id == orderId);
  }
}
