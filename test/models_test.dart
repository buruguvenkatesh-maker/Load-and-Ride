import 'package:flutter_test/flutter_test.dart';
import 'package:rideload/models.dart';

void main() {
  test('matches intermediate stops in forward travel order only', () {
    final store = DemoStore();
    expect(store.search('  HYDERABAD ', 'Thorrur', Service.goods), hasLength(1));
    expect(store.search('Hayathnagar', 'Thorrur', Service.goods), hasLength(1));
    expect(store.search('Thorrur', 'Hyderabad', Service.goods), isEmpty);
    expect(store.search('Hyderabad', 'Hyderabad', Service.goods), isEmpty);
    expect(store.search('Mumbai', 'Delhi', Service.goods), isEmpty);
  });
  test('keeps goods separate from carpool and rejects duplicate requests', () {
    final store = DemoStore();
    final trip = store.search('Hyderabad', 'Thorrur', Service.carpool).single;
    expect(trip.service, Service.carpool);
    expect(store.request(trip, 'Hyderabad', 'Thorrur'), isTrue);
    expect(store.request(trip, 'Hyderabad', 'Thorrur'), isFalse);
    expect(store.bookings.single.status, 'Requested');
    expect(DemoStore().bookings, isEmpty);
  });
  test('new trips support any Indian location', () {
    final trip = Trip(id: 'new', service: Service.goods, stops: ['Pune', 'Mumbai'],
      owner: 'Demo', vehicle: 'Truck', capacity: 100, price: 500,
      departure: DateTime.now().add(const Duration(days: 1)));
    expect(trip.matches('Pune', 'Mumbai', Service.goods), isTrue);
  });
}
