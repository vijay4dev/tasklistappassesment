import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasklistapp/auth/auth_services.dart';
import 'package:tasklistapp/widgets/commonwidgets.dart';

import '../utils/validators.dart';

import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {

    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthService>();

    await auth.signIn(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {

    final auth = context.watch<AuthService>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                const Icon(Icons.check_circle, size: 70),

                const SizedBox(height: 30),

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

                const SizedBox(height: 24),

                if (auth.error != null)
                  Text(auth.error!,
                      style: const TextStyle(color: Colors.red)),

                const SizedBox(height: 16),

                LoadingButton(
                  text: "Sign In",
                  loading: auth.isLoading,
                  onPressed: _login,
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupScreen(),
                      ),
                    );
                  },
                  child: const Text("Create account"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}