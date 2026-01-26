import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khel_mitra/core/theme/app_theme.dart';
import 'package:khel_mitra/features/profile/presentation/bloc/profile_bloc.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  DateTime _dob = DateTime(2005, 1, 1);
  String _gender = 'Male';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Create Profile",
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              const Text(
                "Athlete Details",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Please fill in your details",
                style: TextStyle(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Full Name
              const Text("FULL NAME", style: AppTheme.labelText),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                style: AppTheme.bodyText,
                decoration: InputDecoration(
                  hintText: "Enter your full name",
                  hintStyle: AppTheme.hintText,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.divider),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.accent, width: 2),
                  ),
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 32),

              // Gender
              const Text("GENDER", style: AppTheme.labelText),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _gender,
                dropdownColor: AppTheme.surface,
                style: AppTheme.bodyText,
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.divider),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.accent, width: 2),
                  ),
                ),
                items: ["Male", "Female", "Other"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v!),
              ),
              const SizedBox(height: 32),

              // Height
              const Text("HEIGHT", style: AppTheme.labelText),
              const SizedBox(height: 8),
              TextFormField(
                controller: _heightCtrl,
                style: AppTheme.bodyText,
                decoration: InputDecoration(
                  hintText: "Enter your height",
                  hintStyle: AppTheme.hintText,
                  suffixText: "cm",
                  suffixStyle: const TextStyle(color: AppTheme.textSecondary),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.divider),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.accent, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required";
                  final h = double.tryParse(v);
                  if (h == null || h < 50 || h > 250) return "Invalid height";
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Date of Birth
              const Text("DATE OF BIRTH", style: AppTheme.labelText),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _dob,
                    firstDate: DateTime(1980),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppTheme.accent,
                            surface: AppTheme.surface,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (d != null) setState(() => _dob = d);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppTheme.divider),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_dob.day}/${_dob.month}/${_dob.year}",
                        style: AppTheme.bodyText,
                      ),
                      const Icon(Icons.calendar_today, color: AppTheme.accent),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Save Button
              ElevatedButton(
                style: AppTheme.primaryButton,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<ProfileBloc>().add(SubmitProfile(
                      name: _nameCtrl.text,
                      dob: _dob,
                      gender: _gender,
                      heightCm: double.parse(_heightCtrl.text),
                    ));
                  }
                },
                child: const Text("Save Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
