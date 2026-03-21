import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/rooms_provider.dart';

class RoomDetailScreen extends ConsumerWidget {
  final String roomId;
  const RoomDetailScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(singleRoomProvider(roomId));

    return roomAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (room) => Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('Room ${room.roomNumber}',
                    style: const TextStyle(color: Colors.white)),
                background: room.imageUrls.isNotEmpty
                    ? Image.network(room.imageUrls[0], fit: BoxFit.cover)
                    : Container(color: AppTheme.primary,
                        child: const Icon(Icons.hotel, size: 100, color: Colors.white30)),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(room.roomType,
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                          Text('Floor ${room.floor}',
                              style: GoogleFonts.lato(color: Colors.grey[600])),
                        ]),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('₹${room.pricePerNight.toStringAsFixed(0)}',
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.accent)),
                          Text('per night', style: GoogleFonts.lato(color: Colors.grey[600])),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(icon: Icons.people, label: 'Max Adults', value: '${room.maxAdults}'),
                    _InfoRow(icon: Icons.child_care, label: 'Max Children', value: '${room.maxChildren}'),
                    _InfoRow(
                      icon: Icons.circle,
                      label: 'Status',
                      value: room.isAvailable ? 'Available' : 'Unavailable',
                      valueColor: room.isAvailable ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 20),
                    Text('Description',
                        style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(room.description, style: GoogleFonts.lato(fontSize: 14, height: 1.6)),
                    const SizedBox(height: 20),
                    Text('Amenities',
                        style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: room.amenities.map((a) => Chip(
                            label: Text(a),
                            backgroundColor: AppTheme.surface,
                            avatar: const Icon(Icons.check_circle, color: AppTheme.accent, size: 18),
                          )).toList(),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: room.isAvailable
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => context.push('/booking/${room.id}'),
                    child: const Text('Book This Room', style: TextStyle(fontSize: 18)),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;
  const _InfoRow({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primary),
            const SizedBox(width: 10),
            Text('$label: ', style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
            Text(value,
                style: GoogleFonts.lato(color: valueColor ?? AppTheme.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      );
}