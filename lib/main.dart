import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// import 'core/supabase_client.dart';
import 'pages/login/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kwldxqorcigwrvqtjbtx.supabase.co',
    publishableKey: 'sb_publishable_Xoub7sYutcKP1O0Ea8w82g_M4DzRXOu',
  );

  runApp(const SecurityAttendanceApp());
}

class SecurityAttendanceApp
    extends StatelessWidget {
  const SecurityAttendanceApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Absensi Satpam',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const LoginPage(),
    );
  }
}