import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';

Widget buildField({
  required String label,
  required String hint,
  required TextEditingController controller,
  required TextInputType keyboardType,
  required TextInputAction textInputAction,
  required IconData icon,
  required String hintText,
  void Function(String)? onSubmitted,
  void Function()? clearError,
  TextCapitalization textCapitalization = TextCapitalization.none,
  required BuildContext context,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            hint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.goldDeep,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: (value) => clearError?.call(),
        onSubmitted: onSubmitted,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.ivory,
          prefixIcon: Icon(icon, color: AppColors.teal),
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.muted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );
}

