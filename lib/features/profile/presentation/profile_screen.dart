import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(children: [
                const CircleAvatar(radius: 50, backgroundColor: AppTheme.primary,
                    child: Icon(Icons.person, size: 50, color: Colors.white)),
                const SizedBox(height: 16),
                Text(profile?['name'] ?? '', style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(profile?['email'] ?? '', style: TextStyle(color: Colors.grey[600])),
                if (profile?['role'] == 'admin')
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(20)),
                    child: const Text('ADMIN', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ]),
            ),
            const SizedBox(height: 32),
            Card(child: Column(children: [
              ListTile(leading: const Icon(Icons.person, color: AppTheme.primary), title: const Text('Name'), subtitle: Text(profile?['name'] ?? '')),
              const Divider(height: 1),
              ListTile(leading: const Icon(Icons.email, color: AppTheme.primary), title: const Text('Email'), subtitle: Text(profile?['email'] ?? '')),
              const Divider(height: 1),
              ListTile(leading: const Icon(Icons.phone, color: AppTheme.primary), title: const Text('Phone'), subtitle: Text(profile?['phone'] ?? 'Not set')),
            ])),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref.read(authProvider.notifier).logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}