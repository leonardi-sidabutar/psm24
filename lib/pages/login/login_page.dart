import 'package:flutter/material.dart';

import '../../models/employee.dart';
import '../../services/auth_service.dart';
import '../mandor/mandor_home_page.dart';
import '../satpam/satpam_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _employeeController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _employeeController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final employeeCode = _employeeController.text.trim();

    if (employeeCode.isEmpty) {
      _showMessage('Masukkan kode employee');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Employee? employee =
          await _authService.login(employeeCode);

      if (!mounted) return;

      if (employee == null) {
        _showMessage('Employee tidak ditemukan');
        return;
      }

      if (employee.isMandor) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MandorHomePage(
              employee: employee,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SatpamHomePage(
              employee: employee,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Terjadi kesalahan saat login',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Satpam'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            TextField(
              controller: _employeeController,
              decoration: const InputDecoration(
                labelText: 'Kode Employee',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('LOGIN'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}