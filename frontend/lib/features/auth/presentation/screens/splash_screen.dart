import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';

/// Shown while the stored session is being restored on launch.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlassScaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PokeBallLoader(size: 88),
            SizedBox(height: AppSpacing.lg),
            BrandTitle(),
          ],
        ),
      ),
    );
  }
}
