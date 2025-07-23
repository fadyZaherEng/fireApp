import 'package:flutter_bloc/flutter_bloc.dart';

/// Base cubit that provides safe state emission to prevent
/// "Bad state: Cannot emit new states after calling close" errors
abstract class BaseCubit<State> extends Cubit<State> {
  BaseCubit(State initialState) : super(initialState);

  /// Safe emit that checks if the cubit is closed before emitting
  @override
  void emit(State state) {
    if (!isClosed) {
      super.emit(state);
    }
  }
}
