// 🐦 Flutter imports:

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_base2e15/at_base2e15.dart';

// 🌎 Project imports:
import '../../../../meta/components/banking_card.dart';
import '../../../../meta/notifiers/user_data.dart';
import '../../../provider/listeners/user_data.listener.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({Key? key}) : super(key: key);

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: UserDataListener(
        builder: (BuildContext context, UserData userData) {
          // return userData.cards.isEmpty
          //     ? const AdaptiveLoading()
          //     : const BankingCard();
          return userData.cards.isEmpty
              ? const Text('No cards saved yet')
              : ListView.builder(
                  itemCount: userData.cards.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onLongPress: () async {
                        // PassKey a = PassKey(key: userData.cards[index].id);
                        // await AppServices.getCards();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CreditCard(
                          cardName: userData.cards[index].nameOnCard,
                          cardNum: userData.cards[index].cardNumber,
                          imageData:
                              Base2e15.decode(userData.cards[index].cardType),
                          cvv: userData.cards[index].cvv,
                          expiry: userData.cards[index].expiryDate,
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
