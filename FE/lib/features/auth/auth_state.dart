import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/db/db_provider.dart';
import '../../data/local/db/app_db.dart';

class AuthState {
  final User? user;
  const AuthState({this.user});

  bool get isLoggedIn => user != null;
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> login(String email, String password) async {
    final db = ref.read(dbProvider);
    final user = await db.login(email, password);

    if (user != null) {
      state = AuthState(user: user);
      return true;
    }
    return false;
  }

  Future<void> register(String email, String password, String fullName) async {
    final db = ref.read(dbProvider);
    await db.insertUser(
      UsersCompanion.insert(
        email: email,
        password: password,
        fullName: fullName,
      ),
    );
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
