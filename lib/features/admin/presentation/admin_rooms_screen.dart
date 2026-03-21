import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/room_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../rooms/providers/rooms_provider.dart';

class AdminRoomsScreen extends ConsumerWidget {
  const AdminRoomsScreen({super.key});

  Future<void> _toggleAvailability(WidgetRef ref, RoomModel room) async {
    await ref.read(supabaseProvider).from('rooms').update({'is_available': !room.isAvailable}).eq('id', room.id);
    ref.invalidate(roomsProvider);
  }

  Future<void> _deleteRoom(BuildContext context, WidgetRef ref, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Room?'),
        content: const Text('This will permanently delete this room and all its bookings.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(supabaseProvider).from('rooms').delete().eq('id', id);
      ref.invalidate(roomsProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Rooms')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/rooms/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Room'),
        backgroundColor: AppTheme.accent,
      ),
      body: roomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rooms) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rooms.length,
          itemBuilder: (_, i) {
            final room = rooms[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: room.isAvailable ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                  child: Icon(Icons.hotel, color: room.isAvailable ? Colors.green : Colors.red),
                ),
                title: Text('Room ${room.roomNumber}',
                    style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
                subtitle: Text('${room.roomType} · Floor ${room.floor} · ₹${room.pricePerNight.toStringAsFixed(0)}/night\n${room.isAvailable ? 'Available' : 'Unavailable'}'),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') context.push('/admin/rooms/edit/${room.id}');
                    if (v == 'toggle') _toggleAvailability(ref, room);
                    if (v == 'delete') _deleteRoom(context, ref, room.id);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
                    PopupMenuItem(value: 'toggle', child: ListTile(
                        leading: Icon(room.isAvailable ? Icons.block : Icons.check_circle),
                        title: Text(room.isAvailable ? 'Mark Unavailable' : 'Mark Available'))),
                    const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red)))),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}