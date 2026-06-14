import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../../domain/entities/movie.dart';

class MovieCatalogScreen extends StatefulWidget {
  const MovieCatalogScreen({super.key});

  @override
  State<MovieCatalogScreen> createState() => _MovieCatalogScreenState();
}

class _MovieCatalogScreenState extends State<MovieCatalogScreen> {
  final _movieFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _durationController = TextEditingController();
  final _langController = TextEditingController(text: 'Tiếng Việt');
  final _posterUrlController = TextEditingController();

  DateTime _selectedReleaseDate = DateTime.now();
  String _selectedRating = 'T13';
  String _selectedStatus = 'NowShowing';

  bool _isUploadingPoster = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false).fetchMovies();
    });
  }

  void _pickAndUploadPoster(StateSetter setDialogState) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        setDialogState(() {
          _isUploadingPoster = true;
        });

        final fileBytes = result.files.first.bytes!;
        final fileName = result.files.first.name;

        final movieProvider = Provider.of<MovieProvider>(context, listen: false);
        final uploadedUrl = await movieProvider.uploadPoster(fileBytes, fileName);

        setDialogState(() {
          _isUploadingPoster = false;
          if (uploadedUrl.isNotEmpty) {
            _posterUrlController.text = uploadedUrl;
          }
        });
      }
    } catch (e) {
      setDialogState(() {
        _isUploadingPoster = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải ảnh lên: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showAddMovieDialog({Movie? editMovie}) {
    if (editMovie != null) {
      _titleController.text = editMovie.title;
      _descController.text = editMovie.description;
      _durationController.text = editMovie.duration.toString();
      _langController.text = editMovie.language;
      _posterUrlController.text = editMovie.posterUrl;
      _selectedReleaseDate = editMovie.releaseDate;
      _selectedRating = editMovie.rating;
      _selectedStatus = editMovie.status;
    } else {
      _titleController.clear();
      _descController.clear();
      _durationController.text = '120';
      _langController.text = 'Tiếng Việt';
      _posterUrlController.clear();
      _selectedReleaseDate = DateTime.now();
      _selectedRating = 'T13';
      _selectedStatus = 'NowShowing';
    }

    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF16171E),
          title: Text(
            editMovie == null ? 'Thêm Phim Mới' : 'Cập Nhật Phim',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Container(
              width: 500,
              child: Form(
                key: _movieFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Tên bộ phim',
                        labelStyle: TextStyle(color: Color(0xFFC5C6C7)),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Nhập tên phim.' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Nội dung tóm tắt',
                        labelStyle: TextStyle(color: Color(0xFFC5C6C7)),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Nhập mô tả.' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Thời lượng (phút)',
                              labelStyle: TextStyle(color: Color(0xFFC5C6C7)),
                            ),
                            validator: (v) => v == null || int.tryParse(v) == null ? 'Lỗi' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _langController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Ngôn ngữ',
                              labelStyle: TextStyle(color: Color(0xFFC5C6C7)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedRating,
                            style: const TextStyle(color: Colors.white),
                            dropdownColor: const Color(0xFF16171E),
                            decoration: const InputDecoration(
                              labelText: 'Phân loại độ tuổi',
                              labelStyle: TextStyle(color: Color(0xFFC5C6C7)),
                            ),
                            items: ['P', 'K', 'T13', 'T16', 'T18', 'C']
                                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setDialogState(() => _selectedRating = v);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            style: const TextStyle(color: Colors.white),
                            dropdownColor: const Color(0xFF16171E),
                            decoration: const InputDecoration(
                              labelText: 'Trạng thái chiếu',
                              labelStyle: TextStyle(color: Color(0xFFC5C6C7)),
                            ),
                            items: [
                              const DropdownMenuItem(value: 'NowShowing', child: Text('Đang chiếu')),
                              const DropdownMenuItem(value: 'Upcoming', child: Text('Sắp chiếu')),
                              const DropdownMenuItem(value: 'Finished', child: Text('Ngừng chiếu')),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setDialogState(() => _selectedStatus = v);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Release Date picker
                    Row(
                      children: [
                        const Icon(Icons.date_range_rounded, color: Color(0xFF66FCF1), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Khởi chiếu: ${_selectedReleaseDate.day}/${_selectedReleaseDate.month}/${_selectedReleaseDate.year}',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedReleaseDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setDialogState(() {
                                _selectedReleaseDate = date;
                              });
                            }
                          },
                          child: const Text('Chọn ngày', style: TextStyle(color: Color(0xFF66FCF1))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Poster Upload UI
                    const Text(
                      'Poster bộ phim',
                      style: TextStyle(color: Color(0xFF66FCF1), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _posterUrlController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Nhập URL ảnh hoặc tải ảnh lên...',
                              hintStyle: TextStyle(color: Colors.white30),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Vui lòng cung cấp ảnh poster.' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _isUploadingPoster
                            ? const CircularProgressIndicator(color: Color(0xFF66FCF1))
                            : ElevatedButton.icon(
                                onPressed: () => _pickAndUploadPoster(setDialogState),
                                icon: const Icon(Icons.cloud_upload_rounded, size: 16),
                                label: const Text('Tải lên'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1F2833),
                                  foregroundColor: const Color(0xFF66FCF1),
                                ),
                              )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: Color(0xFFC5C6C7))),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (_movieFormKey.currentState!.validate()) {
                  setDialogState(() => isSaving = true);
                  try {
                    final provider = Provider.of<MovieProvider>(context, listen: false);
                    bool success;
                    
                    if (editMovie == null) {
                      success = await provider.createMovie(
                        title: _titleController.text.trim(),
                        description: _descController.text.trim(),
                        duration: int.parse(_durationController.text),
                        releaseDate: _selectedReleaseDate,
                        language: _langController.text.trim(),
                        rating: _selectedRating,
                        posterUrl: _posterUrlController.text.trim(),
                        status: _selectedStatus,
                      );
                    } else {
                      success = await provider.updateMovie(
                        editMovie.id,
                        title: _titleController.text.trim(),
                        description: _descController.text.trim(),
                        duration: int.parse(_durationController.text),
                        releaseDate: _selectedReleaseDate,
                        language: _langController.text.trim(),
                        rating: _selectedRating,
                        posterUrl: _posterUrlController.text.trim(),
                        status: _selectedStatus,
                      );
                    }
                    
                    if (success && mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(editMovie == null ? 'Thêm phim mới thành công!' : 'Cập nhật phim thành công!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) setDialogState(() => isSaving = false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF66FCF1)),
              child: isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Text('Lưu Phim', style: TextStyle(color: Color(0xFF0B0C10))),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1015),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16171E),
        title: const Text('Quản Lý Danh Mục Phim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showAddMovieDialog(),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Thêm Phim Mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF66FCF1),
                foregroundColor: const Color(0xFF0B0C10),
              ),
            ),
          )
        ],
      ),
      body: movieProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF66FCF1)))
          : Padding(
              padding: const EdgeInsets.all(40),
              child: movieProvider.movies.isEmpty
                  ? const Center(child: Text('Chưa có phim nào trong danh mục.', style: TextStyle(color: Color(0xFFC5C6C7))))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        crossAxisSpacing: 30,
                        mainAxisSpacing: 30,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: movieProvider.movies.length,
                      itemBuilder: (ctx, idx) {
                        final movie = movieProvider.movies[idx];
                        
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF16171E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Poster image
                                Expanded(
                                  child: movie.posterUrl.isNotEmpty
                                      ? Image.network(
                                          movie.posterUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Center(
                                            child: Icon(Icons.image_not_supported_rounded, color: Colors.blueGrey, size: 40),
                                          ),
                                        )
                                      : const Center(
                                          child: Icon(Icons.movie_rounded, color: Colors.blueGrey, size: 40),
                                        ),
                                ),
                                // Text details
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${movie.duration} phút',
                                            style: const TextStyle(color: Color(0xFFC5C6C7), fontSize: 11),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF66FCF1).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              movie.rating,
                                              style: const TextStyle(
                                                color: Color(0xFF66FCF1),
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_rounded, color: Color(0xFF66FCF1), size: 18),
                                            onPressed: () => _showAddMovieDialog(editMovie: movie),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                                            onPressed: () => _showDeleteMovieConfirm(movieProvider, movie),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
  void _showDeleteMovieConfirm(MovieProvider provider, Movie movie) {
    bool isDeleting = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF16171E),
              title: const Text('Xóa Phim', style: TextStyle(color: Colors.white)),
              content: Text('Bạn có chắc chắn muốn xóa phim "${movie.title}" không?', style: const TextStyle(color: Colors.white)),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.pop(ctx),
                  child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isDeleting ? null : () async {
                    setState(() => isDeleting = true);
                    try {
                      await provider.deleteMovie(movie.id);
                      if (context.mounted) Navigator.pop(ctx);
                    } finally {
                      if (context.mounted) setState(() => isDeleting = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: isDeleting 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Xóa', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
