import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../rooms/providers/rooms_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String roomId;
  const BookingScreen({super.key, required this.roomId});
  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _adults = 1;
  int _children = 0;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _requestsCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  CalendarFormat _calFormat = CalendarFormat.month;

  double get _totalPrice {
    if (_checkIn == null || _checkOut == null) return 0;
    final nights = _checkOut!.difference(_checkIn!).inDays;
    return 0; // Will be calculated after room loads
  }

  Future<void> _confirmBooking(double pricePerNight) async {
    if (!_formKey.currentState!.validate()) return;
    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select check-in and check-out dates')));
      return;
    }
    setState(() => _loading = true);
    final nights = _checkOut!.difference(_checkIn!).inDays;
    final total = nights * pricePerNight;
    final user = ref.read(currentUserProvider);
    try {
      await ref.read(supabaseProvider).from('bookings').insert({
        'user_id': user!.id,
        'room_id': widget.roomId,
        'check_in': DateFormat('yyyy-MM-dd').format(_checkIn!),
        'check_out': DateFormat('yyyy-MM-dd').format(_checkOut!),
        'adults': _adults,
        'children': _children,
        'total_price': total,
        'status': 'pending',
        'guest_name': _nameCtrl.text.trim(),
        'guest_email': _emailCtrl.text.trim(),
        'guest_phone': _phoneCtrl.text.trim(),
        'special_requests': _requestsCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking confirmed! 🎉'), backgroundColor: Colors.green));
        context.go('/my-bookings');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(singleRoomProvider(widget.roomId));
    return Scaffold(
      appBar: AppBar(title: const Text('Book Room')),
      body: roomAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (room) {
          final nights = (_checkIn != null && _checkOut != null)
              ? _checkOut!.difference(_checkIn!).inDays
              : 0;
          final total = nights * room.pricePerNight;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Room summary card
                Card(
                  color: AppTheme.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.hotel, color: AppTheme.accent, size: 40),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Room ${room.roomNumber}',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(room.roomType,
                              style: const TextStyle(color: Colors.white70)),
                          Text('₹${room.pricePerNight.toStringAsFixed(0)}/night',
                              style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Select Dates', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  child: TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _checkIn ?? DateTime.now(),
                    calendarFormat: _calFormat,
                    onFormatChanged: (f) => setState(() => _calFormat = f),
                    selectedDayPredicate: (day) =>
                        (_checkIn != null && isSameDay(_checkIn, day)) ||
                        (_checkOut != null && isSameDay(_checkOut, day)),
                    rangeStartDay: _checkIn,
                    rangeEndDay: _checkOut,
                    rangeSelectionMode: RangeSelectionMode.toggledOn,
                    onRangeSelected: (start, end, _) =>
                        setState(() { _checkIn = start; _checkOut = end; }),
                    calendarStyle: const CalendarStyle(
                      rangeHighlightColor: Color(0x331A3C5E),
                      rangeStartDecoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                      rangeEndDecoration: BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                    ),
                  ),
                ),
                if (_checkIn != null && _checkOut != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _DateChip(label: 'Check-In', date: _checkIn!),
                        const Icon(Icons.arrow_forward, color: AppTheme.primary),
                        _DateChip(label: 'Check-Out', date: _checkOut!),
                        _DateChip(label: 'Nights', value: '$nights'),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Text('Guests', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _GuestCounter(
                          label: 'Adults',
                          subtitle: 'Age 13+',
                          value: _adults,
                          max: room.maxAdults,
                          onChanged: (v) => setState(() => _adults = v),
                        ),
                        const Divider(),
                        _GuestCounter(
                          label: 'Children',
                          subtitle: 'Age 2–12',
                          value: _children,
                          max: room.maxChildren,
                          onChanged: (v) => setState(() => _children = v),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Guest Details', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.contains('@') ? null : 'Invalid email',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined)),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _requestsCtrl,
                  decoration: const InputDecoration(labelText: 'Special Requests (optional)', prefixIcon: Icon(Icons.note_outlined)),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                if (nights > 0)
                  Card(
                    color: AppTheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _PriceRow(label: '₹${room.pricePerNight.toStringAsFixed(0)} × $nights nights', value: '₹${total.toStringAsFixed(0)}'),
                          const Divider(),
                          _PriceRow(label: 'Total', value: '₹${total.toStringAsFixed(0)}', bold: true),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loading ? null : () => _confirmBooking(room.pricePerNight),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Confirm Booking', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final DateTime? date;
  final String? value;
  const _DateChip({required this.label, this.date, this.value});
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value ?? DateFormat('dd MMM').format(date!),
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
        ],
      );
}

class _GuestCounter extends StatelessWidget {
  final String label, subtitle;
  final int value, max;
  final ValueChanged<int> onChanged;
  const _GuestCounter({required this.label, required this.subtitle, required this.value, required this.max, required this.onChanged});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ])),
          IconButton(
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: AppTheme.primary,
          ),
          Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline),
            color: AppTheme.primary,
          ),
        ],
      );
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _PriceRow({required this.label, required this.value, this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 16 : 14)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 16 : 14, color: AppTheme.accent)),
        ]),
      );
}