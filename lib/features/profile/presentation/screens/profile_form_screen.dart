import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Athlete Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const Gap(16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: "Gender", border: OutlineInputBorder()),
                items: ["Male", "Female", "Other"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v!),
              ),
              const Gap(16),
              TextFormField(
                controller: _heightCtrl,
                decoration: const InputDecoration(labelText: "Height (CM)", border: OutlineInputBorder(), suffixText: "cm"),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required";
                  final h = double.tryParse(v);
                  if (h == null || h < 50 || h > 250) return "Invalid height";
                  return null;
                },
              ),
              const Gap(16),
              ListTile(
                title: const Text("Date of Birth"),
                subtitle: Text("${_dob.day}/${_dob.month}/${_dob.year}"),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.grey)),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _dob,
                    firstDate: DateTime(1980),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) setState(() => _dob = d);
                },
              ),
              const Gap(32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
