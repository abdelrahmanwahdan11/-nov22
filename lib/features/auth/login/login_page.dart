import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconly/iconly.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/app_scope.dart';
import '../../shell/shell_page.dart';
import '../forgot_password/forgot_password_page.dart';
import '../register/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const route = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      await AppScope.of(context).setLoggedIn(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(ShellPage.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.translate('login_welcome'), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: t.translate('email'),
                        prefixIcon: const Icon(IconlyLight.message),
                      ),
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return t.translate('invalid_email');
                        }
                        return null;
                      },
                      onSaved: (v) => _email = v ?? '',
                    ).animate().fadeIn(duration: const Duration(milliseconds: 250)).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: t.translate('password'),
                        prefixIcon: const Icon(IconlyLight.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return t.translate('password_too_short');
                        }
                        return null;
                      },
                      onSaved: (v) => _password = v ?? '',
                    ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pushNamed(ForgotPasswordPage.route),
                        child: Text(t.translate('forgot_password')),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: Text(t.translate('login')),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(ShellPage.route);
                        },
                        child: Text(t.translate('login_as_guest')),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed(RegisterPage.route),
                      child: Text(t.translate('register')),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
