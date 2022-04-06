class Decryption {
  static final Decryption _singleton = Decryption._internal();
  factory Decryption() => _singleton;
  Decryption._internal();

  Future<void> decryptValue() async {}
}
