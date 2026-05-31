import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Lớp Data Source dùng chung cho mọi bảng dữ liệu Admin
class AdminDataSource<T> extends DataTableSource {
  final List<T> data;
  final DataRow Function(int index, T item) buildRow;

  AdminDataSource({
    required this.data,
    required this.buildRow,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    return buildRow(index, data[index]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

class AdminPaginatedTable<T> extends StatefulWidget {
  final String? title;
  final List<DataColumn> columns;
  final AdminDataSource<T> source;
  final Widget? headerActions;
  final int rowsPerPage;
  final bool isLoading;
  
  // New props for Server-side pagination
  final int? serverSideTotalElements;
  final int? serverSideCurrentPage;
  final ValueChanged<int>? onPageChanged;

  const AdminPaginatedTable({
    super.key,
    this.title,
    required this.columns,
    required this.source,
    this.headerActions,
    this.rowsPerPage = 10,
    this.isLoading = false,
    this.serverSideTotalElements,
    this.serverSideCurrentPage,
    this.onPageChanged,
  });

  @override
  State<AdminPaginatedTable<T>> createState() => _AdminPaginatedTableState<T>();
}

class _AdminPaginatedTableState<T> extends State<AdminPaginatedTable<T>> {
  int _currentPage = 0;

  @override
  void didUpdateWidget(covariant AdminPaginatedTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.source.rowCount == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 64),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Không có dữ liệu', style: AppTextStyles.heading3.copyWith(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text('Không tìm thấy bản ghi nào khớp với điều kiện tìm kiếm', style: AppTextStyles.bodyGrey),
          ],
        ),
      );
    }

    bool isServerSide = widget.serverSideTotalElements != null;
    int total = isServerSide ? widget.serverSideTotalElements! : widget.source.rowCount;
    int page = isServerSide ? (widget.serverSideCurrentPage ?? 0) : _currentPage;

    int startIndex = page * widget.rowsPerPage;
    int endIndex = startIndex + widget.rowsPerPage;
    if (endIndex > total) endIndex = total;
    
    // Safety check just in case source.rowCount changed for client-side
    if (!isServerSide && startIndex >= total && total > 0) {
      _currentPage = (total - 1) ~/ widget.rowsPerPage;
      startIndex = _currentPage * widget.rowsPerPage;
      endIndex = startIndex + widget.rowsPerPage;
      if (endIndex > total) endIndex = total;
    }

    List<DataRow> currentRows = [];
    if (isServerSide) {
      // In server-side, data only contains the current page items
      for (int i = 0; i < widget.source.data.length; i++) {
        final row = widget.source.getRow(i);
        if (row != null) {
          currentRows.add(row);
        }
      }
    } else {
      // Client-side, slice from startIndex to endIndex
      for (int i = startIndex; i < endIndex; i++) {
        final row = widget.source.getRow(i);
        if (row != null) {
          currentRows.add(row);
        }
      }
    }

    return Stack(
      children: [
        Theme(
          data: Theme.of(context).copyWith(
            cardColor: Colors.white,
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  surface: Colors.white,
                  surfaceContainer: Colors.white,
                  surfaceContainerLow: Colors.white,
                  surfaceContainerHigh: Colors.white,
                ),
            dataTableTheme: DataTableThemeData(
              headingRowColor: WidgetStateProperty.all(Colors.white),
              dataRowColor: WidgetStateProperty.all(Colors.white),
              headingTextStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark),
              dataTextStyle: AppTextStyles.body.copyWith(color: AppColors.textGrey),
            ),
            dividerColor: Colors.grey.shade200,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.title != null || widget.headerActions != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.title != null)
                          Text(widget.title!, style: AppTextStyles.heading3),
                        if (widget.headerActions != null)
                          widget.headerActions!,
                      ],
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columns: widget.columns,
                        rows: currentRows,
                        showCheckboxColumn: false,
                        columnSpacing: 24,
                        horizontalMargin: 24,
                      ),
                    ),
                  ),
                ),
                // Pagination Footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${startIndex + 1}-$endIndex của $total', style: AppTextStyles.bodyGrey),
                      const SizedBox(width: 24),
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: page > 0 ? () {
                          if (isServerSide) {
                            widget.onPageChanged?.call(page - 1);
                          } else {
                            setState(() {
                              _currentPage--;
                            });
                          }
                        } : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: endIndex < total ? () {
                          if (isServerSide) {
                            widget.onPageChanged?.call(page + 1);
                          } else {
                            setState(() {
                              _currentPage++;
                            });
                          }
                        } : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
