import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/features/widgets/app_text.dart';

import '../../../../../app/theme/app_spacing.dart';

class CategoryErrorView extends StatelessWidget {
  const CategoryErrorView({required this.message, super.key, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 32),
            AppSpacing.h16,
            AppText(
              text: message,
              textAlign: TextAlign.center,
              fontSize: 15.sp,
            ),
            AppSpacing.h16,
            if (onRetry != null)
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
          ],
        ),
      ),
    );
  }
}
