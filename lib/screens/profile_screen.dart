import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/export_service.dart';
import '../providers/expense_provider.dart';
import 'category_list_screen.dart';
import 'login_screen.dart';
import 'fixed_costs_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showExportDialog(BuildContext context) {
    int selectedMonth = DateTime.now().month;
    int selectedYear = DateTime.now().year;
    ExportFormat selectedFormat = ExportFormat.pdf;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('Export Report'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        isExpanded: true,
                        dropdownColor: Theme.of(context).cardColor,
                        value: selectedMonth,
                        decoration: const InputDecoration(
                          labelText: 'Month',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: List.generate(12, (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(
                            DateFormat('MMM').format(DateTime(2024, index + 1)),
                            style: const TextStyle(fontSize: 14),
                          ),
                        )),
                        onChanged: (v) => setDialogState(() => selectedMonth = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        isExpanded: true,
                        dropdownColor: Theme.of(context).cardColor,
                        value: selectedYear,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: List.generate(5, (index) => DropdownMenuItem(
                          value: DateTime.now().year - index,
                          child: Text(
                            (DateTime.now().year - index).toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        )),
                        onChanged: (v) => setDialogState(() => selectedYear = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Format', style: TextStyle(fontSize: 12, color: Colors.white54)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _FormatChip(
                      label: 'PDF',
                      isSelected: selectedFormat == ExportFormat.pdf,
                      onTap: () => setDialogState(() => selectedFormat = ExportFormat.pdf),
                    ),
                    const SizedBox(width: 8),
                    _FormatChip(
                      label: 'Excel',
                      isSelected: selectedFormat == ExportFormat.csv,
                      onTap: () => setDialogState(() => selectedFormat = ExportFormat.csv),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(100, 45)),
              onPressed: () async {
                final provider = context.read<ExpenseProvider>();
                Navigator.pop(context);
                
                try {
                  await ExportService.exportData(
                    transactions: provider.transactions,
                    month: selectedMonth,
                    year: selectedYear,
                    format: selectedFormat,
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
              child: const Text('Export'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDailyLimitDialog(BuildContext context, ExpenseProvider provider) {
    final controller = TextEditingController(text: provider.dailyLimit.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Set Daily Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Daily Limit (₹)',
            hintText: 'e.g. 500',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 45)),
            onPressed: () {
              final limit = double.tryParse(controller.text);
              if (limit != null && limit > 0) {
                provider.updateDailyLimit(limit);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).cardColor,
                    backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: user?.photoURL == null
                        ? Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.primary)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  user?.displayName ?? 'User Name',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'user@example.com',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          _buildProfileSection(
            context: context,
            title: 'Account Settings',
            items: [
              _ProfileItem(
                icon: Icons.category_outlined,
                title: 'Categories',
                subtitle: 'Manage your expense categories',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CategoryListScreen()),
                  );
                },
              ),
              _ProfileItem(
                icon: Icons.file_download_outlined,
                title: 'Export Report',
                subtitle: 'Download PDF or CSV reports',
                onTap: () => _showExportDialog(context),
              ),
              _ProfileItem(
                icon: Icons.track_changes_rounded,
                title: 'Daily Budget',
                subtitle: 'Set your daily spending limit',
                onTap: () => _showDailyLimitDialog(context, provider),
              ),
              _ProfileItem(
                icon: Icons.receipt_outlined,
                title: 'Fixed Costs (EMI)',
                subtitle: 'Manage upcoming recurring payments',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FixedCostsScreen()),
                  );
                },
              ),
              _ProfileItem(
                icon: Icons.settings_outlined,
                title: 'General Settings',
                onTap: () {},
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildProfileSection(
            context: context,
            title: 'Support',
            items: [
              _ProfileItem(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                onTap: () {},
              ),
              _ProfileItem(
                icon: Icons.info_outline_rounded,
                title: 'About App',
                onTap: () {},
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Logout Button
          GestureDetector(
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await authService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Logout Account',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileSection({required BuildContext context, required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }
}

class _FormatChip extends StatelessWidget {
  const _FormatChip({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)) : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
    );
  }
}
