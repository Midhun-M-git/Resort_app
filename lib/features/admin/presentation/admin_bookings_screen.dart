import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

final allBookingsProvider = FutureProvider((ref) async {
  final data = await ref.watch(supabaseProvider)
      .from('bookings')
      .select('*, rooms(*), profiles(*)')
      .order('created_at', ascending: false);
  return data as List;
});

class AdminBookingsScreen extends ConsumerWidget {
  const AdminBookingsScreen({super.key});

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Future<void> _updateStatus(WidgetRef ref, BuildContext context, String bookingId, String status) async {
    await ref.read(supabaseProvider).from('bookings').update({'status': status}).eq('id', bookingId);
    ref.invalidate(allBookingsProvider);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated to $status'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(allBookingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('All Bookings')),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (bookings) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (_, i) {
            final b = bookings[i];
            final room = b['rooms'];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: _statusColor(b['status']).withOpacity(0.15),
                  child: Text(b['status'][0].toUpperCase(), style: TextStyle(color: _statusColor(b['status']), fontWeight: FontWeight.bold)),
                ),
                title: Text('Room ${room?['room_number'] ?? 'N/A'} — ${b['guest_name']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${DateFormat('dd MMM').format(DateTime.parse(b['check_in']))} → ${DateFormat('dd MMM yyyy').format(DateTime.parse(b['check_out']))}  · ₹${b['total_price']}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _InfoLine('Email', b['guest_email']),
                      _InfoLine('Phone', b['guest_phone'] ?? 'N/A'),
                      _InfoLine('Adults', '${b['adults']}'),
                      _InfoLine('Children', '${b['children']}'),
                      if (b['special_requests'] != null && b['special_requests'].isNotEmpty)
                        _InfoLine('Requests', b['special_requests']),
                      const SizedBox(height: 12),
                      Text('Update Status', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, children: ['pending', 'confirmed', 'completed', 'cancelled'].map((s) =>
                        ElevatedButton(
                          onPressed: b['status'] == s ? null : () => _updateStatus(ref, context, b['id'], s),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: b['status'] == s ? _statusColor(s) : _statusColor(s).withOpacity(0.2),
                            foregroundColor: b['status'] == s ? Colors.white : _statusColor(s),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text(s.toUpperCase(), style: const TextStyle(fontSize: 11)),
                        )).toList()),
                    ]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label, value;
  const _InfoLine(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary)),
          Expanded(child: Text(value)),
        ]),
      );
}