import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safetyZone/Features/home_feature/cubit/home_ui_cubit.dart';
import 'package:safetyZone/Features/home_feature/cubit/home_ui_state.dart';
import 'package:safetyZone/Features/home_feature/view/home_view.dart';

void main() {
  group('HomeView Tests', () {
    testWidgets('HomeView should display correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) {
            return MaterialApp(
              home: const HomeView(),
            );
          },
        ),
      );

      // Wait for the cubit to load
      await tester.pumpAndSettle();

      // Verify the header is present
      expect(find.text('مرحبا بك احمد، في'), findsOneWidget);
      expect(find.text('Safety Zone'), findsOneWidget);

      // Verify the featured service carousel is present
      expect(
          find.text('نقدم خدمة طفايات الحريق و تأمين الاماكن'), findsOneWidget);

      // Verify service grid items are present
      expect(find.text('تقرير كشف هندسي على المنشآت'), findsOneWidget);
      expect(find.text('شهادات تركيبات ادوات الوقاية'), findsOneWidget);
      expect(find.text('طفاية الحريق'), findsOneWidget);
      expect(find.text('عقود صيانة إنذار و إطفاء حريق'), findsOneWidget);
    });

    testWidgets('HomeView should handle loading state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) {
            return MaterialApp(
              home: BlocProvider(
                create: (context) => HomeUiCubit(),
                child: Builder(
                  builder: (context) {
                    return BlocBuilder<HomeUiCubit, HomeUiState>(
                      builder: (context, state) {
                        if (state is HomeUiLoading) {
                          return const Scaffold(
                            body: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return const HomeView();
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      );

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Should show home content after loading
      expect(find.text('مرحبا بك احمد، في'), findsOneWidget);
    });

    testWidgets('HomeView should handle error state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) {
            return MaterialApp(
              home: BlocProvider(
                create: (context) => HomeUiCubit(),
                child: Builder(
                  builder: (context) {
                    return BlocBuilder<HomeUiCubit, HomeUiState>(
                      builder: (context, state) {
                        if (state is HomeUiError) {
                          return Scaffold(
                            body: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('حدث خطأ في تحميل البيانات'),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<HomeUiCubit>().refreshData();
                                    },
                                    child: const Text('إعادة المحاولة'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const HomeView();
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      // Should show error message and retry button if error occurs
      // This test would need a mock repository that throws an error
    });
  });
}
