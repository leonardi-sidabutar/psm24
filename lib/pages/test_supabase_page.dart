// import 'package:flutter/material.dart';
// import '../core/supabase_client.dart';

// class TestSupabasePage extends StatefulWidget {
//   const TestSupabasePage({super.key});

//   @override
//   State<TestSupabasePage> createState() => _TestSupabasePageState();
// }

// class _TestSupabasePageState extends State<TestSupabasePage> {

//   List<Map<String, dynamic>> data = [];

//   bool loading = false;

//   String? errorMessage;

//   Future<void> loadData() async {
//     setState(() {
//       loading = true;
//       errorMessage = null;
//     });

//     try {
//       final result = await supabase
//           .from('lokasi')
//           .select();

//       setState(() {
//         data = List<Map<String, dynamic>>.from(result);
//       });
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString();
//       });
//     } finally {
//       setState(() {
//         loading = false;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();

//     loadData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Test Supabase'),
//       ),
//       body: loading
//           ? const Center(
//               child: CircularProgressIndicator(),
//             )
//           : errorMessage != null
//               ? Center(
//                   child: Text(
//                     errorMessage!,
//                     textAlign: TextAlign.center,
//                   ),
//                 )
//               : ListView.builder(
//                   itemCount: data.length,
//                   itemBuilder: (context, index) {
//                     final item = data[index];

//                     return ListTile(
//                       title: Text(
//                         'ID: ${item['id']}',
//                       ),
//                       subtitle: Text(
//                         'Lokasi: ${item['lokasi']} | '
//                         // 'Tanggal: ${item['date']}',
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }
