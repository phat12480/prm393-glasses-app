import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth_state.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String? from;
  const LoginPage({super.key, this.from});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final ok = await ref
                    .read(authProvider.notifier)
                    .login(emailCtrl.text, passCtrl.text);

                if (ok) {
                  context.go(widget.from ?? '/');
                } else {
                  setState(() => error = 'Sai email hoặc mật khẩu');
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
