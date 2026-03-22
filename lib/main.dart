// ===========================================================================
// main.dart
// Entry point for the Waiter Assistant App.
// Sets up the Provider state management and launches the app.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:waiter_assistant/providers/order_provider.dart';
import 'package:waiter_assistant/screens/role_selection_screen.dart';
import 'package:waiter_assistant/core/app_theme.dart';
import 'package:waiter_assistant/repositories/firebase_order_repository.dart';
import 'package:waiter_assistant/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with the generated options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init failed (flutterfire configure may be needed): $e");
  }

  // Lock to portrait orientation for waiter use on handheld devices
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const WaiterAssistantApp());
}

class WaiterAssistantApp extends StatelessWidget {
  const WaiterAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // We have swapped to the live Firebase repository.
        ChangeNotifierProvider(create: (_) => OrderProvider(FirebaseOrderRepository())),
      ],
      child: MaterialApp(
        title: 'Waiter Assistant',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const RoleSelectionScreen(),
      ),
    );
  }
}
