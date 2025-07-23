import '../data/models/mall_model.dart';

abstract class MallState {}

class MallInitial extends MallState {}

class MallLoading extends MallState {}

class MallSuccess extends MallState {
  final List<Mall> malls;

  MallSuccess({required this.malls});
}

class MallError extends MallState {
  final String message;

  MallError({required this.message});
}
