// screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:uni_links/uni_links.dart';

class ResetPasswordScreen extends StatefulWidget {
  final VoidCallback onLogin;
  const ResetPasswordScreen({super.key, required this.onLogin});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _token = '';
  String _password = '';
  bool _loading = false;
  String? _error;
  String? _success;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _handleInitialDeepLink();
  }

  Future<void> _handleInitialDeepLink() async {
    final link = await getInitialLink();
    if (link != null && link.contains('reset-password?token=')) {
      setState(() {
        _token = Uri.parse(link).queryParameters['token'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Branding/logo
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: FlutterLogo(size: 64),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Reset Token'),
                  initialValue: _token,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter token' : null,
                  onSaved: (v) => _token = v ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter new password';
                    if (v.length < 8)
                      return 'Password must be at least 8 characters';
                    if (!RegExp(r'[A-Z]').hasMatch(v))
                      return 'Include an uppercase letter';
                    if (!RegExp(r'[a-z]').hasMatch(v))
                      return 'Include a lowercase letter';
                    if (!RegExp(r'[0-9]').hasMatch(v))
                      return 'Include a number';
                    if (!RegExp(r'[!@#\$&*~]').hasMatch(v))
                      return 'Include a special character';
                    return null;
                  },
                  onSaved: (v) => _password = v ?? '',
                ),
                const SizedBox(height: 24),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                ],
                if (_success != null) ...[
                  Text(_success!, style: const TextStyle(color: Colors.green)),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _reset,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Reset Password'),
                  ),
                ),
                TextButton(
                  onPressed: widget.onLogin,
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _reset() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .resetPassword(_token, _password);
      setState(() {
        _success = 'Password reset successful!';
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
