import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../data/services/employee_api_service.dart';
import '../data/models/employee_models.dart';
import 'add_employee_states.dart';

class AddEmployeeCubit extends Cubit<AddEmployeeState> {
  final EmployeeApiService _employeeApiService;
  final Logger _logger = Logger();

  AddEmployeeCubit(this._employeeApiService) : super(AddEmployeeInitial());

  Future<void> addEmployee({
    required String fullName,
    required String phoneNumber,
    required String permission,
    required String profileImage,
    required String jobTitle,
  }) async {
    _logger.i('👥 AddEmployeeCubit: Adding employee $fullName');
    emit(AddEmployeeLoading());

    try {
      final request = AddEmployeeRequest(
        fullName: fullName,
        phoneNumber: phoneNumber,
        permission: permission, // Use the actual permission parameter
        profileImage: profileImage,
        jobTitle: jobTitle,
      );

      final response = await _employeeApiService.addEmployee(request);

      if (response.success) {
        _logger.i('✅ AddEmployeeCubit: Employee added successfully');
        emit(AddEmployeeSuccess(message: response.message));
      } else {
        _logger.w(
            '⚠️ AddEmployeeCubit: Add employee failed - ${response.message}');
        emit(AddEmployeeFailure(error: response.message));
      }
    } catch (e) {
      _logger.e('💥 AddEmployeeCubit: Unexpected error in addEmployee - $e');
      emit(AddEmployeeFailure(error: 'An unexpected error occurred'));
    }
  }

  List<Employee> employees = [];
  int currentEmployeeIndex = 0;

  void addNewEmployee() {
    employees.add(Employee(
      fullName: '',
      phoneNumber: '',
      permission: 'management',
      profileImage: '',
      jobTitle: '',
      selectedRole: 'management',
      selectedCountry: 'SA',
    ));
    currentEmployeeIndex = employees.length - 1;
    emit(AddEmployeeInitial());
  }

  void updateCurrentEmployee(Employee employee) {
    if (currentEmployeeIndex < employees.length) {
      employees[currentEmployeeIndex] = employee;
    }
  }

  void switchToEmployee(int index) {
    if (index < employees.length) {
      currentEmployeeIndex = index;
      emit(AddEmployeeInitial());
    }
  }

  Future<void> updateEmployee({
    required String employeeId,
    required String fullName,
    required String phoneNumber,
    required String permission,
    required String profileImage,
    required String jobTitle,
  }) async {
    _logger.i('📝 AddEmployeeCubit: Updating employee $fullName');
    emit(AddEmployeeLoading());

    try {
      final request = AddEmployeeRequest(
        fullName: fullName,
        phoneNumber: phoneNumber,
        permission: permission,
        profileImage: profileImage,
        jobTitle: jobTitle,
      );

      final response =
          await _employeeApiService.updateEmployee(employeeId, request);

      if (response.success) {
        _logger.i('✅ AddEmployeeCubit: Employee updated successfully');
        emit(AddEmployeeSuccess(message: response.message));
      } else {
        _logger.w(
            '⚠️ AddEmployeeCubit: Update employee failed - ${response.message}');
        emit(AddEmployeeFailure(error: response.message));
      }
    } catch (e) {
      _logger.e('💥 AddEmployeeCubit: Unexpected error in updateEmployee - $e');
      emit(AddEmployeeFailure(error: 'An unexpected error occurred'));
    }
  }

  void resetState() {
    _logger.d('🔄 AddEmployeeCubit: Resetting state');
    emit(AddEmployeeInitial());
  }
}
