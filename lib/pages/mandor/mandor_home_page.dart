import 'package:flutter/material.dart';

import '../../models/employee.dart';
import '../../services/attendance_service.dart';
import 'transaction_page.dart';
import 'attendance_monitoring_page.dart';

class MandorHomePage extends StatefulWidget {
  final Employee employee;

  const MandorHomePage({
    super.key,
    required this.employee,
  });

  @override
  State<MandorHomePage> createState() =>
      _MandorHomePageState();
}

class _MandorHomePageState
    extends State<MandorHomePage> {
  final AttendanceService _attendanceService =
      AttendanceService();

  int _selectedIndex = 0;

  bool _isLoading = true;

  Map<String, dynamic>? _dashboard;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _loadDashboard();
  }

  // ==========================================================
  // LOAD DASHBOARD
  // ==========================================================

  Future<void> _loadDashboard() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final result =
          await _attendanceService
              .getMandorDashboard();

      if (!mounted) return;

      setState(() {
        _dashboard = result;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'ERROR LOAD MANDOR DASHBOARD: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengambil data dashboard: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboard(),

      AttendanceMonitoringPage(
        employee: widget.employee,
      ),

      TransactionPage(
        employee: widget.employee,
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],

      bottomNavigationBar:
          NavigationBar(
        selectedIndex: _selectedIndex,

        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Refresh ketika kembali ke Home
          if (index == 0) {
            _loadDashboard();
          }
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.dashboard_outlined,
            ),
            selectedIcon: Icon(
              Icons.dashboard,
            ),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.access_time_outlined,
            ),
            selectedIcon: Icon(
              Icons.access_time,
            ),
            label: 'Presensi',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.receipt_long_outlined,
            ),
            selectedIcon: Icon(
              Icons.receipt_long,
            ),
            label: 'Transaksi',
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DASHBOARD
  // ==========================================================

  Widget _buildDashboard() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboard,

        child: ListView(
          padding: const EdgeInsets.all(20),

          children: [
            _buildHeader(),

            const SizedBox(height: 20),

            _buildDateCard(),

            const SizedBox(height: 24),

            const Text(
              'Presensi Hari Ini',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child:
                      CircularProgressIndicator(),
                ),
              )
            else
              _buildSummary(),

            const SizedBox(height: 28),

            _buildShiftSection(),

            const SizedBox(height: 24),

            _buildAttendanceButton(),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          'Selamat Datang',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
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
          'Mandor Satpam',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // DATE
  // ==========================================================

  Widget _buildDateCard() {
    final now = DateTime.now();

    final date =
        '${now.day.toString().padLeft(2, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.year}';

    return Card(
      elevation: 0,
      color: Colors.grey.shade100,

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
            ),

            const SizedBox(width: 12),

            Text(
              date,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SUMMARY
  // ==========================================================

  Widget _buildSummary() {
    final total =
        _dashboard?['totalSatpam'] ?? 0;

    final hadir =
        _dashboard?['sudahPresensi'] ?? 0;

    final belum =
        _dashboard?['belumPresensi'] ?? 0;

    final bertugas =
        _dashboard?['sedangBertugas'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'Total Satpam',
                value: total.toString(),
                icon: Icons.groups,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _summaryCard(
                title: 'Sudah Presensi',
                value: hadir.toString(),
                icon: Icons.check_circle,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'Sedang Bertugas',
                value: bertugas.toString(),
                icon:
                    Icons.person_pin_circle,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _summaryCard(
                title: 'Belum Presensi',
                value: belum.toString(),
                icon:
                    Icons.warning_amber,
              ),
            ),
          ],
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
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Icon(
              icon,
              size: 28,
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color:
                    Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SHIFT
  // ==========================================================

  Widget _buildShiftSection() {
    final shift =
        _dashboard?['shift']
            as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Text(
          'Presensi Berdasarkan Shift',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        _shiftCard(
          shiftName: 'Pagi',
          hadir: shift?[1]?['hadir'] ?? 0,
        ),

        _shiftCard(
          shiftName: 'Siang',
          hadir: shift?[2]?['hadir'] ?? 0,
        ),

        _shiftCard(
          shiftName: 'Malam',
          hadir: shift?[3]?['hadir'] ?? 0,
        ),
      ],
    );
  }

  // ==========================================================
  // SHIFT CARD
  // ==========================================================

  Widget _shiftCard({
    required String shiftName,
    required int hadir,
  }) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 10),

      child: ListTile(
        leading: const Icon(
          Icons.schedule,
        ),

        title: Text(
          'Shift $shiftName',
        ),

        subtitle: Text(
          '$hadir satpam sudah presensi',
        ),

        trailing: const Icon(
          Icons.chevron_right,
        ),
      ),
    );
  }

  // ==========================================================
  // BUTTON
  // ==========================================================

  Widget _buildAttendanceButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,

      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _selectedIndex = 1;
          });
        },

        icon: const Icon(
          Icons.access_time,
        ),

        label: const Text(
          'Lihat Data Presensi',
        ),
      ),
    );
  }
}