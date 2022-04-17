// 🐦 Flutter imports:

// 🎯 Dart imports:
import 'dart:ui';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../../../meta/models/freezed/image.model.dart';
import '../../../../meta/notifiers/user_data.dart';
import '../../../constants/theme.dart';
import '../../../provider/listeners/user_data.listener.dart';

class ImagesPage extends StatefulWidget {
  const ImagesPage({Key? key}) : super(key: key);

  @override
  State<ImagesPage> createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {
  String? _img;
  @override
  void dispose() {
    _img = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        UserDataListener(
          builder: (BuildContext context, UserData userData) {
            return userData.images.isEmpty
                ? const Center(
                    child: Text('Not implemented yet'),
                  )
                : Wrap(
                    children: userData.images.map(
                      (Images image) {
                        return Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15.0),
                                child: Text(
                                  image.folderName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: AppTheme.grey[400],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20.0),
                                child: Wrap(
                                  children: <Widget>[
                                    for (int i in image.images.keys)
                                      GestureDetector(
                                        onTap: _img != null
                                            ? null
                                            : () {
                                                setState(() {
                                                  _img = image.images[i];
                                                });
                                              },
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Image.memory(
                                            Base2e15.decode(
                                              image.images[i]!,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ).toList(),
                  );
          },
        ),
        if (_img != null)
          Center(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.transparent,
                    ),
                    child: Image(
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      image: Image.memory(
                        Base2e15.decode(_img!),
                      ).image,
                    ),
                  ),
                  Positioned(
                    right: -10,
                    top: -10,
                    child: IconButton(
                      icon: const Icon(
                        TablerIcons.x,
                        color: Colors.red,
                      ),
                      onPressed: () => setState(
                        () => _img = null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
