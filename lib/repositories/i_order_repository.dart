// ===========================================================================
// repositories/i_order_repository.dart
// The ABSTRACT INTERFACE (contract) that all repository implementations must follow.
//
// THIS IS THE KEY ARCHITECTURAL PIECE.
// The UI and Provider only ever talk to this interface.
// Swapping Mock → Firebase = creating a new class that implements this interface.
// ===========================================================================

import 'package:waiter_assistant/models/order_model.dart';

abstract class IOrderRepository {
  /// Returns the full static menu list
  List<MenuItem> getMenu();

  /// Returns all orders currently in memory / from the database
  List<Order> getAllOrders();

  /// Saves a new order. Returns the saved order (with its generated ID).
  Future<Order> placeOrder({
    required int tableNumber,
    required List<OrderItem> items,
  });

  /// Updates the status of an existing order by its ID.
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus);
}
