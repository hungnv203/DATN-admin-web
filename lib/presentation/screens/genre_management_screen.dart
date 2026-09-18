import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/admin_theme.dart';
import '../../domain/entities/genre.dart';
import '../providers/genre_provider.dart';

class GenreManagementScreen extends StatefulWidget {
  const GenreManagementScreen({super.key});

  @override
  State<GenreManagementScreen> createState() => _GenreManagementScreenState();
}

class _GenreManagementScreenState extends State<GenreManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GenreProvider>().fetchGenres();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showGenreDialog({Genre? genre}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: genre?.name ?? '');
    final messenger = ScaffoldMessenger.of(context);
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AdminColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AdminColors.outline),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AdminColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.category_outlined,
                      color: AdminColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    genre == null ? 'Thêm thể loại mới' : 'Chỉnh sửa thể loại',
                    style: const TextStyle(
                      color: AdminColors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tên thể loại phim',
                        style: TextStyle(
                          color: AdminColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: nameController,
                        autofocus: true,
                        style: const TextStyle(color: AdminColors.text),
                        decoration: const InputDecoration(
                          hintText: 'Nhập tên thể loại (ví dụ: Hành động, Viễn tưởng...)',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên thể loại.';
                          }
                          if (value.trim().length > 100) {
                            return 'Tên thể loại không được vượt quá 100 ký tự.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isSaving = true);
                          final provider = context.read<GenreProvider>();
                          final name = nameController.text.trim();
                          final bool success;

                          if (genre == null) {
                            success = await provider.createGenre(name);
                          } else {
                            success = await provider.updateGenre(genre.id, name);
                          }

                          if (!mounted || !dialogContext.mounted) return;
                          if (success) {
                            Navigator.of(dialogContext).pop();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  genre == null
                                      ? 'Thêm thể loại "$name" thành công!'
                                      : 'Cập nhật thể loại "$name" thành công!',
                                ),
                                backgroundColor: Colors.green.shade700,
                              ),
                            );
                          } else {
                            setDialogState(() => isSaving = false);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  provider.errorMessage ?? 'Thao tác không thành công.',
                                ),
                                backgroundColor: AdminColors.danger,
                              ),
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AdminColors.background,
                          ),
                        )
                      : Text(genre == null ? 'Tạo thể loại' : 'Lưu thay đổi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(Genre genre) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AdminColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AdminColors.outline),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AdminColors.danger),
              SizedBox(width: 8),
              Text(
                'Xác nhận xóa thể loại',
                style: TextStyle(color: AdminColors.text, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa thể loại "${genre.name}"?\n\nLưu ý: Thao tác này sẽ bị từ chối nếu thể loại đang được liên kết với các bộ phim trong hệ thống.',
            style: const TextStyle(color: AdminColors.muted, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Xác nhận xóa'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<GenreProvider>();
    final success = await provider.deleteGenre(genre.id);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa thể loại "${genre.name}".'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Không thể xóa thể loại. Vui lòng thử lại sau.',
          ),
          backgroundColor: AdminColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GenreProvider>();
    final filtered = provider.filteredGenres;

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text(
          'Quản lý Thể loại Phim',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: provider.isLoading ? null : provider.fetchGenres,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: ElevatedButton.icon(
              onPressed: provider.isLoading ? null : () => _showGenreDialog(),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Thêm thể loại'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter and stats row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: provider.setSearchQuery,
                    style: const TextStyle(color: AdminColors.text),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded, color: AdminColors.muted),
                      hintText: 'Tìm kiếm theo tên hoặc mã thể loại...',
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: AdminColors.muted),
                              onPressed: () {
                                _searchController.clear();
                                provider.clearSearchQuery();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _StatBadge(
                  label: 'Tổng số',
                  count: provider.genres.length,
                  color: AdminColors.primary,
                ),
                if (provider.searchQuery.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  _StatBadge(
                    label: 'Kết quả lọc',
                    count: filtered.length,
                    color: AdminColors.secondary,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Content body
            Expanded(
              child: _buildBody(provider, filtered),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(GenreProvider provider, List<Genre> filtered) {
    if (provider.isLoading && provider.genres.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AdminColors.primary),
      );
    }

    if (provider.errorMessage != null && provider.genres.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AdminColors.danger, size: 48),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage!,
              style: const TextStyle(color: AdminColors.muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: provider.fetchGenres,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (provider.genres.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 56,
              color: AdminColors.muted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có thể loại phim nào',
              style: TextStyle(
                color: AdminColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Bắt đầu bằng việc thêm thể loại phim đầu tiên vào hệ thống.',
              style: TextStyle(color: AdminColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showGenreDialog(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Thêm thể loại mới'),
            ),
          ],
        ),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: AdminColors.muted),
            const SizedBox(height: 12),
            Text(
              'Không tìm thấy thể loại phù hợp với "${provider.searchQuery}"',
              style: const TextStyle(color: AdminColors.muted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: 24,
                    horizontalMargin: 24,
                    headingRowColor: WidgetStateProperty.all(
                      AdminColors.surfaceHigh.withValues(alpha: 0.5),
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'STT',
                          style: TextStyle(
                            color: AdminColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Tên Thể Loại',
                          style: TextStyle(
                            color: AdminColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Mã Thể Loại (ID)',
                          style: TextStyle(
                            color: AdminColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      DataColumn(
                        numeric: true,
                        label: Text(
                          'Thao Tác',
                          style: TextStyle(
                            color: AdminColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    rows: List<DataRow>.generate(filtered.length, (index) {
                      final genre = filtered[index];
                      return DataRow(
                        cells: [
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AdminColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: AdminColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.movie_filter_outlined,
                                  size: 18,
                                  color: AdminColors.primary,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  genre.name,
                                  style: const TextStyle(
                                    color: AdminColors.text,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            SelectableText(
                              genre.id,
                              style: const TextStyle(
                                color: AdminColors.muted,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Chỉnh sửa',
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: AdminColors.primary,
                                    size: 18,
                                  ),
                                  onPressed: () => _showGenreDialog(genre: genre),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  tooltip: 'Xóa thể loại',
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AdminColors.danger,
                                    size: 18,
                                  ),
                                  onPressed: () => _confirmDelete(genre),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: AdminColors.muted, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
