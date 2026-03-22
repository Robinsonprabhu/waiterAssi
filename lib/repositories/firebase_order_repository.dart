import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:waiter_assistant/models/order_model.dart';
import 'package:waiter_assistant/repositories/i_order_repository.dart';

class FirebaseOrderRepository implements IOrderRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Static menu — in a real app, you would fetch this from a 'menu' collection
  // For the MVP, we keep the static list to avoid complex setup.
  final List<MenuItem> _menu = const [
    MenuItem(id: 'item_01', name: 'Chicken Biryani',      emoji: '🍗', price: 180, category: 'Main Course'),
    MenuItem(id: 'item_02', name: 'Veg Biryani',          emoji: '🍚', price: 140, category: 'Main Course'),
    MenuItem(id: 'item_03', name: 'Butter Chicken',       emoji: '🍛', price: 200, category: 'Main Course'),
    MenuItem(id: 'item_04', name: 'Paneer Butter Masala', emoji: '🧀', price: 170, category: 'Main Course'),
    MenuItem(id: 'item_05', name: 'Masala Dosa',  emoji: '🥞', price: 80,  category: 'Snacks'),
    MenuItem(id: 'item_06', name: 'Idli Sambar',  emoji: '🫓', price: 60,  category: 'Snacks'),
    MenuItem(id: 'item_07', name: 'Vada',         emoji: '🍩', price: 50,  category: 'Snacks'),
    MenuItem(id: 'item_08', name: 'Chapati',  emoji: '🫓', price: 40, category: 'Breads'),
    MenuItem(id: 'item_09', name: 'Naan',     emoji: '🍞', price: 50, category: 'Breads'),
    MenuItem(id: 'item_10', name: 'Chai',       emoji: '☕', price: 20, category: 'Drinks'),
    MenuItem(id: 'item_11', name: 'Lassi',      emoji: '🥛', price: 60, category: 'Drinks'),
    MenuItem(id: 'item_12', name: 'Cold Drink', emoji: '🥤', price: 40, category: 'Drinks'),
  ];

  @override
  List<MenuItem> getMenu() => _menu;

  @override
  List<Order> getAllOrders() {
    // This is not used when using watchAllOrders() stream
    return []; 
  }

  @override
  Future<Order> placeOrder({
    required int tableNumber,
    required List<OrderItem> items,
  }) async {
    final Map<String, dynamic> data = {
      'tableNumber': tableNumber,
      'items': items.map((i) => i.toJson()).toList(),
      'status': OrderStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(), // Let server set time
    };

    final docRef = await _db.collection('orders').add(data);

    return Order(
      id: docRef.id,
      tableNumber: tableNumber,
      items: items,
      createdAt: DateTime.now(), // Local approximation until reload
    );
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _db.collection('orders').doc(orderId).update({
      'status': newStatus.name,
    });
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    await _db.collection('orders').doc(orderId).delete();
  }

  /// Real-time stream of all orders, ordered by creation time
  Stream<List<Order>> watchAllOrders() {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      final List<Order> parsedOrders = [];
      for (var doc in snapshot.docs) {
        try {
          parsedOrders.add(Order.fromJson(doc.id, doc.data()));
        } catch (e) {
          // If ONE order in the database is saved incorrectly (e.g. from an old test),
          // we ignore that single order instead of crashing the whole kitchen list.
          print('⚠️ Error parsing order ${doc.id}: $e');
        }
      }
      return parsedOrders;
    });
  }
}
