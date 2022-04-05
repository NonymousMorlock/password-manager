// 📦 Package imports:
import 'package:at_commons/at_commons.dart';

// 🌎 Project imports:
import 'value.model.dart';

class PassKey {
  String? key;
  Value? value = Value();
  String? sharedWith;
  String? sharedBy;
  String? namespace;
  bool? isPublic = false;
  bool? isCached = false;
  bool? isHidden = false;
  bool? isBinary = false;
  bool? isRef = false;
  bool? ccd = false;
  bool? isEncrypted = false;
  bool? namespaceAware = false;
  DateTime? createdDate;
  int? ttb;
  int? ttl;
  int? ttr;

  PassKey(
      {this.sharedBy,
      this.sharedWith,
      this.isBinary,
      this.isCached,
      this.isHidden,
      this.isPublic,
      this.isRef,
      this.isEncrypted,
      this.namespaceAware,
      this.createdDate,
      this.ccd,
      this.ttb,
      this.ttl,
      this.ttr,
      this.key,
      this.namespace,
      this.value}) {
    isBinary ??= false;
    isCached ??= false;
    isHidden ??= false;
    isPublic ??= false;
    isRef ??= false;
    isEncrypted ??= false;
    namespaceAware = namespaceAware ?? false;
    ccd ??= false;

    value ??= Value();
  }

  factory PassKey.fromJson(Map<String, dynamic> parsedJson) {
    return PassKey(
      value: Value.fromJson(parsedJson['value']),
      key: parsedJson['key'],
      ttb: parsedJson['ttb'],
      ttl: parsedJson['ttl'],
      ttr: parsedJson['ttr'],
      sharedBy: parsedJson['sharedBy'],
      sharedWith: parsedJson['sharedWith'],
      isPublic: parsedJson['isPublic'],
      isCached: parsedJson['isCached'],
      isHidden: parsedJson['isHidden'],
      isBinary: parsedJson['isBinary'],
      isEncrypted: parsedJson['isEncrypted'],
      namespaceAware: parsedJson['namespaceAware'],
      namespace: parsedJson['namespace'],
      createdDate: parsedJson['createdDate'],
      ccd: parsedJson['ccd'],
      isRef: parsedJson['isRef'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': key,
      'value': value?.toJson(),
      'isPublic': isPublic,
      'isCached': isCached,
      'isHidden': isHidden,
      'isBinary': isBinary,
      'isEncrypted': isEncrypted,
      'ccd': ccd,
      'isRef': isRef,
      'sharedWith': sharedWith,
      'sharedBy': sharedBy,
      'ttb': ttb,
      'ttl': ttl,
      'ttr': ttr,
      'createdDate': createdDate,
      'namespace': namespace,
      'namespaceAware': namespaceAware
    };
  }

  factory PassKey.fromAtKey(AtKey atKey) {
    return PassKey(
      key: atKey.key,
      sharedBy: atKey.sharedBy,
      sharedWith: atKey.sharedWith,
      ttb: atKey.metadata?.ttb,
      ttl: atKey.metadata?.ttl,
      ttr: atKey.metadata?.ttr,
      isBinary: atKey.metadata?.isBinary,
      isCached: atKey.metadata?.isCached,
      isHidden: atKey.metadata?.isHidden,
      isPublic: atKey.metadata?.isPublic,
      isEncrypted: atKey.metadata?.isEncrypted,
      namespaceAware: atKey.metadata?.namespaceAware,
      namespace: atKey.namespace,
      createdDate: atKey.metadata?.createdAt,
      ccd: atKey.metadata?.ccd,
      isRef: atKey.isRef,
    );
  }

  AtKey toAtKey() {
    return AtKey()
      ..key = key
      ..isRef = isRef ?? false
      ..sharedBy = sharedBy
      ..sharedWith = sharedWith
      ..namespace = namespace
      ..metadata = (Metadata()
        ..ccd = ccd ?? false
        ..isPublic = isPublic ?? false
        ..isHidden = isHidden ?? false
        ..isCached = isCached ?? false
        ..isEncrypted = isEncrypted ?? false
        ..isBinary = isBinary ?? false
        ..namespaceAware = namespaceAware ?? false
        ..ttl = ttl
        ..ttb = ttb
        ..ttr = ttr);
  }

  @override
  String toString() {
    return 'PassKey{key: $key ,value: ${value.toString()},isPublic: $isPublic, isCached: $isCached, isHidden: $isHidden,isBinary: $isBinary, namespaceAware : $namespaceAware , isEncrypted : $isEncrypted, ttl: $ttl, ttb: $ttb, ttr: $ttr ,sharedWith : $sharedWith, sharedBy : $sharedBy, isref : $isRef}';
  }
}
