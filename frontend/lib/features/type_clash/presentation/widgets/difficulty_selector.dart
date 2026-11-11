import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';

class DifficultySelector extends StatelessWidget {
  final ValueChanged<String> onSelect;

  const DifficultySelector({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return EntranceAnimation(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose a difficulty',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            alignment: WrapAlignment.center,
            children: [
              OptionCard(
                title: 'Easy',
                subtitle: '3 types · up to 3 players',
                icon: Icons.eco_rounded,
                color: AppColors.leafGreen,
                width: 260,
                onTap: () => onSelect('easy'),
              ),
              OptionCard(
                title: 'Medium',
                subtitle: '6 types · up to 6 players',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.sunsetOrange,
                width: 260,
                onTap: () => onSelect('medium'),
              ),
              OptionCard(
                title: 'Hard',
                subtitle: '10 types · up to 10 players',
                icon: Icons.whatshot_rounded,
                color: AppColors.pokeRed,
                width: 260,
                onTap: () => onSelect('hard'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
