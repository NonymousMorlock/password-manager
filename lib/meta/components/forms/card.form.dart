// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../../app/constants/assets.dart';
import '../../../app/constants/constants.dart';
import '../../../app/constants/enum.dart';
import '../../../app/constants/global.dart';
import '../../../app/constants/keys.dart';
import '../../../app/constants/theme.dart';
import '../../../core/services/app.service.dart';
import '../../extensions/card_num_formatter.ext.dart';
import '../../extensions/string.ext.dart';
import '../../models/freezed/card.model.dart';
import '../../models/key.model.dart';
import '../../notifiers/user_data.dart';
import '../flip_widget.dart';
import '../glassmorphic.dart';
import '../toast.dart';

class CardsForm extends StatefulWidget {
  const CardsForm({Key? key}) : super(key: key);

  @override
  State<CardsForm> createState() => _CardsFormState();
}

class _CardsFormState extends State<CardsForm> {
  late TextEditingController _cardNumController,
      _cardNameController,
      _cardCvvController,
      _cardExpMController,
      _cardExpYController;
  final FocusNode _cvvFocusNode = FocusNode();
  CreditCardType? _cardType;
  @override
  void initState() {
    _cardNumController = TextEditingController();
    _cardNameController = TextEditingController();
    _cardCvvController = TextEditingController(text: 'CVV');
    _cardExpMController = TextEditingController();
    _cardExpYController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedContainer(
              height: 400,
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    bottom: 50,
                    left: -50,
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: -100,
                    child: Container(
                      height: 300,
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(150),
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  Center(
                    child: Flip(
                      isFront: true,
                      front: frontCard(),
                      back: backCard(),
                    ),
                  ),
                ],
              ),
            ),
            MaterialButton(
              onPressed: (_cardCvvController.text.isEmpty ||
                      _cardCvvController.text.length != 3 ||
                      _cardExpMController.text.isEmpty ||
                      int.parse(_cardExpMController.text) >= 13 ||
                      _cardExpYController.text.isEmpty ||
                      _cardExpYController.text.length != 4 ||
                      _cardNumController.text.length < 16)
                  ? () async {
                      showToast(context, 'Some fields are empty or invalid',
                          isError: true);
                      setState(() {});
                    }
                  : () async {
                      String _id = Constants.uuid;
                      CardModel _card = CardModel(
                        id: _id,
                        nameOnCard: _cardNameController.text,
                        cardNumber: _cardNumController.text,
                        expiryDate: _cardExpMController.text +
                            ' / ' +
                            _cardExpYController.text,
                        cvv: _cardCvvController.text,
                        cardType: Base2e15.encode(
                          await AppServices.readLocalfilesAsBytes(
                            Assets.cardLogo(_cardType!.name),
                          ),
                        ),
                      );
                      PassKey _key = Keys.cardsKey
                        ..key = 'cards_' + _id
                        ..value?.value = _card.toJson();
                      bool _isPut = await AppServices.sdkServices.put(_key);
                      showToast(
                          context,
                          _isPut
                              ? 'Card saved successfully'
                              : 'Failed save card',
                          isError: !_isPut);
                      if (_isPut) {
                        context.read<UserData>().cards.add(_card);
                        _cardCvvController.clear();
                        _cardExpMController.clear();
                        _cardExpYController.clear();
                        _cardNameController.clear();
                        _cardNumController.clear();
                        _cardType = null;
                        Navigator.pop(context);
                      }
                    },
              child: const Text('Save'),
            ),
            vSpacer(30),
          ],
        ),
      ),
    );
  }

  Glassmorphic frontCard() {
    return Glassmorphic(
      blur: 10,
      opacity: 0.5,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        margin: const EdgeInsets.all(20),
        shadowColor: Colors.transparent,
        color: Colors.transparent,
        child: SizedBox(
          height: 200,
          width: 310,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child:
                        _cardType == null || _cardType == CreditCardType.unknown
                            ? const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 3),
                                child: Icon(TablerIcons.credit_card),
                              )
                            : Image.asset(
                                Assets.cardLogo(_cardType!.name),
                                height: 30,
                              ),
                  ),
                  const Text('Banking Card'),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Transform.rotate(
                      angle: 0.9,
                      child: const Icon(TablerIcons.wifi),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Text('Card Number'),
              TextField(
                controller: _cardNumController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'XXXX XXXX XXXX XXXX',
                  hintStyle: TextStyle(
                    color: AppTheme.disabled,
                  ),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
                onChanged: (_) {
                  _cardType = AppServices.detectCCType(_cardNumController.text);
                  setState(() {});
                },
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(19),
                  FilteringTextInputFormatter.digitsOnly,
                  CardNumberInputFormatter(),
                ],
              ),
              const Spacer(),
              const Text('Name on card'),
              TextField(
                controller: _cardNameController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'John Doe',
                  hintStyle: TextStyle(
                    color: AppTheme.disabled,
                  ),
                ),
                onChanged: (_) => setState(() {}),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z ]'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Glassmorphic backCard() {
    return Glassmorphic(
      blur: 10,
      opacity: 0.5,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
        elevation: 0,
        shadowColor: Colors.transparent,
        color: Colors.transparent,
        child: SizedBox(
          height: 200,
          width: 310,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Container(
                  height: 40,
                  color: Colors.indigo,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 30,
                    width: 90,
                    color: Colors.white,
                  ),
                  Container(
                    height: 30,
                    width: 50,
                    color: Colors.white,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Center(
                        child: EditableText(
                          keyboardType: TextInputType.number,
                          controller: _cardCvvController,
                          onChanged: (_) {
                            setState(() {});
                          },
                          textAlign: TextAlign.center,
                          obscureText: true,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          inputFormatters: <TextInputFormatter>[
                            LengthLimitingTextInputFormatter(3),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          backgroundCursorColor: Colors.transparent,
                          cursorColor: AppTheme.primary,
                          focusNode: _cvvFocusNode,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Expiry Date'),
                    ),
                  ),
                  // month and year text field
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return 'Please enter expiry month';
                              } else if (int.parse(value) > 12) {
                                return 'Please enter a valid month';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            controller: _cardExpMController,
                            onTap: () => setState(_cvvFocusNode.unfocus),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'MM',
                              hintStyle: TextStyle(
                                color: AppTheme.disabled,
                              ),
                            ),
                            onChanged: (_) {
                              if (int.parse(_) > 12) {
                                setState(
                                    () => _cardExpMController.text.clear());
                              }
                            },
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                            inputFormatters: <TextInputFormatter>[
                              LengthLimitingTextInputFormatter(2),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _cardExpYController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'YYYY',
                              hintStyle: TextStyle(
                                color: AppTheme.disabled,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                            inputFormatters: <TextInputFormatter>[
                              LengthLimitingTextInputFormatter(4),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
