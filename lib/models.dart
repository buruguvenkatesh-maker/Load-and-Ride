enum Service { goods, carpool }

String locationKey(String value) => value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

class Trip {
  const Trip({required this.id, required this.service, required this.stops,
    required this.owner, required this.vehicle, required this.capacity,
    required this.price, required this.departure});
  final String id;
  final Service service;
  final List<String> stops;
  final String owner, vehicle;
  final int capacity, price;
  final DateTime departure;

  bool matches(String pickup, String drop, Service category) {
    final from = stops.indexWhere((s) => locationKey(s) == locationKey(pickup));
    final to = stops.indexWhere((s) => locationKey(s) == locationKey(drop));
    return service == category && capacity > 0 && from >= 0 && to > from;
  }
}

class Booking {
  Booking(this.trip, this.pickup, this.drop);
  final Trip trip;
  final String pickup, drop;
  String status = 'Requested';
}

class DemoStore {
  DemoStore() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    trips.addAll([
      Trip(id: 'sample-goods', service: Service.goods,
        stops: ['Hyderabad', 'Hayathnagar', 'Choutuppal', 'Thorrur'],
        owner: 'Arjun • Sample owner', vehicle: 'Tata Ace • TS 09 AB 1234',
        capacity: 750, price: 2200, departure: tomorrow),
      Trip(id: 'sample-car', service: Service.carpool,
        stops: ['Hyderabad', 'Hayathnagar', 'Thorrur'],
        owner: 'Priya • Sample owner', vehicle: 'Maruti Ertiga • TS 08 CD 5678',
        capacity: 3, price: 350, departure: tomorrow),
    ]);
  }
  final List<Trip> trips = [];
  final List<Booking> bookings = [];
  String name = 'Demo customer', phone = '', role = 'Customer';

  List<Trip> search(String pickup, String drop, Service service) =>
      trips.where((t) => t.matches(pickup, drop, service)).toList();

  bool request(Trip trip, String pickup, String drop) {
    if (bookings.any((b) => b.trip.id == trip.id)) return false;
    bookings.add(Booking(trip, pickup, drop));
    return true;
  }
}
