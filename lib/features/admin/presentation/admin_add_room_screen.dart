import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../rooms/providers/rooms_provider.dart';

class AdminAddRoomScreen extends ConsumerStatefulWidget {
  final String? roomId;
  const AdminAddRoomScreen({super.key, this.roomId});
  @override
  ConsumerState<AdminAddRoomScreen> createState() => _AdminAddRoomScreenState();
}

class _AdminAddRoomScreenState extends ConsumerState<AdminAddRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumberCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _amenityCtrl = TextEditingController();
  String _roomType = 'Standard';
  int _maxAdults = 2;
  int _maxChildren = 2;
  bool _isAvailable = true;
  List<String> _amenities = [];
  bool _loading = false;
  bool _isEdit = false;

  final _roomTypes = ['Standard', 'Deluxe', 'Suite', 'Villa', 'Presidential'];

  @override
  void initState() {
    super.initState();
    if (widget.roomId != null) {
      _isEdit = true;
      _loadRoom();
    }
  }

  Future<void> _loadRoom() async {
    final data = await ref.read(supabaseProvider).from('rooms').select().eq('id', widget.roomId!).single();
    setState(() {
      _roomNumberCtrl.text = data['room_number'];
      _floorCtrl.text = data['floor'].toString();
      _priceCtrl.text = data['price_per_night'].toString();
      _descCtrl.text = data['description'] ?? '';
      _roomType = data['room_type'];
      _maxAdults = data['max_adults'];
      _maxChildren = data['max_children'];
      _isAvailable = data['is_available'];
      _amenities = List<String>.from(data['amenities'] ?? []);
    });
  }

  void _addAmenity() {
    if (_amenityCtrl.text.isNotEmpty) {
      setState(() { _amenities.add(_amenityCtrl.text.trim()); _amenityCtrl.clear(); });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'room_number': _roomNumberCtrl.text.trim(),
      'room_type': _roomType,
      'floor': int.parse(_floorCtrl.text),
      'price_per_night': double.parse(_priceCtrl.text),
      'max_adults': _maxAdults,
      'max_children': _maxChildren,
      'description': _descCtrl.text.trim(),
      'amenities': _amenities,
      'is_available': _isAvailable,
    };
    try {
      if (_isEdit) {
        await ref.read(supabaseProvider).from('rooms').update(data).eq('id', widget.roomId!);
      } else {
        await ref.read(supabaseProvider).from('rooms').insert(data);
      }
      ref.invalidate(roomsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEdit ? 'Room updated!' : 'Room added!'), backgroundColor: Colors.green));
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Room' : 'Add New Room')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Room Details', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: TextFormField(
                controller: _roomNumberCtrl,
                decoration: const InputDecoration(labelText: 'Room Number', prefixIcon: Icon(Icons.tag)),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              )),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(
                controller: _floorCtrl,
                decoration: const InputDecoration(labelText: 'Floor', prefixIcon: Icon(Icons.stairs)),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              )),
            ]),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _roomType,
              decoration: const InputDecoration(labelText: 'Room Type', prefixIcon: Icon(Icons.hotel)),
              items: _roomTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _roomType = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceCtrl,
              decoration: const InputDecoration(labelText: 'Price per Night (₹)', prefixIcon: Icon(Icons.currency_rupee)),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            Text('Capacity', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Max Adults', style: TextStyle(fontWeight: FontWeight.w600)),
                Row(children: [
                  IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: _maxAdults > 1 ? () => setState(() => _maxAdults--) : null),
                  Text('$_maxAdults', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => _maxAdults++)),
                ]),
              ]),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Max Children', style: TextStyle(fontWeight: FontWeight.w600)),
                Row(children: [
                  IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: _maxChildren > 0 ? () => setState(() => _maxChildren--) : null),
                  Text('$_maxChildren', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => _maxChildren++)),
                ]),
              ]),
            ]))),
            const SizedBox(height: 20),
            Text('Amenities', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextFormField(controller: _amenityCtrl, decoration: const InputDecoration(labelText: 'Add Amenity (e.g. WiFi)'))),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _addAmenity, child: const Icon(Icons.add)),
            ]),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 4,
              children: _amenities.map((a) => Chip(
                    label: Text(a),
                    onDeleted: () => setState(() => _amenities.remove(a)),
                  )).toList(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description)),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Available for Booking', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(_isAvailable ? 'Room is available' : 'Room is unavailable'),
              value: _isAvailable,
              onChanged: (v) => setState(() => _isAvailable = v),
              activeColor: AppTheme.accent,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_isEdit ? 'Update Room' : 'Add Room', style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}