import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hazodashborad/Core/res/Service/AuthService.dart';
import 'package:hazodashborad/Core/res/bloc/auth_bloc.dart';
import 'package:hazodashborad/Features/Auth/Home/login_screen.dart';
import 'package:hazodashborad/dashboard_screen.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(AuthService()),
          // إذا كان لديك Repository مرره هنا
          // create: (context) => AuthBloc(authRepository: AuthRepository()),
        ),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
      ),
    );
  }
}
