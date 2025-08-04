import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:hazodashborad/Core/res/bloc/auth_bloc.dart';
import 'package:hazodashborad/Core/res/bloc/auth_event.dart';
import 'package:hazodashborad/Core/res/bloc/auth_state.dart';
import 'package:hazodashborad/dashboard_screen.dart';
// import bloc, state, event, وغيرهم من ملفاتك



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;
  bool hidePassword = true;

  void showError(String message) {
    Flushbar(
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(10),
      backgroundColor: Colors.red.shade600,
      flushbarPosition: FlushbarPosition.TOP,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      duration: const Duration(seconds: 3),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    ).show(context);
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    // أرسل حدث تسجيل الدخول للبلوك
    BlocProvider.of<AuthBloc>(context).add(
      LoginEvent( email ,password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101a23),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(
                child: CircularProgressIndicator(color: Color(0xFF0bda5b)),
              ),
            );
          } else if (state is AuthSuccess) {
            Navigator.pop(context); // Close loading
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
              (route) => false,
            );
          } else if (state is AuthFailure) {
            Navigator.pop(context); // Close loading
            showError(state.error);
            print(state.error);
          }
        },
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 370,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF182634),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock, color: Color(0xFF90adcb), size: 52),
                    const SizedBox(height: 18),
                    const Text(
                      "Welcome Back!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Sign in to your account",
                      style: TextStyle(color: Color(0xFF90adcb), fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    // Email
                    TextFormField(
                      cursorColor: Color(0xFF101a23),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                      
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Color(0xFF90adcb)),
                        filled: true,
                        fillColor: const Color(0xFF223649),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.email, color: Color(0xFF90adcb)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) =>
                          val == null || val.isEmpty || !val.contains('@')
                              ? 'Enter a valid email'
                              : null,
                      onChanged: (val) => setState(() => email = val),
                    ),
                    const SizedBox(height: 18),

                    // Password
                    TextFormField(
                        onFieldSubmitted: (value) {
                          _login();
                        },
                                              style: const TextStyle(color: Colors.white),
                                 cursorColor: Color(0xFF101a23),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Color(0xFF90adcb)),
                        filled: true,
                        fillColor: const Color(0xFF223649),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF90adcb)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            hidePassword ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xFF90adcb),
                          ),
                          
                          onPressed: () => setState(() => hidePassword = !hidePassword),
                        ),
                      ),
                      obscureText: hidePassword,
                      validator: (val) =>
                          val == null || val.length < 2
                              ? 'Password must be at least 6 characters'
                              : null,
                      onChanged: (val) => setState(() => password = val),
                    ),
                    const SizedBox(height: 26),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: InkWell(
                        
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Color(0xFF223649),
                            backgroundColor: const Color(0xFF0bda5b),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _login, 
                          child: const Text(
                            "Sign In",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
