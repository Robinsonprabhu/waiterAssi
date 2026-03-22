// ===========================================================================
// FIREBASE MIGRATION GUIDE
// When you're ready to connect Firebase Firestore, follow these steps.
// You will NOT need to touch any UI screen files.
// ===========================================================================

/*

STEP 1: Add Firebase dependencies to pubspec.yaml
-----------------------------------------------------
  firebase_core: ^2.x.x
  cloud_firestore: ^4.x.x
  firebase_auth: ^4.x.x   # Optional, for staff login


STEP 2: Create FirebaseOrderRepository
---------------------------------------
Create: lib/repositories/firebase_order_repository.dart

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import 'i_order_repository.dart';

class FirebaseOrderRepository implements IOrderRepository {
  final _db = FirebaseFirestore.instance;

  @override
  List<MenuItem> getMenu() {
    // TODO: Fetch from Firestore 'menu' collection
    // For now, return static list or fetch via FutureBuilder in UI
    throw UnimplementedError();
  }

  @override
  List<Order> getAllOrders() {
    // NOTE: With Firestore, prefer streams over this method.
    // See OrderProvider for stream integration.
    throw UnimplementedError();
  }

  @override
  Future<Order> placeOrder({required int tableNumber, required List<OrderItem> items}) async {
    final docRef = await _db.collection('orders').add({
      'tableNumber': tableNumber,
      'items': items.map((i) => {
        'menuItemId': i.menuItem.id,
        'menuItemName': i.menuItem.name,
        'quantity': i.quantity,
        'price': i.menuItem.price,
      }).toList(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return Order(
      id: docRef.id,
      tableNumber: tableNumber,
      items: items,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _db.collection('orders').doc(orderId).update({
      'status': newStatus.name, // 'pending', 'ready', 'delivered'
    });
  }

  // BONUS: Real-time stream for Kitchen screen
  Stream<List<Order>> watchPendingOrders() {
    return _db
      .collection('orders')
      .where('status', isEqualTo: 'pending')
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
        // Map Firestore doc → Order model
        final data = doc.data();
        return Order(
          id: doc.id,
          tableNumber: data['tableNumber'],
          items: [], // TODO: parse items
          status: OrderStatus.values.firstWhere((e) => e.name == data['status']),
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }).toList());
  }
}
```


STEP 3: Update OrderProvider to use the new repository
-------------------------------------------------------
In lib/providers/order_provider.dart, change:

  OrderProvider([IOrderRepository? repository])
    : _repository = repository ?? MockOrderRepository();

To:

  OrderProvider([IOrderRepository? repository])
    : _repository = repository ?? FirebaseOrderRepository();

OR inject from main.dart:
  ChangeNotifierProvider(create: (_) => OrderProvider(FirebaseOrderRepository()))


STEP 4: Add stream listeners for real-time updates
---------------------------------------------------
In OrderProvider, replace the _orders list with a StreamSubscription:

  StreamSubscription? _ordersSubscription;

  void startListening() {
    _ordersSubscription = (repository as FirebaseOrderRepository)
      .watchPendingOrders()
      .listen((orders) {
        _pendingOrders = orders;
        notifyListeners(); // Waiter and Kitchen screens update automatically!
      });
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }


STEP 5: Add to model's fromJson/toJson
---------------------------------------
In lib/models/order_model.dart, uncomment the fromJson/toJson methods.


That's it! The UI screens (role_selection, waiter_dashboard, kitchen_dashboard)
require ZERO changes. The architecture held.

*/
