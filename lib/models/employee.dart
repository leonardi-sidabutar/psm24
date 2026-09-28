class Employee {
  final String employeeCode;
  final String employeeName;
  final String role;

  Employee({
    required this.employeeCode,
    required this.employeeName,
    required this.role,
  });

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      employeeCode: map['nomor'] ?? '',
      employeeName: map['nama'] ?? '',
      role: map['role'] ?? 'SATPAM',
    );
  }

  bool get isMandor => role == 'MANDOR';

  bool get isSatpam => role == 'SATPAM';
}