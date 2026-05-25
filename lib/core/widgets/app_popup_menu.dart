import 'package:flutter/material.dart';

class AppPopupMenuItemData {
  final String value;
  final IconData icon;
  final String label;
  final Color color;
  final bool isDestructive;

  const AppPopupMenuItemData({
    required this.value,
    required this.icon,
    required this.label,
    required this.color,
    this.isDestructive = false,
  });
}

class AppPopupMenu extends StatelessWidget {
  final void Function(String) onSelected;
  final List<AppPopupMenuItemData> items;
  final bool isIconWhite;

  const AppPopupMenu({
    super.key,
    required this.onSelected,
    required this.items,
    this.isIconWhite = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: isIconWhite
          ? const Icon(Icons.more_vert, color: Colors.white)
          : Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: const Icon(Icons.more_vert, size: 20, color: Colors.black87),
            ),
      onSelected: onSelected,
      itemBuilder: (context) => items.map((item) {
        return PopupMenuItem<String>(
          value: item.value,
          child: Row(
            children: [
              Icon(item.icon, size: 20, color: item.color),
              const SizedBox(width: 8),
              Text(
                item.label,
                style: item.isDestructive ? TextStyle(color: item.color) : null,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
