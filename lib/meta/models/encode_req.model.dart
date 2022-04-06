// 📦 Package imports:
import 'package:image/image.dart';

class EncodeRequest {
  EncodeRequest(this.original, this.msg, {this.token});
  Image original;
  String msg;
  String? token;

  bool get shouldEncrypt => (token != null && token != '');
}
