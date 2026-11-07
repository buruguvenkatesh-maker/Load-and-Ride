import 'package:flutter/material.dart';
import 'brand_logo.dart';

class DemoProfile {
  const DemoProfile({required this.name, required this.phone, required this.role});
  final String name, phone, role;
}

// Controllers and form state belong to this route and are disposed only after
// Flutter removes the route, including its exit animation and keyboard focus.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, required this.initial});
  final DemoProfile initial;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController phone;
  late String role;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.initial.name);
    phone = TextEditingController(text: widget.initial.phone);
    role = widget.initial.role;
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    super.dispose();
  }

  void save() {
    if (!formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(DemoProfile(
      name: name.text.trim(), phone: phone.text.trim(), role: role));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Registration')),
    body: SafeArea(child: Form(key: formKey, child: ListView(
      padding: const EdgeInsets.all(24), keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        const Center(child: BrandLogo(size: 64)),
        const SizedBox(height: 12),
        Text('$role registration', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        const Text('Create a local demo profile to explore Load and Ride.\nDemo only • No SMS will be sent. Your phone is not verified.'),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(key: const ValueKey('registration-role'),
          initialValue: role, isExpanded: true,
          decoration: const InputDecoration(labelText: 'Register as'),
          items: [for (final value in ['Customer', 'Vehicle Owner'])
            DropdownMenuItem(value: value, child: Text(value))],
          onChanged: (value) { if (value != null) setState(() => role = value); }),
        const SizedBox(height: 16),
        TextFormField(key: const ValueKey('registration-name'), controller: name,
          textInputAction: TextInputAction.next, textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Full name'),
          validator: (value) => value == null || value.trim().length < 2 ? 'Enter your name' : null),
        const SizedBox(height: 16),
        TextFormField(key: const ValueKey('registration-phone'), controller: phone,
          keyboardType: TextInputType.phone, textInputAction: TextInputAction.done,
          decoration: const InputDecoration(labelText: 'Indian mobile number', prefixText: '+91 '),
          validator: (value) => RegExp(r'^[6-9][0-9]{9}$').hasMatch(value?.trim() ?? '')
            ? null : 'Enter a valid 10-digit mobile number'),
        const SizedBox(height: 24),
        FilledButton.icon(onPressed: save, icon: const Icon(Icons.check_circle_outline),
          label: const Text('Save demo profile')),
        const SizedBox(height: 12),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
      ]))),
  );
}
