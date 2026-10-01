import 'package:flutter/material.dart';

import '../../models/employee.dart';
import '../../services/attendance_service.dart';
import 'attendance_page.dart';

class SatpamHomePage extends StatefulWidget {
  final Employee employee;

  const SatpamHomePage({
    super.key,
    required this.employee,
  });

  @override
  State<SatpamHomePage> createState() =>
      _SatpamHomePageState();
}

class _SatpamHomePageState extends State<SatpamHomePage> {
  final AttendanceService _attendanceService =
      AttendanceService();

  Map<String, dynamic>? _todayAttendance;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadTodayAttendance();
  }

  // ==========================================================
  // LOAD PRESENSI HARI INI
  // ==========================================================

  Future<void> _loadTodayAttendance() async {
    final int? idSatpam =
        int.tryParse(widget.employee.employeeCode);

    if (idSatpam == null) {
      setState(() {
        _isLoading = false;
      });

      return;
    }

    try {
      final attendance =
          await _attendanceService.getTodayAttendance(
        idSatpam: idSatpam,
      );

      if (!mounted) return;

      setState(() {
        _todayAttendance = attendance;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'ERROR LOAD TODAY ATTENDANCE: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengambil data presensi: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // BUKA HALAMAN PRESENSI
  // ==========================================================

  Future<void> _openAttendance() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendancePage(
          employee: widget.employee,
        ),
      ),
    );

    // Setelah kembali dari halaman presensi,
    // refresh data Home.
    _loadTodayAttendance();
  }

  // ==========================================================
  // FORMAT TANGGAL
  // ==========================================================

  String _getTodayDate() {
    final now = DateTime.now();

    const days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${days[now.weekday % 7]}, '
        '${now.day} '
        '${months[now.month - 1]} '
        '${now.year}';
  }

  // ==========================================================
  // STATUS PRESENSI
  // ==========================================================

  String _getStatusText() {
    if (_todayAttendance == null) {
      return 'Belum Presensi';
    }

    final endTime =
        _todayAttendance!['endtime'];

    if (endTime == null ||
        endTime.toString().isEmpty) {
      return 'Sedang Bertugas';
    }

    return 'Sudah Selesai';
  }

  Color _getStatusColor() {
    if (_todayAttendance == null) {
      return Colors.orange;
    }

    final endTime =
        _todayAttendance!['endtime'];

    if (endTime == null ||
        endTime.toString().isEmpty) {
      return Colors.green;
    }

    return Colors.blue;
  }

  // ==========================================================
  // STATUS CARD
  // ==========================================================

  Widget _buildStatusCard() {
    final status = _getStatusText();
    final color = _getStatusColor();

    final startTime =
        _todayAttendance?['starttime']?.toString();

    final endTime =
        _todayAttendance?['endtime']?.toString();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      color.withOpacity(0.12),
                  child: Icon(
                    Icons.access_time,
                    color: color,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status Presensi',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(
              height: 28,
            ),

            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.login,
                    title: 'Jam Masuk',
                    value:
                        startTime ?? '-',
                  ),
                ),

                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.logout,
                    title: 'Jam Keluar',
                    value:
                        endTime ?? '-',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.work_history,
                    title: 'Shift',
                    value:
                        _todayAttendance?[
                                'id_shift']
                            ?.toString() ??
                        '-',
                  ),
                ),

                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.location_on,
                    title: 'Lokasi',
                    value:
                        _todayAttendance?[
                                'id_lokasi']
                            ?.toString() ??
                        '-',
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
  // INFO ITEM
  // ==========================================================

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Absensi Satpam',
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading
                ? null
                : _loadTodayAttendance,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadTodayAttendance,

        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ==================================================
            // SAPAAN
            // ==================================================

            Text(
              'Selamat Datang',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              widget.employee.employeeName,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'NIK / Kode: ${widget.employee.employeeCode}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // TANGGAL
            // ==================================================

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(14),
                color: Colors.grey.shade100,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 22,
                  ),

                  const SizedBox(width: 12),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hari Ini',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        _getTodayDate(),
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // LOADING
            // ==================================================

            if (_isLoading)
              const Padding(
                padding:
                    EdgeInsets.all(30),
                child: Center(
                  child:
                      CircularProgressIndicator(),
                ),
              )
            else
              _buildStatusCard(),

            const SizedBox(height: 24),

            // ==================================================
            // BUTTON PRESENSI
            // ==================================================

            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _isLoading
                        ? null
                        : _openAttendance,

                icon: Icon(
                  _todayAttendance == null
                      ? Icons.login
                      : Icons.access_time,
                ),

                label: Text(
                  _todayAttendance == null
                      ? 'PRESENSI MASUK'
                      : (_todayAttendance![
                                      'endtime'] ==
                                  null
                              ? 'PRESENSI KELUAR'
                              : 'LIHAT PRESENSI'),
                ),

                style:
                    ElevatedButton.styleFrom(
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // INFORMASI
            // ==================================================

            Card(
              elevation: 0,
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'Pastikan melakukan presensi masuk '
                        'dan presensi keluar sesuai jadwal '
                        'bertugas.',
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}