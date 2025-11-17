import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../../core/localization/app_localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  static const route = '/forgot-password';

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('reset_instructions'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('forgot_password'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.translate('reset_instructions'), style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: t.translate('email'),
                  prefixIcon: const Icon(IconlyLight.message),
                ),
                validator: (value) {
                  if (value == null || !value.contains('@')) return t.translate('invalid_email');
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(t.translate('reset_password')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
