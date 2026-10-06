import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../models/employee.dart';
import '../../services/attendance_service.dart';

class AttendancePage extends StatefulWidget {
  final Employee employee;

  const AttendancePage({
    super.key,
    required this.employee,
  });

  @override
  State<AttendancePage> createState() =>
      _AttendancePageState();
}

class _AttendancePageState
    extends State<AttendancePage> {
  // ==========================================================
  // SERVICE
  // ==========================================================

  final ImagePicker _picker = ImagePicker();

  final AttendanceService _attendanceService =
      AttendanceService();

  // ==========================================================
  // STATE
  // ==========================================================

  String? selectedLocation;
  String? selectedShift;

  bool _isLoading = false;

  // Apakah satpam sedang mempunyai presensi aktif?
  bool _hasActiveAttendance = false;

  // Data presensi aktif
  Map<String, dynamic>? _activeAttendance;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _checkActiveAttendance();
  }

  // ==========================================================
  // CEK PRESENSI AKTIF
  // ==========================================================

  Future<void> _checkActiveAttendance() async {
    final int? idSatpam =
        int.tryParse(
      widget.employee.employeeCode,
    );

    if (idSatpam == null) {
      return;
    }

    try {
      final attendance =
          await _attendanceService
              .getActiveAttendance(
        idSatpam: idSatpam,
      );

      if (!mounted) return;

      setState(() {
        _activeAttendance = attendance;

        _hasActiveAttendance =
            attendance != null;
      });
    } catch (e) {
      debugPrint(
        'ERROR CHECK ACTIVE ATTENDANCE: $e',
      );

      if (!mounted) return;

      _showMessage(
        'Gagal mengecek presensi: $e',
      );
    }
  }

  // ==========================================================
  // AMBIL NAMA SHIFT DARI HASIL MANUAL JOIN
  // ==========================================================

  String get _namaShift {
    final dynamic shiftData =
        _activeAttendance?['shift_data'];

    if (shiftData == null) {
      return '-';
    }

    if (shiftData is Map) {
      return shiftData['shift']?.toString() ?? '-';
    }

    return '-';
  }

  // ==========================================================
  // AMBIL NAMA LOKASI DARI HASIL MANUAL JOIN
  // ==========================================================

  String get _namaLokasi {
    final dynamic lokasiData =
        _activeAttendance?['lokasi_data'];

    if (lokasiData == null) {
      return '-';
    }

    if (lokasiData is Map) {
      return lokasiData['lokasi']?.toString() ?? '-';
    }

    return '-';
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Presensi',
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _checkActiveAttendance,

        child: ListView(
          padding: const EdgeInsets.all(20),

          children: [
            // ==================================================
            // INFORMASI SATPAM
            // ==================================================

            Text(
              widget.employee.employeeName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              widget.employee.employeeCode,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // STATUS
            // ==================================================

            _buildStatusCard(),

            const SizedBox(height: 20),

            // ==================================================
            // JIKA BELUM PRESENSI
            // ==================================================

            if (!_hasActiveAttendance)
              _buildCheckInForm(),

            // ==================================================
            // JIKA SUDAH MASUK
            // ==================================================

            if (_hasActiveAttendance)
              _buildCheckOutSection(),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // STATUS CARD
  // ==========================================================

  Widget _buildStatusCard() {
    if (_hasActiveAttendance) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==================================================
              // HEADER STATUS
              // ==================================================

              Row(
                children: [
                  const Icon(
                    Icons.login,
                    color: Colors.green,
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Text(
                      'Sedang Bertugas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      'AKTIF',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const Divider(),

              const SizedBox(height: 10),

              // ==================================================
              // JAM MASUK
              // ==================================================

              Row(
                children: [
                  Icon(
                    Icons.login,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jam Masuk',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          _activeAttendance?[
                                  'starttime']
                              ?.toString() ??
                              '-',
                          style:
                              const TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ==================================================
              // SHIFT
              // ==================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shift',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          _namaShift,
                          style:
                              const TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ==================================================
              // LOKASI
              // ==================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lokasi',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          _namaLokasi,
                          style:
                              const TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // ==========================================================
    // BELUM PRESENSI
    // ==========================================================

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [
            const Icon(
              Icons.login,
              color: Colors.blue,
            ),

            const SizedBox(width: 10),

            const Expanded(
              child: Text(
                'Belum melakukan presensi masuk',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // FORM PRESENSI MASUK
  // ==========================================================

  Widget _buildCheckInForm() {
    return Column(
      children: [
        // ======================================================
        // LOKASI
        // ======================================================

        DropdownButtonFormField<String>(
          value: selectedLocation,

          decoration:
              const InputDecoration(
            labelText: 'Lokasi',
            border:
                OutlineInputBorder(),
          ),

          items: const [
            DropdownMenuItem(
              value: '1',
              child:
                  Text('Pos Kantor Besar'),
            ),

            DropdownMenuItem(
              value: '2',
              child:
                  Text('Pos Diponogero'),
            ),

            DropdownMenuItem(
              value: '3',
              child:
                  Text('Pos Tengku Daud'),
            ),

            DropdownMenuItem(
              value: '4',
              child:
                  Text('Pos Pattimura'),
            ),

            DropdownMenuItem(
              value: '5',
              child:
                  Text('Pos Komplek II'),
            ),

            DropdownMenuItem(
              value: '6',
              child:
                  Text('Pos Komplek IV'),
            ),

            DropdownMenuItem(
              value: '7',
              child:
                  Text('Dinas Luar'),
            ),
          ],

          onChanged:
              _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        selectedLocation =
                            value;
                      });
                    },
        ),

        const SizedBox(height: 16),

        // ======================================================
        // SHIFT
        // ======================================================

        DropdownButtonFormField<String>(
          value: selectedShift,

          decoration:
              const InputDecoration(
            labelText: 'Shift',
            border:
                OutlineInputBorder(),
          ),

          items: const [
            DropdownMenuItem(
              value: '1',
              child: Text('Pagi'),
            ),

            DropdownMenuItem(
              value: '2',
              child: Text('Siang'),
            ),

            DropdownMenuItem(
              value: '3',
              child: Text('Malam'),
            ),
          ],

          onChanged:
              _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        selectedShift =
                            value;
                      });
                    },
        ),

        const SizedBox(height: 30),

        // ======================================================
        // BUTTON MASUK
        // ======================================================

        SizedBox(
          width: double.infinity,
          height: 50,

          child:
              ElevatedButton.icon(
            onPressed:
                _isLoading
                    ? null
                    : _checkIn,

            icon: const Icon(
              Icons.login,
            ),

            label: const Text(
              'PRESENSI MASUK',
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SECTION PRESENSI KELUAR
  // ==========================================================

  Widget _buildCheckOutSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,

          padding:
              const EdgeInsets.all(16),

          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(12),

            color: Colors.orange.shade50,

            border: Border.all(
              color:
                  Colors.orange.shade200,
            ),
          ),

          child: const Column(
            children: [
              Icon(
                Icons.logout,
                size: 45,
                color: Colors.orange,
              ),

              SizedBox(height: 10),

              Text(
                'Konfirmasi Presensi Keluar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              SizedBox(height: 5),

              Text(
                'Pastikan Anda sudah selesai bertugas.',
                textAlign:
                    TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ======================================================
        // BUTTON KELUAR
        // ======================================================

        SizedBox(
          width: double.infinity,
          height: 52,

          child:
              ElevatedButton.icon(
            onPressed:
                _isLoading
                    ? null
                    : _checkOut,

            icon:
                _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.logout,
                      ),

            label: Text(
              _isLoading
                  ? 'Memproses...'
                  : 'PRESENSI KELUAR',
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // PRESENSI MASUK
  // ==========================================================

  Future<void> _checkIn() async {
    if (selectedLocation == null) {
      _showMessage(
        'Silakan pilih lokasi terlebih dahulu',
      );

      return;
    }

    if (selectedShift == null) {
      _showMessage(
        'Silakan pilih shift terlebih dahulu',
      );

      return;
    }

    final int? idSatpam =
        int.tryParse(
      widget.employee.employeeCode,
    );

    if (idSatpam == null) {
      _showMessage(
        'ID satpam tidak valid',
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ======================================================
      // KAMERA
      // ======================================================

      final XFile? image =
          await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice:
            CameraDevice.front,
        imageQuality: 80,
      );

      if (image == null) {
        return;
      }

      // ======================================================
      // COMPRESS
      // ======================================================

      final File photoFile =
          await _compressImage(image);

      // ======================================================
      // WAKTU
      // ======================================================

      final DateTime now =
          DateTime.now();

      // ======================================================
      // UPLOAD
      // ======================================================

      final String photoPath =
          await _attendanceService
              .uploadPhoto(
        file: photoFile,
        idSatpam: idSatpam,
        dateTime: now,
        type: 'in',
      );

      // ======================================================
      // INSERT
      // ======================================================

      await _attendanceService
          .saveCheckIn(
        idSatpam: idSatpam,

        idShift:
            int.parse(
          selectedShift!,
        ),

        idLokasi:
            int.parse(
          selectedLocation!,
        ),

        dateTime: now,

        photoPath: photoPath,
      );

      if (!mounted) return;

      _showMessage(
        'Presensi masuk berhasil',
      );

      setState(() {
        selectedLocation = null;
        selectedShift = null;
      });

      // ======================================================
      // REFRESH STATUS
      // ======================================================

      await _checkActiveAttendance();
    } catch (e) {
      debugPrint(
        'ERROR PRESENSI MASUK: $e',
      );

      if (!mounted) return;

      _showMessage(
        'Presensi masuk gagal: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================================
  // PRESENSI KELUAR
  // ==========================================================

  Future<void> _checkOut() async {
    // ========================================================
    // PASTIKAN ADA PRESENSI AKTIF
    // ========================================================

    if (_activeAttendance == null) {
      _showMessage(
        'Tidak ditemukan presensi aktif',
      );

      return;
    }

    // ========================================================
    // KONFIRMASI
    // ========================================================

    final bool? confirmed =
        await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi Presensi Keluar',
          ),

          content: const Text(
            'Apakah Anda yakin sudah selesai bertugas dan ingin melakukan presensi keluar?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child: const Text(
                'BATAL',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              child: const Text(
                'YA, KELUAR',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    // ========================================================
    // ID PRESENSI
    // ========================================================

    final int attendanceId =
        _activeAttendance!['id'] as int;

    final int? idSatpam =
        int.tryParse(
      widget.employee.employeeCode,
    );

    if (idSatpam == null) {
      _showMessage(
        'ID satpam tidak valid',
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ======================================================
      // KAMERA DEPAN
      // ======================================================

      final XFile? image =
          await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice:
            CameraDevice.front,
        imageQuality: 80,
      );

      if (image == null) {
        return;
      }

      // ======================================================
      // COMPRESS
      // ======================================================

      final File photoFile =
          await _compressImage(image);

      // ======================================================
      // WAKTU KELUAR
      // ======================================================

      final DateTime now =
          DateTime.now();

      // ======================================================
      // UPLOAD FOTO KELUAR
      // ======================================================

      final String photoPath =
          await _attendanceService
              .uploadPhoto(
        file: photoFile,
        idSatpam: idSatpam,
        dateTime: now,
        type: 'out',
      );

      // ======================================================
      // UPDATE ROW PRESENSI
      // ======================================================

      await _attendanceService
          .saveCheckOut(
        attendanceId: attendanceId,
        dateTime: now,
        photoPath: photoPath,
      );

      if (!mounted) return;

      _showMessage(
        'Presensi keluar berhasil',
      );

      // ======================================================
      // REFRESH
      // ======================================================

      await _checkActiveAttendance();
    } catch (e) {
      debugPrint(
        'ERROR PRESENSI KELUAR: $e',
      );

      if (!mounted) return;

      _showMessage(
        'Presensi keluar gagal: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================================
  // COMPRESS FOTO
  // ==========================================================

  Future<File> _compressImage(
    XFile image,
  ) async {
    final File originalFile =
        File(image.path);

    final int originalSize =
        await originalFile.length();

    debugPrint(
      'Foto asli: '
      '${(originalSize / 1024).toStringAsFixed(2)} KB',
    );

    final String targetPath =
        '${Directory.systemTemp.path}/'
        'attendance_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final XFile? compressedImage =
        await FlutterImageCompress
            .compressAndGetFile(
      image.path,
      targetPath,
      quality: 50,
      minWidth: 720,
      minHeight: 720,
      format: CompressFormat.jpeg,
    );

    if (compressedImage == null) {
      throw Exception(
        'Gagal melakukan kompresi foto',
      );
    }

    final File compressedFile =
        File(compressedImage.path);

    final int compressedSize =
        await compressedFile.length();

    debugPrint(
      'Foto setelah compress: '
      '${(compressedSize / 1024).toStringAsFixed(2)} KB',
    );

    return compressedFile;
  }

  // ==========================================================
  // SNACKBAR
  // ==========================================================

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}