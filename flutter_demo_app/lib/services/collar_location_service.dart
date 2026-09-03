import 'package:firebase_database/firebase_database.dart';

class CollarLocationService {
  static Stream<String> getStatusStream() {
    return FirebaseDatabase.instance
        .ref('/pets/buddy/status')
        .onValue
        .map((event) => event.snapshot.value?.toString() ?? 'unknown');
  }

  static Stream<double> getDistanceStream() {
    return FirebaseDatabase.instance.ref('/pets/buddy/distance').onValue.map(
        (event) =>
            double.tryParse(event.snapshot.value?.toString() ?? '0') ?? 0.0);
  }
}
