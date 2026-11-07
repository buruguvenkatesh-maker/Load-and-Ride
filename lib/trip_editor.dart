import 'package:flutter/material.dart';
import 'models.dart';

class TripEditor extends StatefulWidget {
  const TripEditor({super.key, required this.pickup, required this.drop,
    required this.service, required this.owner});
  final String pickup, drop, owner;
  final Service service;
  @override
  State<TripEditor> createState() => _TripEditorState();
}

class _TripEditorState extends State<TripEditor> {
  final formKey = GlobalKey<FormState>();
  final vehicle = TextEditingController();
  final capacity = TextEditingController();
  final price = TextEditingController();
  final via = TextEditingController();
  DateTime departure = DateTime.now().add(const Duration(days: 1));
  String? error;

  @override
  void dispose() {
    vehicle.dispose(); capacity.dispose(); price.dispose(); via.dispose();
    super.dispose();
  }

  String? positive(String? value) => (int.tryParse(value?.trim() ?? '') ?? 0) > 0
    ? null : 'Enter a positive whole number';

  Future<void> pickDeparture() async {
    final now = DateTime.now();
    final day = await showDatePicker(context: context, initialDate: departure,
      firstDate: now, lastDate: now.add(const Duration(days: 365)));
    if (!mounted || day == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(departure));
    if (!mounted || time == null) return;
    setState(() => departure = DateTime(day.year, day.month, day.day, time.hour, time.minute));
  }

  void save() {
    if (!formKey.currentState!.validate()) return;
    if (!departure.isAfter(DateTime.now())) {
      setState(() => error = 'Choose a future departure.'); return;
    }
    final stops = [widget.pickup,
      ...via.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty), widget.drop];
    if (stops.map(locationKey).toSet().length != stops.length) {
      setState(() => error = 'Each stop must be unique.'); return;
    }
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(Trip(id: 'demo-${DateTime.now().microsecondsSinceEpoch}',
      service: widget.service, stops: stops, owner: '${widget.owner} • Demo owner',
      vehicle: vehicle.text.trim(), capacity: int.parse(capacity.text.trim()),
      price: int.parse(price.text.trim()), departure: departure));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Demo vehicle trip')),
    body: SafeArea(child: Form(key: formKey, child: ListView(
      padding: const EdgeInsets.all(24), keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Text('${widget.pickup} → ${widget.drop}', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const Text('Sample data only • This trip stays on this device until restart.'),
        const SizedBox(height: 20),
        TextFormField(key: const ValueKey('trip-vehicle'), controller: vehicle,
          decoration: const InputDecoration(labelText: 'Vehicle model and registration'),
          validator: (value) => value == null || value.trim().isEmpty ? 'Enter vehicle details' : null),
        const SizedBox(height: 16),
        TextFormField(controller: via,
          decoration: const InputDecoration(labelText: 'Intermediate stops (comma separated)')),
        const SizedBox(height: 16),
        TextFormField(key: const ValueKey('trip-capacity'), controller: capacity,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: widget.service == Service.goods ? 'Available capacity (kg)' : 'Available seats'),
          validator: positive),
        const SizedBox(height: 16),
        TextFormField(key: const ValueKey('trip-fare'), controller: price,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Fare (INR)'), validator: positive),
        const SizedBox(height: 16),
        OutlinedButton.icon(onPressed: pickDeparture, icon: const Icon(Icons.calendar_month),
          label: Text('Departure: ${departure.toString().substring(0, 16)}')),
        if (error != null) Padding(padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        const SizedBox(height: 20),
        FilledButton(onPressed: save, child: const Text('Post demo trip')),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
      ]))),
  );
}
