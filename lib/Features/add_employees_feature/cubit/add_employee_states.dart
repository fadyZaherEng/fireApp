abstract class AddEmployeeState {}

class AddEmployeeInitial extends AddEmployeeState {}

class AddEmployeeLoading extends AddEmployeeState {}

class AddEmployeeSuccess extends AddEmployeeState {
  final String message;

  AddEmployeeSuccess({required this.message});
}

class AddEmployeeFailure extends AddEmployeeState {
  final String error;

  AddEmployeeFailure({required this.error});
}
