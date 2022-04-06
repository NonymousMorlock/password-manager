class Decode {
  static final Decode _singleton = Decode._internal();
  factory Decode() => _singleton;
  Decode._internal();

  Future<void> decodeImage() async {}
}
