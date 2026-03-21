import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider((ref) => Supabase.instance.client);

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseProvider).auth.onAuthStateChange;
});

final currentUserProvider = Provider((ref) {
  return ref.watch(supabaseProvider).auth.currentUser;
});

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
    (ref) => AuthNotifier(ref.watch(supabaseProvider)));

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseClient _client;
  AuthNotifier(this._client) : super(const AsyncValue.data(null));

  Future<void> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}

final profileProvider = FutureProvider((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final data = await ref
      .watch(supabaseProvider)
      .from('profiles')
      .select()
      .eq('id', user.id)
      .single();
  return data;
});

final isAdminProvider = FutureProvider<bool>((ref) async {
  final profile = await ref.watch(profileProvider.future);
  return profile?['role'] == 'admin';
});