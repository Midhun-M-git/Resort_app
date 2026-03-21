import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/rooms_provider.dart';
import '../../../core/models/room_model.dart';

final _filterProvider = StateProvider<String>((ref) => 'All');

class RoomsListScreen extends ConsumerWidget {
  const RoomsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);
    final filter = ref.watch(_filterProvider);
    const types = ['All', 'Standard', 'Deluxe', 'Suite', 'Villa', 'Presidential'];

    return Scaffold(
      appBar: AppBar(title: const Text('Our Rooms')),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: types.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(types[i]),
                  selected: filter == types[i],
                  onSelected: (_) =>
                      ref.read(_filterProvider.notifier).state = types[i],
                  selectedColor: AppTheme.accent,
                  labelStyle: TextStyle(
                      color: filter == types[i] ? Colors.white : null,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          Expanded(
            child: roomsAsync.when(
              loading: () => _buildShimmer(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (rooms) {
                final filtered = filter == 'All'
                    ? rooms
                    : rooms.where((r) => r.roomType == filter).toList();
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _RoomCard(room: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
}

class _RoomCard extends StatelessWidget {
  final RoomModel room;
  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/rooms/${room.id}'),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  room.imageUrls.isNotEmpty
                      ? Image.network(room.imageUrls[0],
                          height: 180, width: double.infinity, fit: BoxFit.cover)
                      : Container(
                          height: 180,
                          color: AppTheme.primary.withOpacity(0.1),
                          child: const Icon(Icons.hotel, size: 60, color: AppTheme.primary)),
                  Positioned(
                    top: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: room.isAvailable ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        room.isAvailable ? 'Available' : 'Unavailable',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Room ${room.roomNumber}',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      Text('₹${room.pricePerNight.toStringAsFixed(0)}/night',
                          style: GoogleFonts.lato(
                              fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accent)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(room.roomType,
                      style: GoogleFonts.lato(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text('${room.maxAdults} Adults, ${room.maxChildren} Children',
                          style: GoogleFonts.lato(fontSize: 13)),
                      const SizedBox(width: 12),
                      const Icon(Icons.stairs, size: 16, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text('Floor ${room.floor}',
                          style: GoogleFonts.lato(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    children: room.amenities
                        .take(3)
                        .map((a) => Chip(
                              label: Text(a, style: const TextStyle(fontSize: 11)),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              backgroundColor: AppTheme.surface,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}