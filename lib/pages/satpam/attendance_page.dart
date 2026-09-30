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

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presensi'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

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

            const SizedBox(height: 24),

            // ==================================================
            // LOKASI
            // ==================================================

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Lokasi',
                border: OutlineInputBorder(),
              ),

              items: const [

                DropdownMenuItem(
                  value: '1',
                  child: Text(
                    'Pos Kantor Besar',
                  ),
                ),

                DropdownMenuItem(
                  value: '2',
                  child: Text(
                    'Pos Diponogero',
                  ),
                ),

                DropdownMenuItem(
                  value: '3',
                  child: Text(
                    'Pos Tengku Daud',
                  ),
                ),

                DropdownMenuItem(
                  value: '4',
                  child: Text(
                    'Pos Pattimura',
                  ),
                ),

                DropdownMenuItem(
                  value: '5',
                  child: Text(
                    'Pos Komplek II',
                  ),
                ),

                DropdownMenuItem(
                  value: '6',
                  child: Text(
                    'Pos Komplek IV',
                  ),
                ),

                DropdownMenuItem(
                  value: '7',
                  child: Text(
                    'Dinas Luar',
                  ),
                ),

              ],

              onChanged: _isLoading
                  ? null
                  : (value) {

                      setState(() {
                        selectedLocation = value;
                      });

                    },
            ),

            const SizedBox(height: 16),

            // ==================================================
            // SHIFT
            // ==================================================

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Shift',
                border: OutlineInputBorder(),
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

              onChanged: _isLoading
                  ? null
                  : (value) {

                      setState(() {
                        selectedShift = value;
                      });

                    },
            ),

            const SizedBox(height: 30),

            // ==================================================
            // BUTTON PRESENSI MASUK
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(

                onPressed:
                    _isLoading
                        ? null
                        : _checkIn,

                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,

                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt,
                      ),

                label: Text(
                  _isLoading
                      ? 'Memproses...'
                      : 'PRESENSI MASUK',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PRESENSI MASUK
  // ==========================================================

  Future<void> _checkIn() async {

    // ========================================================
    // VALIDASI LOKASI
    // ========================================================

    if (selectedLocation == null) {

      _showMessage(
        'Silakan pilih lokasi terlebih dahulu',
      );

      return;
    }

    // ========================================================
    // VALIDASI SHIFT
    // ========================================================

    if (selectedShift == null) {

      _showMessage(
        'Silakan pilih shift terlebih dahulu',
      );

      return;
    }

    // ========================================================
    // VALIDASI EMPLOYEE CODE
    // ========================================================

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

    // ========================================================
    // MULAI LOADING
    // ========================================================

    setState(() {
      _isLoading = true;
    });

    try {

      // ======================================================
      // BUKA KAMERA DEPAN
      // ======================================================

      final XFile? image =
          await _picker.pickImage(

        source:
            ImageSource.camera,

        preferredCameraDevice:
            CameraDevice.front,

        // Kita tetap turunkan sedikit kualitas dari kamera.
        // Kompresi utama dilakukan setelah ini.
        imageQuality:
            50,
      );

      // ======================================================
      // USER MEMBATALKAN KAMERA
      // ======================================================

      if (image == null) {
        return;
      }

      // ======================================================
      // FILE FOTO ASLI
      // ======================================================

      final File originalFile =
          File(image.path);

      // ======================================================
      // TAMPILKAN UKURAN FOTO ASLI
      // ======================================================

      final int originalSize =
          await originalFile.length();

      debugPrint(
        'Ukuran foto asli: '
        '${(originalSize / 1024).toStringAsFixed(2)} KB',
      );

      // ======================================================
      // FILE HASIL KOMPRESI
      // ======================================================

      final String targetPath =
          '${Directory.systemTemp.path}/'
          'attendance_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // ======================================================
      // COMPRESS FOTO
      // ======================================================

      final XFile? compressedImage =
          await FlutterImageCompress.compressAndGetFile(

        image.path,

        targetPath,

        // Kualitas JPEG
        quality:
            50,

        // Batasi resolusi foto
        minWidth:
            720,

        minHeight:
            720,

        // Pastikan hasil berupa JPEG
        format:
            CompressFormat.jpeg,
      );

      // ======================================================
      // VALIDASI HASIL COMPRESS
      // ======================================================

      if (compressedImage == null) {

        throw Exception(
          'Gagal melakukan kompresi foto',
        );
      }

      // ======================================================
      // FILE FOTO HASIL COMPRESS
      // ======================================================

      final File photoFile =
          File(compressedImage.path);

      // ======================================================
      // UKURAN FOTO HASIL COMPRESS
      // ======================================================

      final int compressedSize =
          await photoFile.length();

      debugPrint(
        'Ukuran foto setelah compress: '
        '${(compressedSize / 1024).toStringAsFixed(2)} KB',
      );

      // ======================================================
      // WAKTU PRESENSI
      // ======================================================

      final DateTime now =
          DateTime.now();

      // ======================================================
      // UPLOAD FOTO HASIL COMPRESS
      // ======================================================

      final String photoPath =
          await _attendanceService.uploadPhoto(

        file:
            photoFile,

        idSatpam:
            idSatpam,

        dateTime:
            now,

        type:
            'in',
      );

      // ======================================================
      // SIMPAN TRANSAKSI
      // ======================================================

      await _attendanceService.saveCheckIn(

        idSatpam:
            idSatpam,

        idShift:
            int.parse(
              selectedShift!,
            ),

        idLokasi:
            int.parse(
              selectedLocation!,
            ),

        dateTime:
            now,

        photoPath:
            photoPath,
      );

      // ======================================================
      // CEK WIDGET
      // ======================================================

      if (!mounted) return;

      // ======================================================
      // BERHASIL
      // ======================================================

      _showMessage(
        'Presensi masuk berhasil',
      );

      // ======================================================
      // RESET FORM
      // ======================================================

      setState(() {

        selectedLocation = null;

        selectedShift = null;

      });

    } catch (e) {

      // ======================================================
      // ERROR
      // ======================================================

      if (!mounted) return;

      _showMessage(
        'Presensi gagal: $e',
      );

      debugPrint(
        'ERROR PRESENSI: $e',
      );

    } finally {

      // ======================================================
      // STOP LOADING
      // ======================================================

      if (mounted) {

        setState(() {
          _isLoading = false;
        });

      }
    }
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