import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';

class AdminFilterDropdown<T> extends StatelessWidget {
  final T value;
  final void Function(T?)? onChanged;
  final List<DropdownMenuItem<T>> items;

  const AdminFilterDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
          style: AppTextStyles.body,
          onChanged: onChanged,
          items: items,
        ),
      ),
    );
  }
}

class AdminSearchFilterBar extends StatelessWidget {
  final TextEditingController? searchController;
  final String searchHint;
  final Function(String) onSearchChanged;
  
  // Single default filter
  final String? filterValue;
  final Function(String?)? onFilterChanged;
  final List<DropdownMenuItem<String>>? filterItems;
  
  // Extra custom filters
  final List<Widget>? extraFilters;

  const AdminSearchFilterBar({
    super.key,
    this.searchController,
    required this.searchHint,
    required this.onSearchChanged,
    this.filterValue,
    this.onFilterChanged,
    this.filterItems,
    this.extraFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: searchHint,
                border: InputBorder.none,
                isDense: true,
              ),
              style: AppTextStyles.body,
            ),
          ),
          if (filterItems != null)
            AdminFilterDropdown<String>(
              value: filterValue!,
              onChanged: onFilterChanged,
              items: filterItems!,
            ),
          if (extraFilters != null)
            ...extraFilters!.map((w) => Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: w,
                )),
        ],
      ),
    );
  }
}
