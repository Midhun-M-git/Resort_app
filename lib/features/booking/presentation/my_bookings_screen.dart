import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/booking_model.dart';
import '../../auth/providers/auth_provider.dart';

final myBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final data = await ref.watch(supabaseProvider)
      .from('bookings')
      .select('*, rooms(*)')
      .eq('user_id', user.id)
      .order('created_at', ascending: false);
  return (data as List).map((e) => BookingModel.fromJson(e)).toList();
});

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (bookings) => bookings.isEmpty
            ? Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.hotel, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No bookings yet', style: GoogleFonts.playfairDisplay(fontSize: 20, color: Colors.grey)),
                ]),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                itemBuilder: (_, i) {
                  final b = bookings[i];
                  final roomData = b.room;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(
                            'Room ${roomData?['room_number'] ?? 'N/A'}',
                            style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(b.status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _statusColor(b.status)),
                            ),
                            child: Text(b.status.toUpperCase(),
                                style: TextStyle(color: _statusColor(b.status), fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ]),
                        Text(roomData?['room_type'] ?? '', style: GoogleFonts.lato(color: Colors.grey[600])),
                        const Divider(height: 20),
                        Row(children: [
                          Expanded(child: _BookingInfo(icon: Icons.login, label: 'Check-In',
                              value: DateFormat('dd MMM yyyy').format(b.checkIn))),
                          Expanded(child: _BookingInfo(icon: Icons.logout, label: 'Check-Out',
                              value: DateFormat('dd MMM yyyy').format(b.checkOut))),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(child: _BookingInfo(icon: Icons.people, label: 'Guests',
                              value: '${b.adults} Adults, ${b.children} Children')),
                          Expanded(child: _BookingInfo(icon: Icons.nights_stay, label: 'Nights',
                              value: '${b.nights}')),
                        ]),
                        const Divider(height: 20),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Total', style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
                          Text('₹${b.totalPrice.toStringAsFixed(0)}',
                              style: GoogleFonts.playfairDisplay(fontSize: 18, color: AppTheme.accent, fontWeight: FontWeight.bold)),
                        ]),
                      ]),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _BookingInfo extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _BookingInfo({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 6),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ])),
      ]);
}