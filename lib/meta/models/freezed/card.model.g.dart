// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CardModel _$$_CardModelFromJson(Map<String, dynamic> json) => _$_CardModel(
      nameOnCard: json['nameOnCard'] as String,
      cardNumber: json['cardNumber'] as String,
      expiryDate: json['expiryDate'] as String,
      cvv: json['cvv'] as String,
      cardType: json['cardType'] as String,
      id: json['id'] as String?,
    );

Map<String, dynamic> _$$_CardModelToJson(_$_CardModel instance) =>
    <String, dynamic>{
      'nameOnCard': instance.nameOnCard,
      'cardNumber': instance.cardNumber,
      'expiryDate': instance.expiryDate,
      'cvv': instance.cvv,
      'cardType': instance.cardType,
      'id': instance.id,
    };
