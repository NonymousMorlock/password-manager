// 📦 Package imports:
import 'package:uuid/uuid.dart';

// 🌎 Project imports:
import '../../core/services/passman.env.dart';
import 'enum.dart';

class Constants {
  /// Doamin for the API
  static String get domain => PassmanEnv.rootDomain.split('.')[2] == 'wtf'
      ? 'my.atsign.wtf'
      : 'my.atsign.com';

  /// API version path
  static const String apiPath = '/api/app/v2/';

  /// End point for getting a new atsign
  static const String getFreeAtSign = 'get-free-atsign';

  /// End point for registering a new atsign to an user
  static const String registerUser = 'register-person';

  /// End point for validating a new atsign to an user
  static const String validateOTP = 'validate-person';

  /// Domain for fetching favicons of websites
  static const String faviconDomain = 'api.faviconkit.com';

  /// @sign regex pattern
  static const String atSignPattern =
      '[a-zA-Z0-9_]|\u00a9|\u00af|[\u2155-\u2900]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]';

  static Map<String, String> apiHeaders = <String, String>{
    'Authorization': PassmanEnv.appApiKey,
    'Content-Type': 'application/json',
  };

  static String get adminHost => 'passman-admins.herokuapp.com';

  static String get adminPath => 'admins';
  static Map<String, String> get adminHeader => <String, String>{
        'key': PassmanEnv.adminApiKey,
      };

  /// Get a new UUID
  static String get uuid => const Uuid().v4();

  /// Card types
  static const Map<CreditCardType, Set<List<String>>> cardNumPatterns =
      <CreditCardType, Set<List<String>>>{
    CreditCardType.visa: <List<String>>{
      <String>['4'],
    },
    CreditCardType.amex: <List<String>>{
      <String>['34'],
      <String>['37'],
    },
    CreditCardType.discover: <List<String>>{
      <String>['6011'],
      <String>['644', '649'],
      <String>['65'],
    },
    CreditCardType.mastercard: <List<String>>{
      <String>['51', '55'],
      <String>['2221', '2229'],
      <String>['223', '229'],
      <String>['23', '26'],
      <String>['270', '271'],
      <String>['2720'],
    },
    CreditCardType.dinersclub: <List<String>>{
      <String>['300', '305'],
      <String>['36'],
      <String>['38'],
      <String>['39'],
    },
    CreditCardType.jcb: <List<String>>{
      <String>['3528', '3589'],
      <String>['2131'],
      <String>['1800'],
    },
    CreditCardType.unionpay: <List<String>>{
      <String>['620'],
      <String>['624', '626'],
      <String>['62100', '62182'],
      <String>['62184', '62187'],
      <String>['62185', '62197'],
      <String>['62200', '62205'],
      <String>['622010', '622999'],
      <String>['622018'],
      <String>['622019', '622999'],
      <String>['62207', '62209'],
      <String>['622126', '622925'],
      <String>['623', '626'],
      <String>['6270'],
      <String>['6272'],
      <String>['6276'],
      <String>['627700', '627779'],
      <String>['627781', '627799'],
      <String>['6282', '6289'],
      <String>['6291'],
      <String>['6292'],
      <String>['810'],
      <String>['8110', '8131'],
      <String>['8132', '8151'],
      <String>['8152', '8163'],
      <String>['8164', '8171'],
    },
    CreditCardType.maestro: <List<String>>{
      <String>['493698'],
      <String>['500000', '506698'],
      <String>['506779', '508999'],
      <String>['56', '59'],
      <String>['63'],
      <String>['67'],
    },
    CreditCardType.elo: <List<String>>{
      <String>['401178'],
      <String>['401179'],
      <String>['438935'],
      <String>['457631'],
      <String>['457632'],
      <String>['431274'],
      <String>['451416'],
      <String>['457393'],
      <String>['504175'],
      <String>['506699', '506778'],
      <String>['509000', '509999'],
      <String>['627780'],
      <String>['636297'],
      <String>['636368'],
      <String>['650031', '650033'],
      <String>['650035', '650051'],
      <String>['650405', '650439'],
      <String>['650485', '650538'],
      <String>['650541', '650598'],
      <String>['650700', '650718'],
      <String>['650720', '650727'],
      <String>['650901', '650978'],
      <String>['651652', '651679'],
      <String>['655000', '655019'],
      <String>['655021', '655058'],
    },
    CreditCardType.mir: <List<String>>{
      <String>['2200', '2204'],
    },
    CreditCardType.hiper: <List<String>>{
      <String>['637095'],
      <String>['637568'],
      <String>['637599'],
      <String>['637609'],
      <String>['637612'],
      <String>['63743358'],
      <String>['63737423'],
    },
    CreditCardType.hipercard: <List<String>>{
      <String>['606282'],
    }
  };

  /// Finds non numeric characters
  static final RegExp nonNumeric = RegExp(r'\D+');

  /// Finds whitespace in any form
  static final RegExp whiteSpace = RegExp(r'\s+\b|\b\s');
}
