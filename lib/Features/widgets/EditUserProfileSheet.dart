import 'package:flutter/material.dart';

class EditUserProfileResult {
  final String? displayName;
  final String? country;
  final String? bio;
  final int? age;
  final String? gender;

  const EditUserProfileResult({
    this.displayName,
    this.country,
    this.bio,
    this.age,
    this.gender,
  });

  bool get isEmpty =>
      displayName == null &&
      country == null &&
      bio == null &&
      age == null &&
      gender == null;
}

class EditUserProfileSheet extends StatefulWidget {
  final String currentDisplayName;
  final String currentCountry;
  final String currentBio;
  final int currentAge;
  final String currentGender;

  const EditUserProfileSheet({
    super.key,
    required this.currentDisplayName,
    required this.currentCountry,
    required this.currentBio,
    required this.currentAge,
    required this.currentGender,
  });

  @override
  State<EditUserProfileSheet> createState() => _EditUserProfileSheetState();
}

class _EditUserProfileSheetState extends State<EditUserProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _ageCtrl;
  late String _genderValue;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.currentDisplayName);
    _countryCtrl = TextEditingController(text: widget.currentCountry);
    _bioCtrl = TextEditingController(text: widget.currentBio);
    _ageCtrl = TextEditingController(text: widget.currentAge.toString());
    _genderValue = widget.currentGender;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _countryCtrl.dispose();
    _bioCtrl.dispose();
    _ageCtrl.dispose();
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

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    String? displayName =
        (_nameCtrl.text.trim().isEmpty || _nameCtrl.text.trim() == widget.currentDisplayName)
            ? null
            : _nameCtrl.text.trim();

    String? country =
        (_countryCtrl.text.trim().isEmpty || _countryCtrl.text.trim() == widget.currentCountry)
            ? null
            : _countryCtrl.text.trim();

    String? bio =
        (_bioCtrl.text.trim().isEmpty || _bioCtrl.text.trim() == widget.currentBio)
            ? null
            : _bioCtrl.text.trim();

    int? age;
    if (_ageCtrl.text.trim().isNotEmpty) {
      final parsed = int.tryParse(_ageCtrl.text.trim());
      if (parsed != null && parsed != widget.currentAge) {
        age = parsed;
      }
    }

    String? gender =
        (_genderValue.trim().isEmpty || _genderValue.trim() == widget.currentGender)
            ? null
            : _genderValue.trim();

    final result = EditUserProfileResult(
      displayName: displayName,
      country: country,
      bio: bio,
      age: age,
      gender: gender,
    );

    // إذا ما تغيّر شيء، نرجع فارغ (تقدر تتحقق خارجياً)
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 16, bottom + 16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                height: 4,
                width: 44,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              const Row(
                children: [
                  Icon(Icons.edit, color: Color(0xFF5B8DEF)),
                  SizedBox(width: 8),
                  Text(
                    "Edit Profile",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF192132)),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Fields grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 520;
                  return GridView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 2 : 1,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: isWide ? 3.4 : 3.0,
                    ),
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: _deco('Display Name', prefixIcon: const Icon(Icons.person_outline)),
                        maxLength: 40,
                        buildCounter: (_, {required currentLength, maxLength, required isFocused}) => const SizedBox(),
                        validator: (v) {
                          if (v != null && v.trim().isNotEmpty && v.trim().length < 2) {
                            return 'Too short';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _countryCtrl,
                        decoration: _deco('Country', prefixIcon: const Icon(Icons.flag_outlined)),
                        maxLength: 40,
                        buildCounter: (_, {required currentLength, maxLength, required isFocused}) => const SizedBox(),
                      ),
                      TextFormField(
                        controller: _ageCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _deco('Age', prefixIcon: const Icon(Icons.cake_outlined)),
                        validator: (v) {
                          if (v != null && v.trim().isNotEmpty) {
                            final n = int.tryParse(v.trim());
                            if (n == null || n < 1 || n > 120) return 'Invalid age';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _genderValue.isEmpty ? "NONE" : _genderValue,
                        decoration: _deco('Gender', prefixIcon: const Icon(Icons.wc_outlined)),
                        items: const [
                          DropdownMenuItem(value: 'MALE', child: Text('Male')),
                          DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                          DropdownMenuItem(value: 'NONE', child: Text('NONE')),
                        ],
                        onChanged: (val) => setState(() => _genderValue = val ?? ''),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioCtrl,
                maxLines: 3,
                maxLength: 200,
                buildCounter: (_, {required currentLength, maxLength, required isFocused}) => const SizedBox(),
                decoration: _deco('Bio', prefixIcon: const Icon(Icons.info_outline)),
              ),

              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
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
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B8DEF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
