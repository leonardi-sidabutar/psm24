import 'dart:io';

import '../core/supabase_client.dart';

class AttendanceService {
  final _supabase = SupabaseClientService.client;

  static const String bucketName =
      'attendance-photos';

  // ============================================================
  // UPLOAD FOTO
  // ============================================================

  Future<String> uploadPhoto({
    required File file,
    required int idSatpam,
    required DateTime dateTime,
    required String type,
  }) async {
    final date =
        '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')}';

    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}'
        '${dateTime.minute.toString().padLeft(2, '0')}'
        '${dateTime.second.toString().padLeft(2, '0')}';

    final path =
        'attendance/$idSatpam/$date/${type}_$time.jpg';

    await _supabase.storage
        .from(bucketName)
        .upload(
          path,
          file,
        );

    return path;
  }

  // ============================================================
  // SIMPAN PRESENSI MASUK
  // ============================================================

  Future<void> saveCheckIn({
    required int idSatpam,
    required int idShift,
    required int idLokasi,
    required DateTime dateTime,
    required String photoPath,
  }) async {
    final date =
        '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')}';

    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';

    await _supabase
        .from('presensi')
        .insert({
      'id_satpam': idSatpam,
      'id_shift': idShift,
      'id_lokasi': idLokasi,
      'date': date,
      'starttime': time,
      'endtime': null,
      'in_path': photoPath,
      'out_path': null,
      'status': 'MASUK',
      'remarks': null,
    });
  }
}