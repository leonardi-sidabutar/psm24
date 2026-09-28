import '../core/supabase_client.dart';
import '../models/employee.dart';

class AuthService {
  final _supabase = SupabaseClientService.client;

  Future<Employee?> login(String employeeCode) async {
    final response = await _supabase
        .from('satpam')
        .select()
        .eq('nomor', employeeCode)
        // .eq('status', 'ACTIVE')
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Employee.fromMap(response);
  }
}