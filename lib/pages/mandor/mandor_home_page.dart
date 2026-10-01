import 'package:flutter/material.dart';

import '../../models/employee.dart';
import 'transaction_page.dart';
import '../satpam/attendance_page.dart';

class MandorHomePage extends StatefulWidget {
  final Employee employee;

  const MandorHomePage({
    super.key,
    required this.employee,
  });

  @override
  State<MandorHomePage> createState() => _MandorHomePageState();
}

class _MandorHomePageState
    extends State<MandorHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboard(),
      TransactionPage(
        employee: widget.employee,
      ),
      AttendancePage(
        employee: widget.employee,
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.access_time_outlined),
            selectedIcon: Icon(Icons.access_time),
            label: 'Presensi',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              widget.employee.employeeName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Mandor Satpam',
              style: TextStyle(
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Presensi Hari Ini',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    title: 'Satpam',
                    value: '12',
                    icon: Icons.groups,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _summaryCard(
                    title: 'Presensi',
                    value: '10',
                    icon: Icons.check_circle,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _summaryCard(
              title: 'Belum Presensi',
              value: '2',
              icon: Icons.warning_amber,
            ),

            const SizedBox(height: 28),

            const Text(
              'Ringkasan Shift',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _shiftCard(
              shiftName: 'Pagi',
              hadir: 8,
              total: 8,
            ),

            _shiftCard(
              shiftName: 'Siang',
              hadir: 2,
              total: 2,
            ),

            _shiftCard(
              shiftName: 'Malam',
              hadir: 0,
              total: 2,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
                icon: const Icon(
                  Icons.receipt_long,
                ),
                label: const Text(
                  'Lihat Transaksi Presensi',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
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
          ],
        ),
      ),
    );
  }

  Widget _shiftCard({
    required String shiftName,
    required int hadir,
    required int total,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(
          Icons.schedule,
        ),
        title: Text(
          'Shift $shiftName',
        ),
        trailing: Text(
          '$hadir / $total',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}