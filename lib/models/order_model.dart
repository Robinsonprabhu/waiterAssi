// ===========================================================================
// models/order_model.dart
// Plain data models. These map 1-to-1 with what a Firestore document looks like.
// When adding Firebase, you will add fromJson/toJson methods here.
// ===========================================================================

// Represents a single item on the restaurant menu
class MenuItem {
  final String id;
  final String name;
  final String emoji;      // Visual cue for non-tech-savvy staff
  final double price;
  final String category;   // e.g., 'Main', 'Snack', 'Drinks'

  const MenuItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.category,
  });

  // ---------------------------------------------------------------------------
  // FIREBASE SWAP POINT: Add fromJson/toJson when connecting Firestore
  // factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
  //   id: json['id'],
  //   name: json['name'],
  //   emoji: json['emoji'],
  //   price: (json['price'] as num).toDouble(),
  //   category: json['category'],
  // );
  // Map<String, dynamic> toJson() => { 'id': id, 'name': name, ... };
  // ---------------------------------------------------------------------------
}

// Represents one item inside a placed order, with quantity
class OrderItem {
  final MenuItem menuItem;
  final int quantity;

  const OrderItem({required this.menuItem, required this.quantity});

  // Convenience getter
  double get subtotal => menuItem.price * quantity;
}

// Enum for the lifecycle of an order
enum OrderStatus {
  pending,  // Sent by waiter, waiting in kitchen
  ready,    // Kitchen marked as done, waiter needs to pick up
  delivered // (Future state) Waiter confirmed delivery
}

// Extension to get display strings for the enum
extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:   return 'Pending';
      case OrderStatus.ready:     return 'Ready! 🔔';
      case OrderStatus.delivered: return 'Delivered';
    }
  }
}

// Represents a full order placed for a table
class Order {
  final String id;          // Unique ID (UUID in mock, Firestore doc ID later)
  final int tableNumber;
  final List<OrderItem> items;
  OrderStatus status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.tableNumber,
    required this.items,
    this.status = OrderStatus.pending,
    required this.createdAt,
  });

  // Convenience getter for the order summary
  double get totalAmount =>
      items.fold(0.0, (sum, item) => sum + item.subtotal);

  String get itemSummary =>
      items.map((i) => '${i.quantity}x ${i.menuItem.name}').join(', ');

  // ---------------------------------------------------------------------------
  // FIREBASE SWAP POINT: Add fromJson/toJson for Firestore serialization
  // factory Order.fromJson(Map<String, dynamic> json) => ...
  // Map<String, dynamic> toJson() => ...
  // ---------------------------------------------------------------------------
}
