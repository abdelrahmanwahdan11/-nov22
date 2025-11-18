import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconly/iconly.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/app_scope.dart';
import '../../shell/shell_page.dart';
import '../login/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static const route = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirm = '';

  String _strengthLabel(AppLocalizations t) {
    if (_password.length >= 10) return t.translate('strength_strong');
    if (_password.length >= 6) return t.translate('strength_ok');
    return t.translate('strength_weak');
  }

  Color _strengthColor() {
    if (_password.length >= 10) return Colors.green;
    if (_password.length >= 6) return Colors.orange;
    return Colors.red;
  }

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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.translate('register'), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
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
                          if (value == null || !value.contains('@')) return t.translate('invalid_email');
                          return null;
                        },
                        onSaved: (v) => _email = v ?? '',
                      ).animate().fadeIn(),
                      const SizedBox(height: 16),
                      StatefulBuilder(
                        builder: (context, setField) => Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: t.translate('password'),
                                prefixIcon: const Icon(IconlyLight.lock),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    _strengthLabel(t),
                                    style: TextStyle(color: _strengthColor()),
                                  ),
                                ),
                              ),
                              obscureText: true,
                              onChanged: (v) => setField(() {
                                _password = v;
                              }),
                              validator: (value) {
                                if (value == null || value.length < 6) return t.translate('password_too_short');
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: (_password.length.clamp(0, 12)) / 12,
                              color: _strengthColor(),
                              backgroundColor: Theme.of(context).dividerColor.withOpacity(0.2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: t.translate('confirm_password'),
                          prefixIcon: const Icon(IconlyLight.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value != _password) return t.translate('passwords_do_not_match');
                          return null;
                        },
                        onSaved: (v) => _confirm = v ?? '',
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: Text(t.translate('register')),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed(LoginPage.route),
                        child: Text(t.translate('login')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
