import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

final adminStatsProvider = FutureProvider((ref) async {
  final client = ref.watch(supabaseProvider);
  final rooms = await client.from('rooms').select('id, is_available');
  final bookings = await client.from('bookings').select('status, total_price');
  final totalRooms = (rooms as List).length;
  final availableRooms = rooms.where((r) => r['is_available'] == true).length;
  final totalBookings = (bookings as List).length;
  final revenue = bookings.fold<double>(0, (sum, b) => sum + (b['total_price'] as num).toDouble());
  final confirmed = bookings.where((b) => b['status'] == 'confirmed').length;
  final pending = bookings.where((b) => b['status'] == 'pending').length;
  return {
    'totalRooms': totalRooms,
    'availableRooms': availableRooms,
    'totalBookings': totalBookings,
    'revenue': revenue,
    'confirmed': confirmed,
    'pending': pending,
  };
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(adminStatsProvider)),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Overview', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(label: 'Total Rooms', value: '${stats['totalRooms']}', icon: Icons.hotel, color: AppTheme.primary),
                _StatCard(label: 'Available', value: '${stats['availableRooms']}', icon: Icons.check_circle, color: Colors.green),
                _StatCard(label: 'Total Bookings', value: '${stats['totalBookings']}', icon: Icons.book_online, color: AppTheme.accent),
                _StatCard(label: 'Revenue', value: '₹${(stats['revenue'] as double).toStringAsFixed(0)}', icon: Icons.currency_rupee, color: Colors.purple),
              ],
            ),
            const SizedBox(height: 24),
            Text('Booking Status', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: PieChart(PieChartData(
                sections: [
                  PieChartSectionData(value: (stats['confirmed'] as int).toDouble(), title: 'Confirmed\n${stats['confirmed']}', color: Colors.green, radius: 80),
                  PieChartSectionData(value: (stats['pending'] as int).toDouble(), title: 'Pending\n${stats['pending']}', color: Colors.orange, radius: 80),
                ],
                sectionsSpace: 4,
              )),
            ),
            const SizedBox(height: 24),
            Text('Quick Actions', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _AdminActionTile(icon: Icons.hotel, label: 'Manage Rooms', onTap: () => context.push('/admin/rooms')),
            _AdminActionTile(icon: Icons.add_business, label: 'Add New Room', onTap: () => context.push('/admin/rooms/add')),
            _AdminActionTile(icon: Icons.book_online, label: 'All Bookings', onTap: () => context.push('/admin/bookings')),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
        ]),
      );
}

class _AdminActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AdminActionTile({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Icon(icon, color: AppTheme.primary),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      );
}