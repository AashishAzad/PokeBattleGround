import 'package:flutter/material.dart';

class DifficultySelector extends StatelessWidget {
  final ValueChanged<String> onSelect;

  const DifficultySelector({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Choose a difficulty',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _DifficultyCard(
          label: 'Easy',
          subtitle: '3 types · up to 3 players',
          color: Colors.green,
          onTap: () => onSelect('easy'),
        ),
        const SizedBox(height: 12),
        _DifficultyCard(
          label: 'Medium',
          subtitle: '6 types · up to 6 players',
          color: Colors.orange,
          onTap: () => onSelect('medium'),
        ),
        const SizedBox(height: 12),
        _DifficultyCard(
          label: 'Hard',
          subtitle: '10 types · up to 10 players',
          color: Colors.redAccent,
          onTap: () => onSelect('hard'),
        ),
      ],
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        color: color.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color, width: 2),
        ),
        child: ListTile(
          onTap: onTap,
          title: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          subtitle: Text(subtitle),
          trailing: Icon(Icons.arrow_forward_ios, color: color, size: 16),
        ),
      ),
    );
  }
}
