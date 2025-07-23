import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';

class HomeViewModel extends ChangeNotifier {
  final BuildContext context;

  HomeViewModel(this.context);

  Future<void> handleRefresh() async {
    context.read<HomeCubit>().checkAuthentication();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  bool get isRTL => Directionality.of(context) == TextDirection.rtl;
}
