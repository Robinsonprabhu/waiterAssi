// ===========================================================================
// main.dart
// Entry point for the Waiter Assistant App.
// Sets up the Provider state management and launches the app.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:waiter_assistant/providers/order_provider.dart';
import 'package:waiter_assistant/screens/role_selection_screen.dart';
import 'package:waiter_assistant/core/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        // ---------------------------------------------------------------------------
        // FIREBASE SWAP POINT #1 (Provider Registration):
        // Currently using OrderProvider which internally uses MockOrderRepository.
        // When you add Firebase, create a FirebaseOrderRepository that implements
        // the IOrderRepository interface, then pass it into OrderProvider here:
        //   ChangeNotifierProvider(create: (_) => OrderProvider(FirebaseOrderRepository()))
        // ---------------------------------------------------------------------------
        ChangeNotifierProvider(create: (_) => OrderProvider()),
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
