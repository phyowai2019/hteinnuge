// lib/screens/login/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose(); _userCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_userCtrl.text.trim(), _passCtrl.text.trim());
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Login မအောင်မြင်ပါ',
          style: const TextStyle(fontFamily: 'Padauk')),
        backgroundColor: AppTheme.danger,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary, Color(0xFF2d5f9e)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  // Logo
                  const Text('🏫', style: TextStyle(fontSize: 72)),
                  const SizedBox(height: 12),
                  const Text('မူလတန်းကျောင်း',
                    style: TextStyle(color: Colors.white, fontSize: 22,
                      fontFamily: 'Padauk', fontWeight: FontWeight.w700)),
                  const Text('စီမံခန့်ခွဲမှု စနစ်',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Padauk')),
                  const SizedBox(height: 40),
                  // Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15),
                        blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      const Text('ဝင်ရောက်ရန်',
                        style: TextStyle(fontSize: 20, fontFamily: 'Padauk',
                          fontWeight: FontWeight.w700, color: AppTheme.textMain)),
                      const SizedBox(height: 20),
                      // Username
                      TextField(
                        controller: _userCtrl,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        onSubmitted: (_) => _login(),
                      ),
                      const SizedBox(height: 14),
                      // Password
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        onSubmitted: (_) => _login(),
                      ),
                      const SizedBox(height: 24),
                      // Button
                      ElevatedButton(
                        onPressed: auth.loading ? null : _login,
                        child: auth.loading
                          ? const SizedBox(height: 20, width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('🔐 ဝင်ရောက်မည်',
                              style: TextStyle(fontFamily: 'Padauk', fontSize: 16)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  const Text('School Management System v1.0',
                    style: TextStyle(color: Colors.white38, fontSize: 11)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
