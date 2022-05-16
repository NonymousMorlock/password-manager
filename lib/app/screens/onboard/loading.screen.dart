import 'package:flutter/material.dart';

import '../../../core/services/app.service.dart';
import '../../../meta/components/adaptive_loading.dart';
import '../../constants/global.dart';
import '../../constants/page_route.dart';

class LoadingDataScreen extends StatefulWidget {
  const LoadingDataScreen({Key? key}) : super(key: key);

  @override
  State<LoadingDataScreen> createState() => _LoadingDataScreenState();
}

class _LoadingDataScreenState extends State<LoadingDataScreen> {
  String _message = 'Loading data...';
  Future<void> _loadData() async {
    _message = 'Starting monitor...';
    await AppServices.startMonitor();
    _message = 'Fetching passwords...';
    await AppServices.getPasswords();
    _message = 'Fetching images...';
    await AppServices.getImages();
    _message = 'Fetching cards...';
    await AppServices.getCards();
    _message = 'Fetching reports...';
    await AppServices.getReports();
    _message = 'Done...';
    Future<void>.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pushReplacementNamed(PageRouteNames.masterPassword);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
          future: _loadData(),
          builder: (_, __) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const AdaptiveLoading(),
                  vSpacer(30),
                  Text(_message),
                ],
              ),
            );
          }),
    );
  }
}
