import 'package:flutter/material.dart';

import '../../models/employee.dart';

class TransactionPage extends StatelessWidget {
  final Employee employee;

  const TransactionPage({
    super.key,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaksi Presensi',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // DatePicker nanti
                    },
                    icon: const Icon(
                      Icons.calendar_today,
                    ),
                    label: const Text(
                      '27 Sep 2026',
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Shift',
                      border: OutlineInputBorder(),
                    ),
                    value: 'Semua',
                    items: const [
                      DropdownMenuItem(
                        value: 'Semua',
                        child: Text('Semua'),
                      ),
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
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text('Budi Santoso'),
                  subtitle: Text(
                    'Gate Utama • Shift Pagi\n'
                    'Masuk: 06:58 • Pulang: 15:03',
                  ),
                  isThreeLine: true,
                ),

                ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text('Andi Saputra'),
                  subtitle: Text(
                    'Gate Timur • Shift Pagi\n'
                    'Masuk: 07:02 • Pulang: -',
                  ),
                  isThreeLine: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}