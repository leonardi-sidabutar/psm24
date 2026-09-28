import 'package:flutter/material.dart';

import '../../models/employee.dart';

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

  String? selectedLocation;
  String? selectedShift;

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
            Text(
              widget.employee.employeeName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Lokasi',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: '1',
                  child: Text('Pos Kantor Besar'),
                ),
                DropdownMenuItem(
                  value: '2',
                  child: Text('Pos Diponogero'),
                ),
                DropdownMenuItem(
                  value: '3',
                  child: Text('Pos Tengku Daud'),
                ),
                DropdownMenuItem(
                  value: '4',
                  child: Text('Pos Pattimura'),
                ),
                DropdownMenuItem(
                  value: '5',
                  child: Text('Pos Komplek II'),
                ),
                DropdownMenuItem(
                  value: '6',
                  child: Text('Pos Komplek IV'),
                ),
                DropdownMenuItem(
                  value: '7',
                  child: Text('Dinas Luar'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedLocation = value;
                });
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Shift',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Pagi',
                  child: Text('Pagi'),
                ),
                DropdownMenuItem(
                  value: 'Siang',
                  child: Text('Siang'),
                ),
                DropdownMenuItem(
                  value: 'Malam',
                  child: Text('Malam'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedShift = value;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Kamera / selfie nanti
                },
                icon: const Icon(
                  Icons.camera_alt,
                ),
                label: const Text(
                  'PRESENSI MASUK',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}