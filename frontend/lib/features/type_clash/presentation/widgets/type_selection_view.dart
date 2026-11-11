import 'package:flutter/material.dart';

import 'type_colors.dart';

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Pick your type!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          '$selectionSeconds seconds to choose',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: availableTypes.map((type) {
            final claimedBy = claimedTypeUsernames[type];
            final isMine = mySelectedType == type;
            final isClaimed = claimedBy != null;

            return _TypeBubble(
              type: type,
              claimedBy: claimedBy,
              isMine: isMine,
              isClaimed: isClaimed,
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

class _TypeBubble extends StatelessWidget {
  final String type;
  final String? claimedBy;
  final bool isMine;
  final bool isClaimed;
  final VoidCallback? onTap;

  const _TypeBubble({
    required this.type,
    required this.claimedBy,
    required this.isMine,
    required this.isClaimed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isMine
        ? Colors.green
        : isClaimed
        ? Colors.grey
        : colorForType(type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(isClaimed && !isMine ? 0.3 : 0.85),
            border: Border.all(color: color, width: 3),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _capitalize(type),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (claimedBy != null)
                Text(
                  claimedBy!,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
