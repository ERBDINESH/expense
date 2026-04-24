import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final categories = provider.allCategories;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Categories', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isPredefined = predefinedCategories.contains(category);

          Widget listTile = Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.category_rounded, color: Color(0xFF2E7D32), size: 20),
              ),
              title: Text(category, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
              subtitle: Text(
                isPredefined ? 'Default' : 'Custom',
                style: TextStyle(color: isPredefined ? Colors.black26 : const Color(0xFF2E7D32).withOpacity(0.5), fontSize: 12),
              ),
              trailing: isPredefined
                  ? null
                  : const Icon(Icons.swipe_left_rounded, size: 16, color: Colors.black12),
            ),
          );

          if (isPredefined) return listTile;

          return Dismissible(
            key: Key(category),
            direction: DismissDirection.endToStart,
            background: Container(
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            ),
            onDismissed: (direction) {
              provider.removeCategory(category);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.white,
                  content: Text('$category deleted', style: const TextStyle(color: Colors.black87)),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: listTile,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 4,
        onPressed: () => _showAddCategoryDialog(context, provider),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, ExpenseProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Add Category', style: TextStyle(color: Colors.black87)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Category Name',
            hintStyle: const TextStyle(color: Colors.black12),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2E7D32))),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black38)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.addCategory(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
