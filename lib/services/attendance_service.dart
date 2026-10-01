import 'dart:io';

import '../core/supabase_client.dart';

class AttendanceService {
  final _supabase = SupabaseClientService.client;

  static const String bucketName = 'attendance-photos';

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
        'attendance/$idSatpam/$date/${type}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _supabase.storage
        .from(bucketName)
        .upload(
          path,
          file,
        );

    return path;
  }

  // ============================================================
  // CARI PRESENSI AKTIF
  // ============================================================
  //
  // Presensi aktif:
  // - milik satpam tersebut
  // - tanggal hari ini
  // - endtime masih NULL
  //
  // ============================================================

  Future<Map<String, dynamic>?> getActiveAttendance({
    required int idSatpam,
  }) async {
    final now = DateTime.now();

    final date =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final response = await _supabase
        .from('presensi')
        .select()
        .eq('id_satpam', idSatpam)
        .eq('date', date)
        .isFilter('endtime', null)
        .order(
          'id',
          ascending: false,
        )
        .limit(1);

    if (response.isEmpty) {
      return null;
    }

    return response.first;
  }

  // ============================================================
  // SIMPAN PRESENSI MASUK
  // ============================================================

  Future<int> saveCheckIn({
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

    final response = await _supabase
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
    })
        .select('id')
        .single();

    return response['id'] as int;
  }

  // ============================================================
  // SIMPAN PRESENSI KELUAR
  // ============================================================
  //
  // UPDATE ROW YANG SAMA
  //
  // ============================================================

  Future<void> saveCheckOut({
    required int attendanceId,
    required DateTime dateTime,
    required String photoPath,
  }) async {
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';

    await _supabase
        .from('presensi')
        .update({
      'endtime': time,
      'out_path': photoPath,
      'status': 'SELESAI',
    })
        .eq('id', attendanceId);
  }


  Future<Map<String, dynamic>?> getTodayAttendance({
    required int idSatpam,
  }) async {
    final now = DateTime.now();

    final date =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final response = await _supabase
        .from('presensi')
        .select()
        .eq('id_satpam', idSatpam)
        .eq('date', date)
        .order('id', ascending: false)
        .limit(1);

    if (response.isEmpty) {
      return null;
    }

    return response.first;
  }
}