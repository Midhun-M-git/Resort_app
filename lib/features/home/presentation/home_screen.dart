import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final isAdminAsync = ref.watch(isAdminProvider);

    return Scaffold(
      drawer: _AppDrawer(isAdminAsync: isAdminAsync, profileAsync: profileAsync),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Paradise Resort', style: GoogleFonts.playfairDisplay(color: Colors.white)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary, Color(0xFF2D6A9F), AppTheme.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  const Center(child: Icon(Icons.beach_access, size: 100, color: Colors.white24)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  profileAsync.when(
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                    data: (p) => Text(
                      'Welcome, ${p?['name'] ?? 'Guest'}!',
                      style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Where would you like to go today?',
                      style: GoogleFonts.lato(color: Colors.grey[600])),
                  const SizedBox(height: 24),
                  // Quick actions
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _QuickAction(icon: Icons.hotel, label: 'Browse Rooms', color: AppTheme.primary,
                          onTap: () => context.push('/rooms')),
                      _QuickAction(icon: Icons.book_online, label: 'My Bookings', color: AppTheme.accent,
                          onTap: () => context.push('/my-bookings')),
                      _QuickAction(icon: Icons.person, label: 'My Profile', color: const Color(0xFF2D6A9F),
                          onTap: () => context.push('/profile')),
                      isAdminAsync.when(
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                        data: (isAdmin) => isAdmin
                            ? _QuickAction(icon: Icons.admin_panel_settings, label: 'Admin Panel', color: Colors.purple,
                                onTap: () => context.push('/admin'))
                            : _QuickAction(icon: Icons.support_agent, label: 'Support', color: Colors.teal,
                                onTap: () {}),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text('Why Choose Us', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...[
                    ('🏊', 'Infinity Pool', 'Overlooking the ocean with panoramic views'),
                    ('🍽️', 'Fine Dining', '5-star cuisine from world-class chefs'),
                    ('💆', 'Wellness Spa', 'Rejuvenate with luxury treatments'),
                    ('🏋️', 'Fitness Center', 'State-of-the-art equipment 24/7'),
                  ].map((f) => _FeatureCard(emoji: f.$1, title: f.$2, desc: f.$3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
        ),
      );
}

class _FeatureCard extends StatelessWidget {
  final String emoji, title, desc;
  const _FeatureCard({required this.emoji, required this.title, required this.desc});
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Text(emoji, style: const TextStyle(fontSize: 28)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(desc),
        ),
      );
}

class _AppDrawer extends ConsumerWidget {
  final AsyncValue<bool> isAdminAsync;
  final AsyncValue profileAsync;
  const _AppDrawer({required this.isAdminAsync, required this.profileAsync});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Drawer(
        child: Column(children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primary),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
              const CircleAvatar(radius: 30, backgroundColor: AppTheme.accent, child: Icon(Icons.person, color: Colors.white, size: 36)),
              const SizedBox(height: 8),
              profileAsync.when(
                loading: () => const Text('Loading...', style: TextStyle(color: Colors.white)),
                error: (_, __) => const SizedBox(),
                data: (p) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p?['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(p?['email'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ),
            ]),
          ),
          ListTile(leading: const Icon(Icons.home), title: const Text('Home'), onTap: () { context.go('/'); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.hotel), title: const Text('Browse Rooms'), onTap: () { context.push('/rooms'); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.book_online), title: const Text('My Bookings'), onTap: () { context.push('/my-bookings'); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.person), title: const Text('Profile'), onTap: () { context.push('/profile'); Navigator.pop(context); }),
          isAdminAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (isAdmin) => isAdmin
                ? ListTile(leading: const Icon(Icons.admin_panel_settings, color: Colors.purple), title: const Text('Admin Panel'), onTap: () { context.push('/admin'); Navigator.pop(context); })
                : const SizedBox(),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => ref.read(authProvider.notifier).logout(),
          ),
          const SizedBox(height: 16),
        ]),
      );
}