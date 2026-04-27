import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/app_category.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    
    final defaultCategories = provider.allCategories.where((c) => c.type == CategoryType.defaultType).toList();
    final customCategories = provider.allCategories.where((c) => c.type == CategoryType.custom).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Manage Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.refreshAll(),
          ),
        ],
      ),
      body: Stack(
        children: [
          provider.isLoading && provider.allCategories.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (defaultCategories.isNotEmpty) ...[
                    _buildSectionHeader(context, "Default Categories"),
                    const SizedBox(height: 12),
                    ...defaultCategories.map((cat) => _buildCategoryTile(context, cat, provider)),
                    const SizedBox(height: 32),
                  ],
                  
                  if (customCategories.isNotEmpty) ...[
                    _buildSectionHeader(context, "Your Custom Categories"),
                    const SizedBox(height: 12),
                    ...customCategories.map((cat) => _buildCategoryTile(context, cat, provider)),
                  ],

                  if (provider.allCategories.isEmpty && !provider.isLoading)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 100),
                          Icon(Icons.category_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          const Text(
                            'No categories found in Firebase',
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => provider.refreshAll(),
                            child: const Text('Tap to Sync'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          if (provider.isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: provider.isProcessing ? null : () => _showAddCategoryDialog(context, provider),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, AppCategory category, ExpenseProvider provider) {
    final isDefault = category.type == CategoryType.defaultType;

    Widget listTile = Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.category_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
        ),
        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: isDefault 
            ? const Icon(Icons.lock_outline_rounded, size: 16, color: Colors.white10)
            : const Icon(Icons.swipe_left_rounded, size: 16, color: Colors.white10),
      ),
    );

    if (isDefault) return listTile;

    return Dismissible(
      key: ValueKey(category.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
      ),
      onDismissed: (direction) {
        // No need to show loader here as provider handles optimistic removal
        provider.removeCustomCategory(category.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).cardColor,
            content: Text('${category.name} deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: listTile,
    );
  }

  void _showAddCategoryDialog(BuildContext context, ExpenseProvider provider) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. Subscriptions, Gym',
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              final name = value.trim().toLowerCase();
              final exists = provider.allCategories.any((cat) => cat.name.toLowerCase() == name);
              if (exists) {
                return 'Category already exists';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                provider.addCustomCategory(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: Text('Add', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
