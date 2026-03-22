// ===========================================================================
// models/order_model.dart
// Plain data models. These map 1-to-1 with what a Firestore document looks like.
// When adding Firebase, you will add fromJson/toJson methods here.
// ===========================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id'] as String,
    name: json['name'] as String,
    emoji: json['emoji'] as String,
    price: (json['price'] as num).toDouble(),
    category: json['category'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'price': price,
    'category': category,
  };
}

// Represents one item inside a placed order, with quantity
class OrderItem {
  final MenuItem menuItem;
  final int quantity;

  const OrderItem({required this.menuItem, required this.quantity});

  // Convenience getter
  double get subtotal => menuItem.price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    menuItem: MenuItem.fromJson(json['menuItem'] as Map<String, dynamic>),
    quantity: json['quantity'] as int,
  );

  Map<String, dynamic> toJson() => {
    'menuItem': menuItem.toJson(),
    'quantity': quantity,
  };
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

  factory Order.fromJson(String documentId, Map<String, dynamic> json) {
    return Order(
      id: documentId,
      tableNumber: json['tableNumber'] as int,
      items: (json['items'] as List<dynamic>)
          .map((itemJson) => OrderItem.fromJson(itemJson as Map<String, dynamic>))
          .toList(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(), // Fallback if server timestamp hasn't populated yet
    );
  }

  Map<String, dynamic> toJson() => {
    'tableNumber': tableNumber,
    'items': items.map((i) => i.toJson()).toList(),
    'status': status.name,
    // Note: createdAt is handled specially by the repository via FieldValue.serverTimestamp() during creation.
  };
}
