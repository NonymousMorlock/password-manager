class Value {
  String? labelName;
  dynamic value;
  String? type;
  String? createdDate;
  bool? isHidden = false;

  Value(
      {this.value,
      this.type,
      this.createdDate,
      this.labelName,
      this.isHidden}) {
    createdDate = createdDate ?? DateTime.now().toString();
    isHidden = isHidden ?? false;
  }

  factory Value.fromJson(Map<String, dynamic> parsedJson) {
    return Value(
      labelName: parsedJson['labelName'],
      value: parsedJson['value'],
      type: parsedJson['type'],
      createdDate: parsedJson['createdDate'],
      isHidden: parsedJson['isHidden'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'labelName': labelName,
      'value': value,
      'type': type,
      'createdDate': createdDate,
      'isHidden': isHidden,
    };
  }

  @override
  String toString() {
    return 'Value{labelName: $labelName, value: $value, type: $type, createdDate: $createdDate, isHidden: $isHidden}';
  }
}
