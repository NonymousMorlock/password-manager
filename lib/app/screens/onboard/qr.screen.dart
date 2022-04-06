// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tabler_icons/icon_data.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../../core/services/app.service.dart';
import '../../../meta/components/toast.dart';
import '../../../meta/extensions/logger.ext.dart';
import '../../../meta/models/qr.model.dart';
import '../../../meta/notifiers/new_user.dart';
import '../../../meta/notifiers/user_data.dart';
import '../../constants/assets.dart';
import '../../constants/global.dart';
import '../../constants/page_route.dart';
import '../../constants/theme.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({Key? key}) : super(key: key);

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  AppLogger qrLog = AppLogger('QR');
  bool flash = false;
  QRViewController? controller;
  void _onQRViewCreated(QRViewController? qrController) {
    setState(() {
      controller = qrController;
    });
    qrController?.scannedDataStream.listen((Barcode scanData) async {
      if (scanData.code != null) {
        qrController.dispose();
        qrLog.info('QR Code: ${scanData.code}');

        context.read<UserData>().atOnboardingPreference.cramSecret =
            scanData.code?.split(':')[1];
        context.read<NewUser>()
          ..newUserData['atSign'] = scanData.code?.split(':')[0]
          ..newUserData['img'] =
              await AppServices.readLocalfilesAsBytes(Assets.getRandomAvatar())
          ..setQrData = QrModel(
              atSign: scanData.code?.split(':')[0] ?? '',
              cramSecret: scanData.code?.split(':')[1] ?? '');
        await Navigator.pushNamed(context, PageRouteNames.activatingAtSign);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (isAndroid) {
      controller!.pauseCamera();
    } else if (isIos) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
            QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
            Positioned(
              bottom: 130,
              left: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(
                  TablerIcons.photo,
                  color: Colors.white,
                ),
                splashRadius: 0.01,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onPressed: () async {
                  try {
                    await controller!.pauseCamera();
                    List<PlatformFile> _file =
                        await AppServices.uploadFile(FileType.image);
                    if (_file.isNotEmpty) {
                      bool _gotData = await AppServices.getQRData(
                        context,
                        _file.first.path,
                      );
                      if (_gotData) {
                        await Navigator.pushReplacementNamed(
                            context, PageRouteNames.activatingAtSign);
                      }
                    } else {
                      await controller!.resumeCamera();
                      showToast(context, 'No image picked', isError: true);
                    }
                  } on Exception catch (e) {
                    await controller!.resumeCamera();
                    qrLog.severe(e);
                    showToast(context, 'Failed to pick image', isError: true);
                  }
                },
              ),
            ),
            Positioned(
              top: 40,
              right: 10,
              child: IconButton(
                onPressed: () async {
                  await controller?.toggleFlash();
                  setState(
                    () {
                      flash = !flash;
                    },
                  );
                },
                splashRadius: 0.01,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                icon: FutureBuilder<bool?>(
                  future: controller?.getFlashStatus(),
                  builder:
                      (BuildContext context, AsyncSnapshot<bool?> snapshot) =>
                          Icon(
                    flash ? const TablerIconData(0xea38) : TablerIcons.bolt_off,
                    color: flash
                        ? Colors.white
                        : AppTheme.primary.withOpacity(0.3),
                    size: 30,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  TablerIcons.x,
                  color: Colors.white,
                  size: 30,
                ),
                splashRadius: 0.01,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
