import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/room_model.dart';
import '../../auth/providers/auth_provider.dart';

final roomsProvider = FutureProvider<List<RoomModel>>((ref) async {
  final client = ref.watch(supabaseProvider);
  final data = await client.from('rooms').select().order('room_number');
  return (data as List).map((e) => RoomModel.fromJson(e)).toList();
});

final availableRoomsProvider =
    FutureProvider.family<bool, ({String roomId, DateTime checkIn, DateTime checkOut})>(
        (ref, args) async {
  final client = ref.watch(supabaseProvider);
  final data = await client.from('bookings').select().eq('room_id', args.roomId).neq('status', 'cancelled');
  final bookings = data as List;
  for (final b in bookings) {
    final bIn = DateTime.parse(b['check_in']);
    final bOut = DateTime.parse(b['check_out']);
    if (args.checkIn.isBefore(bOut) && args.checkOut.isAfter(bIn)) return false;
  }
  return true;
});

final singleRoomProvider = FutureProvider.family<RoomModel, String>((ref, id) async {
  final client = ref.watch(supabaseProvider);
  final data = await client.from('rooms').select().eq('id', id).single();
  return RoomModel.fromJson(data);
});