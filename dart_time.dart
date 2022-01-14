main() {
  List<String> weekdays = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma'];

  DateTime simdi = DateTime.now();
  print(simdi);

  DateTime cumhuriyet = DateTime.utc(1923, 10, 29, 9, 30);
  print("cumhuriyet: $cumhuriyet");

  DateTime localTime = DateTime.parse('1923-10-29');
  print('localtime: $localTime');

  print(localTime.weekday);

  print(weekdays[localTime.weekday - 1]);

  DateTime simdiArtiDoksanGun = simdi.add(Duration(days: 90));
  print(simdiArtiDoksanGun);

  print(simdi.difference(cumhuriyet));
}
