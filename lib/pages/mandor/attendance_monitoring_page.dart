import 'package:flutter/material.dart';

import '../../models/employee.dart';
import '../../services/attendance_service.dart';

class AttendanceMonitoringPage extends StatefulWidget {
  final Employee employee;

  const AttendanceMonitoringPage({
    super.key,
    required this.employee,
  });

  @override
  State<AttendanceMonitoringPage> createState() =>
      _AttendanceMonitoringPageState();
}

class _AttendanceMonitoringPageState
    extends State<AttendanceMonitoringPage> {
  final AttendanceService _attendanceService =
      AttendanceService();

  // ==========================================================
  // DATA
  // ==========================================================

  List<Map<String, dynamic>> _attendanceList = [];

  bool _isLoading = true;

  // null = semua shift
  int? _selectedShift;

  @override
  void initState() {
    super.initState();

    _loadAttendance();
  }

  // ==========================================================
  // LOAD DATA PRESENSI
  // ==========================================================

  Future<void> _loadAttendance() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final data =
          await _attendanceService
              .getTodayAttendanceList();

      if (!mounted) return;

      setState(() {
        _attendanceList = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'ERROR LOAD ATTENDANCE MONITORING: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengambil data presensi: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // FILTER SHIFT
  // ==========================================================

  List<Map<String, dynamic>>
      get _filteredAttendance {
    if (_selectedShift == null) {
      return _attendanceList;
    }

    return _attendanceList.where((item) {
      final dynamic rawShift =
          item['id_shift'];

      final int? idShift =
          int.tryParse(rawShift.toString());

      return idShift == _selectedShift;
    }).toList();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Monitoring Presensi',
        ),

        actions: [
          IconButton(
            onPressed: _isLoading
                ? null
                : _loadAttendance,
            icon: const Icon(
              Icons.refresh,
            ),
            tooltip: 'Refresh',
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadAttendance,

        child: ListView(
          padding: const EdgeInsets.all(16),

          children: [
            _buildHeader(),

            const SizedBox(height: 16),

            _buildFilter(),

            const SizedBox(height: 16),

            _buildSummary(),

            const SizedBox(height: 16),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child:
                      CircularProgressIndicator(),
                ),
              )
            else if (_filteredAttendance.isEmpty)
              _buildEmpty()
            else
              _buildAttendanceList(),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader() {
    final now = DateTime.now();

    final date =
        '${now.day.toString().padLeft(2, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.year}';

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Text(
          'Data Presensi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Tanggal $date',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // FILTER
  // ==========================================================

  Widget _buildFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: Row(
        children: [
          _filterChip(
            label: 'Semua',
            value: null,
          ),

          const SizedBox(width: 8),

          _filterChip(
            label: 'Pagi',
            value: 1,
          ),

          const SizedBox(width: 8),

          _filterChip(
            label: 'Siang',
            value: 2,
          ),

          const SizedBox(width: 8),

          _filterChip(
            label: 'Malam',
            value: 3,
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required int? value,
  }) {
    final selected =
        _selectedShift == value;

    return FilterChip(
      label: Text(label),

      selected: selected,

      onSelected: (_) {
        setState(() {
          _selectedShift = value;
        });
      },
    );
  }

  // ==========================================================
  // SUMMARY
  // ==========================================================

  Widget _buildSummary() {
    final data = _filteredAttendance;

    int sedangBertugas = 0;
    int sudahSelesai = 0;

    for (final item in data) {
      final endtime = item['endtime'];

      if (endtime == null ||
          endtime.toString().isEmpty) {
        sedangBertugas++;
      } else {
        sudahSelesai++;
      }
    }

    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            title: 'Presensi',
            value: data.length.toString(),
            icon: Icons.groups,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _summaryCard(
            title: 'Bertugas',
            value:
                sedangBertugas.toString(),
            icon:
                Icons.person_pin_circle,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _summaryCard(
            title: 'Selesai',
            value:
                sudahSelesai.toString(),
            icon: Icons.check_circle,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SUMMARY CARD
  // ==========================================================

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          children: [
            Icon(
              icon,
              size: 25,
            ),

            const SizedBox(height: 6),

            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color:
                    Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ATTENDANCE LIST
  // ==========================================================

  Widget _buildAttendanceList() {
    return Column(
      children: _filteredAttendance
          .map(
            (item) =>
                _attendanceCard(item),
          )
          .toList(),
    );
  }

  // ==========================================================
  // ATTENDANCE CARD
  // ==========================================================

  Widget _attendanceCard(
    Map<String, dynamic> item,
  ) {
    final String idSatpam =
        item['id_satpam']
                ?.toString() ??
            '-';

    final String starttime =
        item['starttime']
                ?.toString() ??
            '-';

    final String endtime =
        item['endtime']
                ?.toString() ??
            '-';

    final String shift =
        item['id_shift']
                ?.toString() ??
            '-';

    final String lokasi =
        item['id_lokasi']
                ?.toString() ??
            '-';

    final bool isActive =
        item['endtime'] == null ||
            item['endtime']
                .toString()
                .isEmpty;

    final Map<String, dynamic>? shiftData =
        item['shift_data'] != null
            ? Map<String, dynamic>.from(
                item['shift_data'],
              )
            : null;

    final Map<String, dynamic>? lokasiData =
        item['lokasi_data'] != null
            ? Map<String, dynamic>.from(
                item['lokasi_data'],
              )
            : null;

    final String namaShift =
        shiftData?['shift']?.toString() ?? '-';

    final String namaLokasi =
        lokasiData?['lokasi']?.toString() ?? '-';

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      child: Padding(
        padding: const EdgeInsets.all(14),

        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,

                  child: Text(
                    idSatpam.isNotEmpty
                        ? idSatpam[0]
                        : '?',
                  ),
                ),

                const SizedBox(width: 12),


                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==========================================
                      // NAMA SATPAM
                      // ==========================================
                      Text(
                        'Satpam $idSatpam',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ==========================================
                      // SHIFT
                      // ==========================================
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              'Shift $namaShift',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // ==========================================
                      // LOKASI
                      // ==========================================
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              namaLokasi,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                _statusBadge(
                  isActive,
                ),
              ],
            ),

            const Divider(
              height: 24,
            ),

            Row(
              children: [
                Expanded(
                  child: _timeInfo(
                    icon: Icons.login,
                    title: 'Masuk',
                    value: starttime,
                  ),
                ),

                Expanded(
                  child: _timeInfo(
                    icon: Icons.logout,
                    title: 'Keluar',
                    value: endtime,
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
  // STATUS BADGE
  // ==========================================================

  Widget _statusBadge(
    bool isActive,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.shade50
            : Colors.blue.shade50,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Text(
        isActive
            ? 'Bertugas'
            : 'Selesai',

        style: TextStyle(
          fontSize: 11,
          fontWeight:
              FontWeight.bold,

          color: isActive
              ? Colors.green.shade700
              : Colors.blue.shade700,
        ),
      ),
    );
  }

  // ==========================================================
  // TIME INFO
  // ==========================================================

  Widget _timeInfo({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
        ),

        const SizedBox(width: 8),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color:
                    Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              value,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // EMPTY
  // ==========================================================

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(40),

      child: Column(
        children: [
          Icon(
            Icons
                .event_busy_outlined,
            size: 60,
            color:
                Colors.grey.shade400,
          ),

          const SizedBox(height: 12),

          Text(
            'Belum ada data presensi',
            style: TextStyle(
              fontSize: 16,
              color:
                  Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}