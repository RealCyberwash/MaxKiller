import 'dart:math';

class TestDataGenerator {
  static final _random = Random();

  static String randomPhone() {
    final suffix = List.generate(7, (_) => _random.nextInt(10)).join();
    return '+7988$suffix';
  }
}
