import 'package:flutter/material.dart';
import 'package:tasklistapp/app/app_theme.dart';

/// ───── Loading Button ─────
class LoadingButton extends StatelessWidget {

  final String text;
  final bool loading;
  final VoidCallback? onPressed;

  const LoadingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {

    return ElevatedButton(
      onPressed: loading ? null : onPressed,

      child: loading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(text),
    );
  }
}

/// ───── Gradient Card ─────
class GradientCard extends StatelessWidget {

  final Widget child;

  const GradientCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            const Color(0xFF8B85FF),
          ],
        ),

        borderRadius: BorderRadius.circular(16),
      ),

      child: child,
    );
  }
}

/// ───── Empty State ─────
class EmptyState extends StatelessWidget {

  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          Icon(icon, size: 60, color: AppTheme.primaryColor),

          const SizedBox(height: 20),

          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(subtitle),
        ],
      ),
    );
  }
}

/// ───── App Text Field ─────
class AppTextField extends StatelessWidget {

  final TextEditingController controller;
  final String label;
  final bool obscure;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscure = false,
    this.validator, required bool obscureText, required IconButton suffixIcon,
  });

  @override
  Widget build(BuildContext context) {

    return TextFormField(
      controller: controller,
      obscureText: obscure,

      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }
}

/// ───── Priority Badge ─────
class PriorityBadge extends StatelessWidget {

  final String priority;

  const PriorityBadge({
    super.key,
    required this.priority,
  });

  Color get color {

    switch (priority) {

      case "high":
        return Colors.red;

      case "medium":
        return Colors.orange;

      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),

      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}