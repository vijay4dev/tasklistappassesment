import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklistapp/auth/auth_services.dart';
import 'package:tasklistapp/widgets/commonwidgets.dart';

import '../utils/validators.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscure = true;
  bool _obscureConfirm = true;

  bool _success = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {

    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthService>();

    final success = await auth.signUp(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      fullName: _nameCtrl.text.trim(),
    );

    if (success && mounted) {
      setState(() => _success = true);
    }
  }

  @override
  Widget build(BuildContext context) {

    final auth = context.watch<AuthService>();

    if (_success) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(Icons.mark_email_read, size: 80),

              const SizedBox(height: 20),

              const Text("Check your email"),

              const SizedBox(height: 10),

              Text(_emailCtrl.text),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back to login"),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("Create Account")),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              AppTextField(
                controller: _nameCtrl,
                label: "Full name",
                validator: Validators.fullName,
                obscureText: false,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {},
                ),
              ),

              const SizedBox(height: 16),

              AppTextField(
                controller: _emailCtrl,
                label: "Email",
                validator: Validators.email,
                obscureText: false,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.email),
                  onPressed: () {},
                ),
              ),

              const SizedBox(height: 16),

              AppTextField(
                controller: _passCtrl,
                label: "Password",
                obscureText: _obscure,
                validator: Validators.password,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscure = !_obscure),
                ),
              ),

              const SizedBox(height: 16),

              AppTextField(
                controller: _confirmCtrl,
                label: "Confirm Password",
                obscureText: _obscureConfirm,
                validator: (v) =>
                    Validators.confirmPassword(
                        v, _passCtrl.text),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() =>
                          _obscureConfirm = !_obscureConfirm),
                ),
              ),

              const SizedBox(height: 30),

              LoadingButton(
                text: "Create Account",
                loading: auth.isLoading,
                onPressed: _signup,
              ),

              if (auth.error != null) ...[
                const SizedBox(height: 16),
                Text(auth.error!,
                    style: const TextStyle(color: Colors.red)),
              ],

              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Already have account? Sign in"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}