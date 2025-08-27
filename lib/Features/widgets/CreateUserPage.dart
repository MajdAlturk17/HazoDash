import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hazodashborad/Core/res/Service/AuthService.dart';

import 'package:hazodashborad/Core/res/Service/UserService.dart'; 

class CreateUserPage extends StatefulWidget {

  const CreateUserPage({super.key, });

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String _role = 'USER';
  bool _obscure = true;
  bool _submitting = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  InputDecoration _deco(String label, {Widget? prefixIcon, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4E7EE), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4E7EE), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5B8DEF), width: 1.5),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
String? token =await AuthService().getToken();
    try {
      final service = UserService();
      await service.createUser(
        token: token!,
        fullName: _fullNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        role: _role,
        password: _passwordCtrl.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('User created successfully'),
        ),
      );

      Navigator.pop(context, true); // ارجع ومعك نتيجة نجاح (اختياري)
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFFF6C8B),
          content: Text('Create failed: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Create User',
          style: TextStyle(
            color: Color(0xFF192132),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF192132)),
        actions: [
          if (_submitting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Card(
            color: Colors.white,
            elevation: 16,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: const BorderSide(color: Color(0xFFE4E7EE), width: 2),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // العنوان
                    const Row(
                      children: [
                        Icon(Icons.person_add_alt_1, color: Color(0xFF5B8DEF)),
                        SizedBox(width: 8),
                        Text(
                          'New User',
                          style: TextStyle(
                            color: Color(0xFF192132),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // شبكة الحقول
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth > 520;
                        return GridView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: wide ? 2 : 1,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: wide ? 3.4 : 3.0,
                          ),
                          children: [
                            TextFormField(
                              controller: _fullNameCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: _deco('Full name', prefixIcon: const Icon(Icons.badge_outlined)),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Full name is required';
                                if (v.trim().length < 2) return 'Too short';
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _emailCtrl,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _deco('Email', prefixIcon: const Icon(Icons.email_outlined)),
                              validator: (v) {
                                final val = v?.trim() ?? '';
                                final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                                if (val.isEmpty) return 'Email is required';
                                if (!emailRegex.hasMatch(val)) return 'Invalid email';
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _phoneCtrl,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]'))],
                              decoration: _deco('Phone number', prefixIcon: const Icon(Icons.phone_outlined), hint: '+49111111111'),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Phone is required';
                                if (v.trim().length < 6) return 'Too short';
                                return null;
                              },
                            ),
                            DropdownButtonFormField<String>(
                              value: _role,
                              decoration: _deco('Role', prefixIcon: const Icon(Icons.security_outlined)),
                              items: const [
                                DropdownMenuItem(value: 'USER', child: Text('USER')),
                                DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                                DropdownMenuItem(value: 'SUPER_ADMIN', child: Text('SUPER_ADMIN')),
                              ],
                              onChanged: (val) => setState(() => _role = val!),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: _deco('Password', prefixIcon: const Icon(Icons.lock_outline)).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) {
                        final val = v ?? '';
                        if (val.isEmpty) return 'Password is required';
                        if (val.length < 6) return 'Min 6 chars';
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _submitting ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF5B8DEF)),
                              foregroundColor: const Color(0xFF5B8DEF),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _submitting ? null : _submit,
                            icon: _submitting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.check, color: Colors.white),
                            label: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B8DEF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
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
