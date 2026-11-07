import 'package:flutter/material.dart';
import 'models.dart';

void main() => runApp(const RideloadApp());

class RideloadApp extends StatelessWidget {
  const RideloadApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Load and Ride', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF006B5E),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder())),
    home: const Marketplace());
}

class Marketplace extends StatefulWidget {
  const Marketplace({super.key});
  @override
  State<Marketplace> createState() => _MarketplaceState();
}

class _MarketplaceState extends State<Marketplace> {
  final store = DemoStore();
  final pickup = TextEditingController(text: 'Hyderabad');
  final drop = TextEditingController(text: 'Thorrur');
  Service service = Service.goods;
  int tab = 0;
  List<Trip>? results;
  @override
  void dispose() { pickup.dispose(); drop.dispose(); super.dispose(); }

  void message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Load and Ride'), actions: [
      TextButton(onPressed: register, child: const Text('Register'))]),
    bottomNavigationBar: NavigationBar(selectedIndex: tab,
      onDestinationSelected: (value) => setState(() => tab = value), destinations: const [
        NavigationDestination(icon: Icon(Icons.search), label: 'Explore'),
        NavigationDestination(icon: Icon(Icons.add_road), label: 'Post trip'),
        NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Bookings'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile')]),
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [
      Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(12)),
        child: const Text('SAMPLE DATA • Personal testing only\nNo live vehicles, real bookings, payments or OTP. Changes reset when the app restarts.')),
      if (tab == 0) ...explore(),
      if (tab == 1) ...post(),
      if (tab == 2) ...bookings(),
      if (tab == 3) ...profile(),
    ])));

  Widget heading(String text) => Padding(padding: const EdgeInsets.only(bottom: 16),
    child: Text(text, style: Theme.of(context).textTheme.headlineSmall));
  Widget categories() => Padding(padding: const EdgeInsets.only(bottom: 20),
    child: SegmentedButton<Service>(segments: const [
      ButtonSegment(value: Service.goods, icon: Icon(Icons.local_shipping_outlined), label: Text('Goods Transport')),
      ButtonSegment(value: Service.carpool, icon: Icon(Icons.directions_car_outlined), label: Text('Carpool'))],
      selected: {service}, onSelectionChanged: (s) => setState(() { service = s.first; results = null; })));
  List<Widget> routeFields() => [
    TextField(controller: pickup, decoration: const InputDecoration(labelText: 'Pickup location', hintText: 'Any Indian town or city')),
    const SizedBox(height: 12),
    TextField(controller: drop, decoration: const InputDecoration(labelText: 'Drop location')),
    const SizedBox(height: 16),
  ];
  bool validRoute() {
    if (pickup.text.trim().isEmpty || drop.text.trim().isEmpty || locationKey(pickup.text) == locationKey(drop.text)) {
      message('Enter different pickup and drop locations.'); return false;
    }
    return true;
  }
  List<Widget> explore() => [heading('Move goods. Share journeys.'),
    const Text('Find a vehicle already heading your way.\nStarting with Hyderabad–Thorrur. All Indian locations welcome.'),
    const SizedBox(height: 20), categories(), ...routeFields(),
    FilledButton.icon(onPressed: () { if (validRoute()) setState(() => results = store.search(pickup.text, drop.text, service)); },
      icon: const Icon(Icons.search), label: const Text('Find matching trips')),
    const SizedBox(height: 20),
    if (results != null && results!.isEmpty) const Text('No sample trips match this route. Post a demo trip to try another location.'),
    for (final trip in results ?? store.trips.where((t) => t.service == service).toList()) tripCard(trip),
  ];
  Widget tripCard(Trip trip) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${trip.stops.first} → ${trip.stops.last}', style: Theme.of(context).textTheme.titleLarge),
      Text(trip.vehicle), Text(trip.owner),
      Text('Via ${trip.stops.join(' → ')}'),
      Text('Departure: ${trip.departure.toLocal().toString().substring(0, 16)}'),
      Text('${trip.capacity} ${trip.service == Service.goods ? 'kg available' : 'seats available'} • ₹${trip.price} ${trip.service == Service.goods ? 'per trip' : 'per seat'}'),
      const Text('Sample listing • Fare is illustrative'),
      TextButton(onPressed: () => showDialog<void>(context: context, builder: (ctx) => AlertDialog(
        title: const Text('Vehicle details'), content: Text('${trip.vehicle}\n${trip.owner}\nOne-way journey\nNo verification has been performed for this demo vehicle.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))])), child: const Text('Vehicle details')),
      FilledButton.tonal(onPressed: () {
        if (!validRoute()) return;
        if (!trip.matches(pickup.text, drop.text, service)) { message('Search a route served by this vehicle first.'); return; }
        setState(() { final added = store.request(trip, pickup.text.trim(), drop.text.trim());
          message(added ? 'Demo request saved. No driver has been contacted.' : 'You already requested this demo trip.'); });
      }, child: const Text('Request demo booking')),
    ])));

  List<Widget> post() => [heading('Post a one-way trip'),
    if (store.role != 'Vehicle Owner') ...[
      const Text('Register as a Vehicle Owner to post a demo trip.'),
      FilledButton(onPressed: register, child: const Text('Vehicle Owner registration')),
    ] else ...[categories(), ...routeFields(),
      const Text('Add stops in travel order to match customers along your route.'),
      const SizedBox(height: 16), FilledButton(onPressed: postDetails, child: const Text('Add vehicle and departure')),
    ]];

  Future<void> postDetails() async {
    if (!validRoute()) return;
    final vehicle = TextEditingController(), capacity = TextEditingController(), price = TextEditingController(), via = TextEditingController();
    final form = GlobalKey<FormState>();
    DateTime date = DateTime.now().add(const Duration(days: 1));
    await showDialog<void>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, update) => AlertDialog(
      title: const Text('Demo vehicle trip'), content: SingleChildScrollView(child: Form(key: form, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: vehicle, decoration: const InputDecoration(labelText: 'Vehicle model and registration'), validator: (s) => s == null || s.trim().isEmpty ? 'Enter vehicle details' : null),
        const SizedBox(height: 12), TextFormField(controller: via, decoration: const InputDecoration(labelText: 'Intermediate stops (comma separated)')),
        const SizedBox(height: 12), TextFormField(controller: capacity, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: service == Service.goods ? 'Available capacity (kg)' : 'Available seats'), validator: positive),
        const SizedBox(height: 12), TextFormField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fare (INR)'), validator: positive),
        TextButton(onPressed: () async {
          final chosen = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
          if (chosen == null || !ctx.mounted) return;
          final time = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(date));
          if (time != null) update(() => date = DateTime(chosen.year, chosen.month, chosen.day, time.hour, time.minute));
        }, child: Text('Departure: ${date.toString().substring(0, 16)}')),
      ]))), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () {
          if (!form.currentState!.validate()) return;
          if (!date.isAfter(DateTime.now())) { message('Choose a future departure.'); return; }
          final stops = [pickup.text.trim(), ...via.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty), drop.text.trim()];
          if (stops.map(locationKey).toSet().length != stops.length) { message('Each stop must be unique.'); return; }
          setState(() { store.trips.add(Trip(id: 'demo-${DateTime.now().microsecondsSinceEpoch}', service: service, stops: stops, owner: '${store.name} • Demo owner', vehicle: vehicle.text.trim(), capacity: int.parse(capacity.text.trim()), price: int.parse(price.text.trim()), departure: date)); results = null; tab = 0; });
          Navigator.pop(ctx); message('Demo trip posted locally.');
        }, child: const Text('Post demo trip'))])));
    vehicle.dispose(); capacity.dispose(); price.dispose(); via.dispose();
  }
  String? positive(String? text) => (int.tryParse(text?.trim() ?? '') ?? 0) > 0 ? null : 'Enter a positive whole number';

  List<Widget> bookings() => [heading('Bookings & trip requests'),
    const Text('Local simulations only. No real reservation or owner notification.'),
    if (store.bookings.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('No demo requests yet. Explore a route to get started.')),
    for (final b in store.bookings) Card(child: ListTile(isThreeLine: true,
      title: Text('${b.pickup} → ${b.drop}'), subtitle: Text('${b.trip.vehicle}\nDemo status: ${b.status}'),
      trailing: PopupMenuButton<String>(onSelected: (s) => setState(() => b.status = s),
        itemBuilder: (_) => [for (final s in ['Accepted', 'Declined', 'Cancelled']) PopupMenuItem(value: s, child: Text('Simulate $s'))]))),
  ];
  List<Widget> profile() => [heading('Your demo profile'),
    ListTile(leading: const Icon(Icons.account_circle, size: 40), title: Text(store.name), subtitle: Text('${store.role}\n${store.phone.isEmpty ? 'No phone entered' : store.phone}')),
    const Text('Phone is not verified. Registration is local and does not create a Firebase account.'),
    FilledButton(onPressed: register, child: const Text('Edit registration')),
  ];
  Future<void> register() async {
    final name = TextEditingController(text: store.name), phone = TextEditingController(text: store.phone);
    var role = store.role;
    final key = GlobalKey<FormState>();
    await showDialog<void>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, update) => AlertDialog(
      title: Text('$role registration'), content: SingleChildScrollView(child: Form(key: key, child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(initialValue: role, items: [for (final r in ['Customer', 'Vehicle Owner']) DropdownMenuItem(value: r, child: Text(r))], onChanged: (r) => update(() => role = r!)),
        const SizedBox(height: 12), TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Full name'), validator: (s) => s == null || s.trim().length < 2 ? 'Enter your name' : null),
        const SizedBox(height: 12), TextFormField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Indian mobile number', prefixText: '+91 '), validator: (s) => RegExp(r'^[6-9][0-9]{9}$').hasMatch(s?.trim() ?? '') ? null : 'Enter a valid 10-digit mobile number'),
        const Text('Demo only • No SMS will be sent.'),
      ]))), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () { if (!key.currentState!.validate()) return; setState(() { store.name = name.text.trim(); store.phone = phone.text.trim(); store.role = role; }); Navigator.pop(ctx); }, child: const Text('Save demo profile'))])));
    name.dispose(); phone.dispose();
  }
}
