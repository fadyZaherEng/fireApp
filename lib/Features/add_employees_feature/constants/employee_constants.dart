class EmployeeConstants {
  static final List<String> roles = [
    'management',
    'contractDocumentation',
    'reportReceiving',
    'repairApproval',
    'requestSubmission'
  ];

  static final Map<String, String> roleMapping = {
    'management': 'management',
    'contractDocumentation': 'Contract Documentation',
    'reportReceiving': 'Report Receiving',
    'repairApproval': 'Repair Approval',
    'requestSubmission': 'Request Submission'
  };

  static final Map<String, String> jobTitleMapping = {
    'management': 'مدير النظام',
    'contractDocumentation': 'موثق عقود',
    'reportReceiving': 'مستقبل تقارير',
    'repairApproval': 'موافق إصلاح',
    'requestSubmission': 'مقدم طلبات'
  };

  static final List<Map<String, String>> countries = [
    {'code': 'SA', 'name': 'Saudi Arabia', 'dialCode': '+966', 'flag': '🇸🇦'},
  ];
}
