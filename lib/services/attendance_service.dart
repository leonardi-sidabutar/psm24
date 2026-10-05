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

  Future<List<Map<String, dynamic>>>
      getTodayAttendanceList() async {
    // ==========================================================
    // 1. TANGGAL HARI INI
    // ==========================================================

    final now = DateTime.now();

    final date =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    // ==========================================================
    // 2. AMBIL DATA PRESENSI
    // ==========================================================

    final presensiResponse = await _supabase
        .from('presensi')
        .select()
        .eq('date', date)
        .order(
          'starttime',
          ascending: true,
        );

    // ==========================================================
    // 3. AMBIL MASTER SHIFT
    // ==========================================================

    final shiftResponse = await _supabase
        .from('shift')
        .select();

    // ==========================================================
    // 4. AMBIL MASTER LOKASI
    // ==========================================================

    final lokasiResponse = await _supabase
        .from('lokasi')
        .select();

    // ==========================================================
    // 5. UBAH DATA SHIFT MENJADI MAP BERDASARKAN ID
    // ==========================================================

    final Map<String, Map<String, dynamic>>
        shiftMap = {};

    for (final item in shiftResponse) {
      shiftMap[
        item['id'].toString()
      ] = Map<String, dynamic>.from(item);
    }

    // ==========================================================
    // 6. UBAH DATA LOKASI MENJADI MAP BERDASARKAN ID
    // ==========================================================

    final Map<String, Map<String, dynamic>>
        lokasiMap = {};

    for (final item in lokasiResponse) {
      lokasiMap[
        item['id'].toString()
      ] = Map<String, dynamic>.from(item);
    }

    // ==========================================================
    // 7. GABUNGKAN PRESENSI + SHIFT + LOKASI
    // ==========================================================

    final List<Map<String, dynamic>>
        result = [];

    for (final item in presensiResponse) {
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(item);

      // --------------------------------------------------------
      // ID SHIFT DARI PRESENSI
      // --------------------------------------------------------

      final String shiftId =
          item['id_shift']?.toString() ?? '';

      // --------------------------------------------------------
      // ID LOKASI DARI PRESENSI
      // --------------------------------------------------------

      final String lokasiId =
          item['id_lokasi']?.toString() ?? '';

      // --------------------------------------------------------
      // CARI MASTER SHIFT
      // --------------------------------------------------------

      final shiftData =
          shiftMap[shiftId];

      // --------------------------------------------------------
      // CARI MASTER LOKASI
      // --------------------------------------------------------

      final lokasiData =
          lokasiMap[lokasiId];

      // --------------------------------------------------------
      // SIMPAN DATA HASIL JOIN MANUAL
      // --------------------------------------------------------

      data['shift_data'] =
          shiftData;

      data['lokasi_data'] =
          lokasiData;

      result.add(data);
    }

    // ==========================================================
    // DEBUG
    // ==========================================================

    return result;
  }

  // ==========================================================
  // DASHBOARD MANDOR
  // ==========================================================

  Future<Map<String, dynamic>> getMandorDashboard() async {
    final now = DateTime.now();

    final date =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    // ========================================================
    // 1. TOTAL SATPAM
    // ========================================================

    final employees = await _supabase
        .from('pekerja')
        .select('nomor')
        .eq('role', 'SATPAM');

    final int totalSatpam = employees.length;

    // ========================================================
    // 2. PRESENSI HARI INI
    // ========================================================

    final response = await _supabase
        .from('presensi')
        .select()
        .eq('date', date);

    final List<Map<String, dynamic>> presensi =
        List<Map<String, dynamic>>.from(response);

    // ========================================================
    // 3. SATPAM YANG SUDAH PRESENSI
    // ========================================================

    final Set<dynamic> satpamSudahPresensi =
        presensi
            .map((item) => item['id_satpam'])
            .toSet();

    final int sudahPresensi =
        satpamSudahPresensi.length;

    // ========================================================
    // 4. BELUM PRESENSI
    // ========================================================

    final int belumPresensi =
        totalSatpam - sudahPresensi;

    // ========================================================
    // 5. STATUS BERTUGAS / SELESAI
    // ========================================================

    int sedangBertugas = 0;
    int sudahSelesai = 0;

    for (final item in presensi) {
      final endtime = item['endtime'];

      if (endtime == null ||
          endtime.toString().isEmpty) {
        sedangBertugas++;
      } else {
        sudahSelesai++;
      }
    }

    // ========================================================
    // 6. HITUNG PRESENSI PER SHIFT
    // ========================================================

    int shiftPagi = 0;
    int shiftSiang = 0;
    int shiftMalam = 0;

    for (final item in presensi) {
      final dynamic rawShift =
          item['id_shift'];

      final int? idShift =
          int.tryParse(rawShift.toString());

      if (idShift == 1) {
        shiftPagi++;
      } else if (idShift == 2) {
        shiftSiang++;
      } else if (idShift == 3) {
        shiftMalam++;
      }
    }

    // ========================================================
    // RETURN
    // ========================================================

    return {
      'totalSatpam': totalSatpam,
      'sudahPresensi': sudahPresensi,
      'belumPresensi': belumPresensi,
      'sedangBertugas': sedangBertugas,
      'sudahSelesai': sudahSelesai,

      'shift': {
        1: {
          'hadir': shiftPagi,
        },
        2: {
          'hadir': shiftSiang,
        },
        3: {
          'hadir': shiftMalam,
        },
      },
    };
  }
}