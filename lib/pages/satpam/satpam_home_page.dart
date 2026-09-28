import 'package:flutter/material.dart';

import '../../models/employee.dart';
import 'attendance_page.dart';

class SatpamHomePage extends StatelessWidget {
  final Employee employee;

  const SatpamHomePage({
    super.key,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Absensi Satpam',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            Text(
              employee.employeeName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            const Card(
              child: ListTile(
                leading: Icon(
                  Icons.access_time,
                ),
                title: Text(
                  'Presensi Hari Ini',
                ),
                subtitle: Text(
                  'Belum melakukan presensi',
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AttendancePage(
                        employee: employee,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'PRESENSI',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}