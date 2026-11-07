import 'package:flutter/material.dart';
import 'models.dart';

void main() => runApp(const RideloadApp());

class RideloadApp extends StatelessWidget {
  const RideloadApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Load and Ride', debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5),
        primary: const Color(0xFF4F46E5), secondary: const Color(0xFF008B82)),
      scaffoldBackgroundColor: const Color(0xFFF4F6FF),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.white,
        foregroundColor: Color(0xFF17204B), surfaceTintColor: Colors.transparent),
      navigationBarTheme: const NavigationBarThemeData(backgroundColor: Colors.white,
        indicatorColor: Color(0xFFE4E1FF)),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDDE1F3))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDDE1F3))))),
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
  Service service = Service.carpool;
  int tab = 0;
  List<Trip>? results;
  @override
  void dispose() { pickup.dispose(); drop.dispose(); super.dispose(); }

  void message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(titleSpacing: 20,
      title: const Row(children: [
        Icon(Icons.route_rounded, color: Color(0xFF4F46E5), size: 28),
        SizedBox(width: 8),
        Flexible(child: Text('Load and Ride', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800))),
      ]), actions: [
      TextButton(onPressed: register, child: const Text('Register')),
      const SizedBox(width: 8),
    ]),
    bottomNavigationBar: NavigationBar(selectedIndex: tab,
      onDestinationSelected: (value) => setState(() => tab = value), destinations: const [
        NavigationDestination(icon: Icon(Icons.search), label: 'Explore'),
        NavigationDestination(icon: Icon(Icons.add_road), label: 'Post trip'),
        NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Bookings'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile')]),
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [
      if (tab == 0) hero(),
      Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(color: const Color(0xFFE9EDFF),
          borderRadius: BorderRadius.circular(14)),
        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.science_outlined, size: 20, color: Color(0xFF4F46E5)),
          SizedBox(width: 10),
          Expanded(child: Text('SAMPLE DATA • Personal testing only\nNo live vehicles, real bookings, payments or OTP. Changes reset when the app restarts.',
            style: TextStyle(fontSize: 12, color: Color(0xFF37416D), height: 1.4))),
        ])),
      if (tab == 0) ...explore(),
      if (tab == 1) ...post(),
      if (tab == 2) ...bookings(),
      if (tab == 3) ...profile(),
    ])));

  Widget heading(String text) => Padding(padding: const EdgeInsets.only(bottom: 16),
    child: Text(text, style: Theme.of(context).textTheme.headlineSmall));
  Widget hero() => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF4338CA), Color(0xFF6756E8), Color(0xFF168CBB)]),
      borderRadius: BorderRadius.circular(26),
      boxShadow: const [BoxShadow(color: Color(0x224F46E5), blurRadius: 20, offset: Offset(0, 8))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.explore_outlined, color: Color(0xFFFFDC88), size: 18),
        SizedBox(width: 8), Expanded(child: Text('YOUR ROUTE. MORE POSSIBILITIES.',
          style: TextStyle(color: Color(0xFFE9E6FF), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)))]),
      const SizedBox(height: 18),
      Text(service == Service.carpool ? 'Share a ride.\nEnjoy the journey.' : 'Your goods.\nAlready on the way.',
        style: const TextStyle(color: Colors.white, fontSize: 30, height: 1.13, fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      const Text('Hyderabad ↔ Thorrur & across India',
        style: TextStyle(color: Color(0xFFE9EDFF), fontSize: 13)),
      const SizedBox(height: 16),
      Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFF3730A3), borderRadius: BorderRadius.circular(20)),
          child: const Text('One-way journeys', style: TextStyle(color: Colors.white, fontSize: 12))),
        const Spacer(),
        Icon(service == Service.carpool ? Icons.directions_car_rounded : Icons.local_shipping_rounded,
          color: const Color(0xFFFFD783), size: 44),
      ]),
    ]));

  Widget categories() => Padding(padding: const EdgeInsets.only(bottom: 20),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: category(Service.carpool, 'Carpool', 'Share the journey',
        Icons.directions_car_rounded, const Color(0xFF5145CD), const Color(0xFFEDEAFF))),
      const SizedBox(width: 12),
      Expanded(child: category(Service.goods, 'Goods Transport', 'Move your goods',
        Icons.local_shipping_rounded, const Color(0xFF00796E), const Color(0xFFE1F5EE))),
    ]));

  Widget category(Service value, String title, String subtitle, IconData icon, Color accent, Color tint) {
    final selected = service == value;
    return Semantics(selected: selected, button: true, child: Material(
      color: selected ? accent : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(key: ValueKey('category-${value.name}'),
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() { service = value; results = null; }),
        child: Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? accent : const Color(0xFFE1E5F3))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: selected ? const Color(0x33FFFFFF) : tint,
                  borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: selected ? Colors.white : accent, size: 26)),
              const Spacer(),
              if (selected) const Icon(Icons.check_circle, color: Colors.white, size: 20),
            ]),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: selected ? Colors.white : const Color(0xFF202748),
              fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: selected ? const Color(0xFFE8E5FF) : const Color(0xFF626C89), fontSize: 11)),
          ])),
      )));
  }

  List<Widget> routeFields() => [
    TextField(controller: pickup, decoration: const InputDecoration(
      labelText: 'Pickup location', hintText: 'Any Indian town or city',
      prefixIcon: Icon(Icons.trip_origin, color: Color(0xFF4F46E5)))),
    const SizedBox(height: 12),
    TextField(controller: drop, decoration: const InputDecoration(labelText: 'Drop location',
      prefixIcon: Icon(Icons.location_on_rounded, color: Color(0xFFDA6441)))),
    const SizedBox(height: 16),
  ];
  bool validRoute() {
    if (pickup.text.trim().isEmpty || drop.text.trim().isEmpty || locationKey(pickup.text) == locationKey(drop.text)) {
      message('Enter different pickup and drop locations.'); return false;
    }
    return true;
  }
  List<Widget> explore() => [categories(), heading('Where are you heading?'),
    ...routeFields(),
    FilledButton.icon(onPressed: () { if (validRoute()) setState(() => results = store.search(pickup.text, drop.text, service)); },
      icon: const Icon(Icons.search), label: const Text('Find matching trips')),
    const SizedBox(height: 24),
    heading(results == null ? 'Explore sample journeys' : 'Matching sample journeys'),
    if (results != null && results!.isEmpty) const Text('No sample trips match this route. Post a demo trip to try another location.'),
    for (final trip in results ?? store.trips.where((t) => t.service == service).toList()) tripCard(trip),
  ];
  Widget tripCard(Trip trip) => Card(
    color: Colors.white, surfaceTintColor: Colors.transparent, elevation: 0,
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22),
      side: const BorderSide(color: Color(0xFFE0E5F5))),
    child: Padding(padding: const EdgeInsets.all(20), child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: trip.service == Service.carpool ? const Color(0xFFEDEAFF) : const Color(0xFFE1F5EE),
            borderRadius: BorderRadius.circular(14)),
          child: Icon(trip.service == Service.carpool ? Icons.directions_car_rounded : Icons.local_shipping_rounded,
            color: trip.service == Service.carpool ? const Color(0xFF5145CD) : const Color(0xFF00796E))),
        const SizedBox(width: 10),
        Expanded(child: Text(trip.service == Service.carpool ? 'CARPOOL' : 'GOODS TRANSPORT',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF59617E), letterSpacing: 1))),
        Text('₹${trip.price}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF00796E))),
      ]),
      const SizedBox(height: 16),
      Text('${trip.stops.first} → ${trip.stops.last}', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text(trip.vehicle, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 4), Text(trip.owner),
      const Divider(height: 26),
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
