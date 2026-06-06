import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cinema_provider.dart';
import '../widgets/seat_matrix_grid_builder.dart';
import '../../domain/entities/cinema.dart';
import '../../domain/entities/room.dart';

class CinemaConfigScreen extends StatefulWidget {
  const CinemaConfigScreen({super.key});

  @override
  State<CinemaConfigScreen> createState() => _CinemaConfigScreenState();
}

class _CinemaConfigScreenState extends State<CinemaConfigScreen> {
  Cinema? _selectedCinema;
  Room? _activeConfigRoom;
  
  // Cinema form controllers
  final _cinemaFormKey = GlobalKey<FormState>();
  final _cinemaNameController = TextEditingController();
  final _cinemaAddressController = TextEditingController();
  final _cinemaCityController = TextEditingController();
  
  // Room form controllers
  final _roomFormKey = GlobalKey<FormState>();
  final _roomNameController = TextEditingController();
  final _roomRowsController = TextEditingController(text: '8');
  final _roomColsController = TextEditingController(text: '10');
  String _selectedRoomType = '2D';

  // Seat layout configuration variables
  int _gridRows = 8;
  int _gridCols = 10;
  Map<String, String> _seatMap = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CinemaProvider>(context, listen: false).fetchCinemas();
      Provider.of<CinemaProvider>(context, listen: false).fetchRooms();
    });
  }

  void _showAddCinemaDialog({Cinema? editCinema}) {
    if (editCinema != null) {
      _cinemaNameController.text = editCinema.name;
      _cinemaAddressController.text = editCinema.address;
      _cinemaCityController.text = editCinema.city;
    } else {
      _cinemaNameController.clear();
      _cinemaAddressController.clear();
      _cinemaCityController.clear();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16171E),
        title: Text(
          editCinema == null ? 'Thêm chi nhánh rạp mới' : 'Chỉnh sửa chi nhánh',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _cinemaFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _cinemaNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Tên rạp',
                    labelStyle: TextStyle(color: Color(0xFFC5C6C7)),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tên rạp.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cinemaAddressController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ',
                    labelStyle: TextStyle(color: Color(0xFFC5C6C7)),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập địa chỉ.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cinemaCityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Thành phố',
                    labelStyle: TextStyle(color: Color(0xFFC5C6C7)),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập thành phố.' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFFC5C6C7))),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_cinemaFormKey.currentState!.validate()) {
                final provider = Provider.of<CinemaProvider>(context, listen: false);
                bool success;
                if (editCinema == null) {
                  success = await provider.createCinema(
                    _cinemaNameController.text.trim(),
                    _cinemaAddressController.text.trim(),
                    _cinemaCityController.text.trim(),
                  );
                } else {
                  success = await provider.updateCinema(
                    editCinema.id,
                    _cinemaNameController.text.trim(),
                    _cinemaAddressController.text.trim(),
                    _cinemaCityController.text.trim(),
                  );
                }
                if (success && mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(editCinema == null ? 'Thêm rạp thành công!' : 'Cập nhật rạp thành công!'),
                      backgroundColor: const Color(0xFF66FCF1),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF66FCF1)),
            child: const Text('Lưu', style: TextStyle(color: Color(0xFF0B0C10))),
          ),
        ],
      ),
    );
  }

  void _showAddRoomDialog() {
    _roomNameController.clear();
    _roomRowsController.text = '8';
    _roomColsController.text = '10';
    _selectedRoomType = '2D';
    _seatMap = {};

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF16171E),
          title: const Text(
            'Thêm phòng chiếu & Cấu hình ghế',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.65,
              maxWidth: 900,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _roomFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  TextFormField(
                    controller: _roomNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Tên phòng chiếu (Ví dụ: Phòng 01)',
                      labelStyle: TextStyle(color: Color(0xFFC5C6C7)),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tên phòng.' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRoomType,
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xFF16171E),
                    decoration: const InputDecoration(
                      labelText: 'Loại phòng',
                      labelStyle: TextStyle(color: Color(0xFFC5C6C7)),
                    ),
                    items: ['2D', '3D', 'IMAX', '4DX']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() {
                          _selectedRoomType = v;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _roomRowsController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Số hàng ghế',
                            labelStyle: TextStyle(color: Color(0xFFC5C6C7)),
                          ),
                          validator: (v) => v == null || int.tryParse(v) == null ? 'Lỗi' : null,
                          onChanged: (v) {
                            final parsed = int.tryParse(v);
                            if (parsed != null && parsed > 0 && parsed <= 26) {
                              setDialogState(() {
                                _gridRows = parsed;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _roomColsController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Số cột ghế',
                            labelStyle: TextStyle(color: Color(0xFFC5C6C7)),
                          ),
                          validator: (v) => v == null || int.tryParse(v) == null ? 'Lỗi' : null,
                          onChanged: (v) {
                            final parsed = int.tryParse(v);
                            if (parsed != null && parsed > 0 && parsed <= 30) {
                              setDialogState(() {
                                _gridCols = parsed;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'NHẤP CHUỘT VÀO GHẾ ĐỂ ĐỔI LOẠI:',
                    style: TextStyle(color: Color(0xFF66FCF1), fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  // Seat builder inside dialog
                  SeatMatrixGridBuilder(
                    rows: _gridRows,
                    columns: _gridCols,
                    initialSeatMap: _seatMap,
                    onChanged: (map) {
                      _seatMap = map;
                    },
                  ),
                ],
              ),
            ),
          ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: Color(0xFFC5C6C7))),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_roomFormKey.currentState!.validate() && _selectedCinema != null) {
                  final provider = Provider.of<CinemaProvider>(context, listen: false);
                  
                  // Count total non-empty seats
                  final totalSeatsCount = _seatMap.values.where((v) => v != 'Empty').length;
                  
                  // 1. Create Room object in backend
                  final newRoom = await provider.createRoom(
                    _selectedCinema!.id,
                    _roomNameController.text.trim(),
                    totalSeatsCount,
                    _selectedRoomType,
                  );
                  
                  // 2. Generate seats grid layout based on created Room
                  if (newRoom != null) {
                    final layoutSuccess = await provider.generateSeatLayout(newRoom.id, _seatMap);
                    if (layoutSuccess && mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tạo phòng chiếu và sơ đồ ghế thành công!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF66FCF1)),
              child: const Text('Lưu & Tạo Ghế', style: TextStyle(color: Color(0xFF0B0C10))),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cinemaProvider = Provider.of<CinemaProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F1015),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16171E),
        title: const Text('Quản Lý Rạp & Thiết Lập Phòng Chiếu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showAddCinemaDialog(),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Thêm rạp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF66FCF1),
                foregroundColor: const Color(0xFF0B0C10),
              ),
            ),
          )
        ],
      ),
      body: cinemaProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF66FCF1)))
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cinemas list (left column)
                Container(
                  width: 320,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: cinemaProvider.cinemas.length,
                    itemBuilder: (ctx, index) {
                      final cinema = cinemaProvider.cinemas[index];
                      final isSelected = _selectedCinema?.id == cinema.id;
                      
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCinema = cinema;
                            _activeConfigRoom = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF66FCF1).withOpacity(0.05) : Colors.transparent,
                            border: Border(
                              bottom: BorderSide(color: Colors.white.withOpacity(0.03)),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      cinema.name,
                                      style: TextStyle(
                                        color: isSelected ? const Color(0xFF66FCF1) : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 16, color: Colors.blueGrey),
                                    onPressed: () => _showAddCinemaDialog(editCinema: cinema),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                                    onPressed: () async {
                                      final deleteSuccess = await cinemaProvider.deleteCinema(cinema.id);
                                      if (deleteSuccess && mounted) {
                                        setState(() {
                                          if (_selectedCinema?.id == cinema.id) {
                                            _selectedCinema = null;
                                          }
                                        });
                                      }
                                    },
                                  )
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cinema.address,
                                style: const TextStyle(color: Color(0xFFC5C6C7), fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cinema.city,
                                style: const TextStyle(color: Color(0xFF66FCF1), fontSize: 11, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Rooms of selected Cinema (right side panel)
                Expanded(
                  child: _selectedCinema == null
                      ? const Center(
                          child: Text(
                            'Chọn một chi nhánh rạp ở danh sách bên trái để thiết lập phòng chiếu.',
                            style: TextStyle(color: Color(0xFFC5C6C7)),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Danh sách phòng chiếu - ${_selectedCinema!.name}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Địa chỉ: ${_selectedCinema!.address}, ${_selectedCinema!.city}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Color(0xFFC5C6C7), fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => _showAddRoomDialog(),
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Thêm phòng chiếu'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF66FCF1),
                                      foregroundColor: const Color(0xFF0B0C10),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 30),
                              
                              // Rooms List representation
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (ctx, constraints) {
                                    final currentRooms = cinemaProvider.rooms
                                        .where((r) => r.cinemaId == _selectedCinema!.id)
                                        .toList();
                                        
                                    if (currentRooms.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          'Chưa có phòng chiếu nào được tạo cho rạp này.',
                                          style: TextStyle(color: Color(0xFFC5C6C7)),
                                        ),
                                      );
                                    }
                                    
                                    final double childAspectRatio = constraints.maxWidth < 380 ? 1.3 : 1.5;
                                    return GridView.builder(
                                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 250,
                                        crossAxisSpacing: 20,
                                        mainAxisSpacing: 20,
                                        childAspectRatio: childAspectRatio,
                                      ),
                                      itemCount: currentRooms.length,
                                      itemBuilder: (ctx, index) {
                                        final room = currentRooms[index];
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF16171E),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                                          ),
                                          child: SingleChildScrollView(
                                            physics: const NeverScrollableScrollPhysics(),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        room.name,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF66FCF1).withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        room.type,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          color: Color(0xFF66FCF1),
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    InkWell(
                                                      onTap: () async {
                                                        await cinemaProvider.deleteRoom(room.id);
                                                      },
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(4),
                                                        child: Icon(
                                                          Icons.delete_outline_rounded,
                                                          color: Colors.redAccent,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  'Số lượng ghế: ${room.totalSeats}',
                                                  style: const TextStyle(
                                                    color: Color(0xFFC5C6C7),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                )
              ],
            ),
    );
  }
}
