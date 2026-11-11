import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import 'type_badge.dart';

class TypeSelectionView extends StatelessWidget {
  final List<String> availableTypes;
  final Map<String, String> claimedTypeUsernames;
  final String? mySelectedType;
  final int selectionSeconds;
  final ValueChanged<String> onSelectType;

  const TypeSelectionView({
    super.key,
    required this.availableTypes,
    required this.claimedTypeUsernames,
    required this.mySelectedType,
    required this.selectionSeconds,
    required this.onSelectType,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Pick your type!', style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: AppRadii.pillAll,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer_rounded,
                size: 16,
                color: AppColors.electricYellow,
              ),
              const SizedBox(width: 6),
              Text(
                '$selectionSeconds seconds to choose',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          alignment: WrapAlignment.center,
          children: availableTypes.map((type) {
            final claimedBy = claimedTypeUsernames[type];
            final isMine = mySelectedType == type;
            final isClaimed = claimedBy != null;

            return TypeBadge(
              type: type,
              caption: claimedBy,
              selected: isMine,
              dimmed: isClaimed && !isMine,
              // Disabled once claimed by anyone, OR once I've already
              // claimed a different type myself — matches the backend
              // rule that a player can only hold one type at a time.
              onTap: (isClaimed || mySelectedType != null)
                  ? null
                  : () => onSelectType(type),
            );
          }).toList(),
        ),
      ],
    );
  }
}
