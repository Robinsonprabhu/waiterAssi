// ===========================================================================
// screens/role_selection_screen.dart
// Screen 1: Role Selection — The app's home/entry screen.
// Two massive buttons. No clutter. Clear intent.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:waiter_assistant/core/app_theme.dart';
import 'package:waiter_assistant/screens/waiter/waiter_dashboard_screen.dart';
import 'package:waiter_assistant/screens/kitchen/kitchen_dashboard_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- App Title ---
              const SizedBox(height: 24),
              const Text(
                '🍽️',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              Text(
                'WAITER ASSIST',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.primaryOrange,
                  letterSpacing: 3,
                ),
              ),
              Text(
                'Who are you today?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),

              // --- WAITER BUTTON ---
              _RoleButton(
                emoji: '🛎️',
                title: 'I am a Waiter',
                subtitle: 'Take orders & serve tables',
                color: AppTheme.primaryOrange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WaiterDashboardScreen(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- KITCHEN BUTTON ---
              _RoleButton(
                emoji: '👨‍🍳',
                title: 'I am the Kitchen',
                subtitle: 'View & manage active orders',
                color: AppTheme.kitchenGreen,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const KitchenDashboardScreen(),
                  ),
                ),
              ),

              const Spacer(),
              Text(
                'v1.0.0 MVP',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: AppTheme.textSecondary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable Role Button Widget — Large, thumb-friendly, high-contrast
// ---------------------------------------------------------------------------
class _RoleButton extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleButton({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      elevation: 8,
      shadowColor: color.withValues(alpha: 0.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.white24,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 52)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
