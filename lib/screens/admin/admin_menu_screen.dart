// ===========================================================================
// screens/admin/admin_menu_screen.dart
// Screen: Admin / Owner — Manage the food menu.
// Allows adding, editing, and deleting menu items in real time.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:waiter_assistant/core/app_theme.dart';
import 'package:waiter_assistant/models/order_model.dart';
import 'package:waiter_assistant/providers/order_provider.dart';

const _uuid = Uuid();

/// All supported categories — keep in sync with the menu data.
const _categories = ['Main Course', 'Snacks', 'Breads', 'Drinks'];

// ===========================================================================
// Main Screen
// ===========================================================================
class AdminMenuScreen extends StatelessWidget {
  const AdminMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('⚙️  ADMIN — MENU MANAGER'),
        backgroundColor: Colors.deepPurple.shade800,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('ADD ITEM',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
        onPressed: () => _openItemSheet(context, null),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          final menu = provider.menu;
          if (menu.isEmpty) {
            return const Center(
              child: Text('No items. Tap + to add one.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
            );
          }

          // Group items by category
          final grouped = <String, List<MenuItem>>{};
          for (final cat in _categories) {
            final catItems =
                menu.where((m) => m.category == cat).toList();
            if (catItems.isNotEmpty) grouped[cat] = catItems;
          }
          // Any items with an unknown category go at the bottom
          final otherItems =
              menu.where((m) => !_categories.contains(m.category)).toList();
          if (otherItems.isNotEmpty) grouped['Other'] = otherItems;

          return ListView(
            padding: const EdgeInsets.only(
                left: 16, right: 16, top: 16, bottom: 100),
            children: [
              for (final entry in grouped.entries) ...[
                _CategoryHeader(entry.key),
                for (final item in entry.value)
                  _MenuItemTile(
                    item: item,
                    onEdit: () => _openItemSheet(context, item),
                    onDelete: () => _confirmDelete(context, item, provider),
                  ),
                const SizedBox(height: 8),
              ],
            ],
          );
        },
      ),
    );
  }

  // Opens the Add/Edit bottom sheet
  void _openItemSheet(BuildContext context, MenuItem? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MenuItemFormSheet(existing: existing),
    );
  }

  // Confirm-delete dialog
  Future<void> _confirmDelete(
      BuildContext context, MenuItem item, OrderProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: Text('Delete "${item.name}"?',
            style: const TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'This item will be removed from the menu permanently (for this session).',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      provider.deleteMenuItem(item.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🗑️  "${item.name}" deleted.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

// ===========================================================================
// Category Header Widget
// ===========================================================================
class _CategoryHeader extends StatelessWidget {
  final String category;
  const _CategoryHeader(this.category);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        category.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.accentGold,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

// ===========================================================================
// Menu Item Tile with Edit + Delete actions
// ===========================================================================
class _MenuItemTile extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MenuItemTile(
      {required this.item, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  Text(
                    '₹${item.price.toStringAsFixed(0)}  •  ${item.category}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: Colors.deepPurpleAccent),
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Delete',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Add / Edit Form Bottom Sheet
// ===========================================================================
class _MenuItemFormSheet extends StatefulWidget {
  /// If null, we are adding a new item. If non-null, we are editing.
  final MenuItem? existing;
  const _MenuItemFormSheet({this.existing});

  @override
  State<_MenuItemFormSheet> createState() => _MenuItemFormSheetState();
}

class _MenuItemFormSheetState extends State<_MenuItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emojiCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _selectedCategory = _categories.first;

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameCtrl.text = widget.existing!.name;
      _emojiCtrl.text = widget.existing!.emoji;
      _priceCtrl.text = widget.existing!.price.toStringAsFixed(0);
      _selectedCategory = widget.existing!.category;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emojiCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<OrderProvider>();

    final item = MenuItem(
      id: isEditing ? widget.existing!.id : 'item_${_uuid.v4()}',
      name: _nameCtrl.text.trim(),
      emoji: _emojiCtrl.text.trim().isEmpty ? '🍽️' : _emojiCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim()),
      category: _selectedCategory,
    );

    if (isEditing) {
      provider.updateMenuItem(item);
    } else {
      provider.addMenuItem(item);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(isEditing ? '✅ "${item.name}" updated!' : '✅ "${item.name}" added!'),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Padding accounts for on-screen keyboard
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPad),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sheet handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isEditing ? 'Edit Menu Item' : 'Add New Item',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),

            // Name field
            _FormField(
              ctrl: _nameCtrl,
              label: 'Item Name',
              hint: 'e.g. Mango Lassi',
              icon: Icons.fastfood_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 14),

            // Emoji + Price row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _FormField(
                    ctrl: _emojiCtrl,
                    label: 'Emoji',
                    hint: '🥭',
                    icon: Icons.emoji_emotions_outlined,
                    // Emoji is optional — falls back to 🍽️
                    validator: null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: _FormField(
                    ctrl: _priceCtrl,
                    label: 'Price (₹)',
                    hint: '70',
                    icon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final n = double.tryParse(v.trim());
                      if (n == null || n <= 0) return 'Invalid price';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Category dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: AppTheme.cardBg,
                  icon: const Icon(Icons.arrow_drop_down,
                      color: AppTheme.textSecondary),
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 15),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                  items: _categories
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _submit(context),
                icon: Icon(isEditing ? Icons.save_outlined : Icons.add_circle_outline),
                label: Text(
                  isEditing ? 'SAVE CHANGES' : 'ADD TO MENU',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Small reusable text form field
// ===========================================================================
class _FormField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.ctrl,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.deepPurpleAccent, size: 20),
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        hintStyle:
            const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        filled: true,
        fillColor: AppTheme.surfaceGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.deepPurpleAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}
