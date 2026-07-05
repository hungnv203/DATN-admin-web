import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/concession.dart';
import '../providers/concession_provider.dart';

class ConcessionManagementScreen extends StatefulWidget {
  const ConcessionManagementScreen({super.key});

  @override
  State<ConcessionManagementScreen> createState() =>
      _ConcessionManagementScreenState();
}

class _ConcessionManagementScreenState
    extends State<ConcessionManagementScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConcessionProvider>().fetchConcessions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConcessionProvider>();
    final concessions = provider.concessions.where((item) {
      final keyword = _query.toLowerCase();
      return item.name.toLowerCase().contains(keyword) ||
          item.description.toLowerCase().contains(keyword);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1015),
      appBar: AppBar(
        title: const Text('Quản lý bỏng nước'),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: provider.isLoading ? null : provider.fetchConcessions,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: ElevatedButton.icon(
              onPressed: provider.isLoading
                  ? null
                  : () => _showConcessionDialog(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Thêm món'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF66FCF1),
                foregroundColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: 'Tìm theo tên hoặc mô tả',
                      filled: true,
                      fillColor: const Color(0xFF16171E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _SummaryPill(
                  label: 'Đang bán',
                  value: provider.concessions
                      .where((item) => item.isActive)
                      .length,
                  color: const Color(0xFF66FCF1),
                ),
                const SizedBox(width: 12),
                _SummaryPill(
                  label: 'Tổng món',
                  value: provider.concessions.length,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: provider.isLoading && provider.concessions.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF66FCF1),
                      ),
                    )
                  : provider.errorMessage != null &&
                        provider.concessions.isEmpty
                  ? Center(
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    )
                  : concessions.isEmpty
                  ? const Center(
                      child: Text(
                        'Chưa có món bỏng nước nào.',
                        style: TextStyle(color: Color(0xFFC5C6C7)),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 420,
                            mainAxisExtent: 180,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: concessions.length,
                      itemBuilder: (context, index) {
                        final concession = concessions[index];
                        return _ConcessionTile(
                          concession: concession,
                          onEdit: () =>
                              _showConcessionDialog(concession: concession),
                          onDelete: () => _showDeleteConfirm(concession),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showConcessionDialog({Concession? concession}) async {
    final provider = context.read<ConcessionProvider>();
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: concession?.name ?? '');
    final descriptionController = TextEditingController(
      text: concession?.description ?? '',
    );
    final priceController = TextEditingController(
      text: concession == null ? '' : concession.price.toStringAsFixed(0),
    );
    final imageUrlController = TextEditingController(
      text: concession?.imageUrl ?? '',
    );
    var isActive = concession?.isActive ?? true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF16171E),
              title: Text(concession == null ? 'Thêm món' : 'Cập nhật món'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên món',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tên món';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descriptionController,
                          minLines: 2,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Mô tả'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Giá'),
                          validator: (value) {
                            final price = double.tryParse(value ?? '');
                            if (price == null || price <= 0) {
                              return 'Giá phải lớn hơn 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: imageUrlController,
                          decoration: const InputDecoration(
                            labelText: 'URL hình ảnh',
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          value: isActive,
                          onChanged: (value) =>
                              setDialogState(() => isActive = value),
                          activeThumbColor: const Color(0xFF66FCF1),
                          title: const Text('Đang bán'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final name = nameController.text.trim();
                    final description = descriptionController.text.trim();
                    final price = double.parse(priceController.text.trim());
                    final imageUrl = imageUrlController.text.trim();
                    final success = concession == null
                        ? await provider.createConcession(
                            name: name,
                            description: description,
                            price: price,
                            imageUrl: imageUrl,
                            isActive: isActive,
                          )
                        : await provider.updateConcession(
                            concession.id,
                            name: name,
                            description: description,
                            price: price,
                            imageUrl: imageUrl,
                            isActive: isActive,
                          );

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, success);
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            concession == null
                ? 'Đã thêm món bỏng nước.'
                : 'Đã cập nhật món bỏng nước.',
          ),
        ),
      );
    } else if (saved == false && mounted && provider.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
    }
  }

  Future<void> _showDeleteConfirm(Concession concession) async {
    final provider = context.read<ConcessionProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16171E),
        title: const Text('Xóa món'),
        content: Text('Bạn muốn xóa "${concession.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await provider.deleteConcession(concession.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã xóa món bỏng nước.'
              : provider.errorMessage ?? 'Xóa món thất bại.',
        ),
      ),
    );
  }
}

class _ConcessionTile extends StatelessWidget {
  const _ConcessionTile({
    required this.concession,
    required this.onEdit,
    required this.onDelete,
  });

  final Concession concession;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final price = _formatCurrency(concession.price);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16171E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 96,
              height: 128,
              color: Colors.white.withValues(alpha: 0.06),
              child: concession.imageUrl.isEmpty
                  ? const Icon(
                      Icons.fastfood_rounded,
                      color: Color(0xFFC5C6C7),
                      size: 36,
                    )
                  : Image.network(
                      concession.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.fastfood_rounded,
                        color: Color(0xFFC5C6C7),
                        size: 36,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        concession.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _StatusBadge(isActive: concession.isActive),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  concession.description.isEmpty
                      ? 'Chưa có mô tả'
                      : concession.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFC5C6C7)),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        price,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF66FCF1),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton(
                        tooltip: 'Sua',
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 36,
                          height: 36,
                        ),
                        color: const Color(0xFFC5C6C7),
                        hoverColor: const Color(
                          0xFF66FCF1,
                        ).withValues(alpha: 0.12),
                        highlightColor: const Color(
                          0xFF66FCF1,
                        ).withValues(alpha: 0.18),
                        splashColor: const Color(
                          0xFF66FCF1,
                        ).withValues(alpha: 0.22),
                        icon: const Icon(Icons.edit_rounded, size: 20),
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton(
                        tooltip: 'Xoa',
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 36,
                          height: 36,
                        ),
                        color: Colors.redAccent,
                        hoverColor: Colors.redAccent.withValues(alpha: 0.12),
                        highlightColor: Colors.redAccent.withValues(
                          alpha: 0.18,
                        ),
                        splashColor: Colors.redAccent.withValues(alpha: 0.22),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (isActive ? const Color(0xFF66FCF1) : Colors.orangeAccent)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        isActive ? 'Đang bán' : 'Tạm ẩn',
        style: TextStyle(
          color: isActive ? const Color(0xFF66FCF1) : Colors.orangeAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16171E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Color(0xFFC5C6C7))),
        ],
      ),
    );
  }
}

String _formatCurrency(double value) {
  final digits = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write('.');
    }
  }
  return '$buffer VND';
}
