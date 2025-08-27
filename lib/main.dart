import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hazodashborad/Core/res/Service/AuthService.dart';
import 'package:hazodashborad/Core/res/Service/UserService.dart';

import 'package:hazodashborad/Core/res/bloc/auth_bloc.dart';
import 'package:hazodashborad/Core/res/bloc/bloc/user_profile_bloc.dart';
import 'package:hazodashborad/Features/Auth/Home/login_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      // نوفّر UserService مرة واحدة لكل الشجرة
      create: (_) => UserService(),
      child: MultiBlocProvider(
        providers: [
          // مصادقة
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(AuthService()),
          ),

          // بروفايل المستخدم (جلب/تعديل/حذف)
          BlocProvider<UserProfileBloc>(
            create: (context) => UserProfileBloc(
              service: RepositoryProvider.of<UserService>(context),
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const LoginScreen(),
        ),
      ),
    );
  }
}
