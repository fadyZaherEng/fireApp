import 'package:flutter/material.dart';
import '../data/models/terms_models.dart';
import '../data/services/terms_api_service.dart';

class TermsViewModel extends ChangeNotifier {
  final TermsAndConditionsApiService _termsApiService = TermsAndConditionsApiService();
  final TextEditingController termsController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isLoadingEmployees = false;
  List<Employee> _employees = [];
  Employee? _selectedEmployee;
  String? _employeesError;

  bool get isLoading => _isLoading;
  bool get isLoadingEmployees => _isLoadingEmployees;
  List<Employee> get employees => _employees;
  Employee? get selectedEmployee => _selectedEmployee;
  String? get employeesError => _employeesError;

  void setSelectedEmployee(Employee? employee) {
    _selectedEmployee = employee;
    notifyListeners();
  }

  Future<void> loadEmployees() async {
    _isLoadingEmployees = true;
    _employeesError = null;
    notifyListeners();

    try {
      final employees = await _termsApiService.getContractDocumentationEmployees();
      _employees = employees.where((e) => !e.isDeleted).toList();
      _isLoadingEmployees = false;
      notifyListeners();
    } catch (e) {
      _employeesError = e.toString();
      _isLoadingEmployees = false;
      notifyListeners();
    }
  }

  Future<bool> saveTerms(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    if (_selectedEmployee == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final termsText = termsController.text.trim();
      final clauses = termsText
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => TermsClause(text: line.trim()))
          .toList();

      if (clauses.isEmpty) {
        clauses.add(TermsClause(text: termsText));
      }

      final request = CreateTermsRequest(
        employee: _selectedEmployee!.id,
        responsibleEmployeeName: _selectedEmployee!.fullName,
        clauses: clauses,
        isFirstTime: true,
      );

      final response = await _termsApiService.createTermsAndConditions(request);
      _isLoading = false;
      notifyListeners();

      return response.success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    termsController.dispose();
    super.dispose();
  }
}
