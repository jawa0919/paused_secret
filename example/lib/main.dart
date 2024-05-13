import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:is_debug/is_debug.dart';

import 'package:paused_secret/paused_secret.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _pausedSecretPlugin = PausedSecret();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
        actions: [
          IconButton(
            onPressed: () {
              openAppSettings();
            },
            icon: const Icon(Icons.developer_board_rounded),
          )
        ],
      ),
      body: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ...ListTile.divideTiles(context: context, tiles: _b(context))
        ],
      ),
    );
  }

  bool disableScreenshot = false;
  bool pausedSecret = false;
  bool pausedSecretGlobal = false;
  StreamSubscription<dynamic>? screenshotListener;
  List<bool> overlay = [false, false, false];

  List<Widget> _b(BuildContext context) {
    return [
      const SizedBox(height: 1),
      ListTile(
        title: Text("Running Dart${Platform.version.split(" ").first}"),
        trailing: FutureBuilder<List<String?>>(
          future: Future.wait<String?>([
            IsDebug().getHostPlatformName(),
            IsDebug().getHostPlatformVersion(),
          ]),
          builder: (c, s) => Text('${s.data?.join("_")}'),
        ),
      ),
      CheckboxListTile(
        title: const Text("disableScreenshot"),
        subtitle: const Text(
          "only support android",
        ),
        value: disableScreenshot,
        onChanged: (b) {
          if (!Platform.isAndroid) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("only support android")),
            );
            return;
          }
          disableScreenshot = b == true;
          setState(() {});
          _pausedSecretPlugin.disableScreenshot(disableScreenshot);
        },
      ),
      CheckboxListTile(
        title: const Text("pausedSecret"),
        subtitle: const Text("support android13+ and ios"),
        value: pausedSecret,
        onChanged: (b) {
          pausedSecret = b == true;
          setState(() {});
          _pausedSecretPlugin.pausedSecret(pausedSecret);
        },
      ),
      CheckboxListTile(
        title: const Text("pausedSecretGlobal"),
        subtitle: const Text(
          "support android and ios\n"
          "Warning: android cannot screenshot",
        ),
        value: pausedSecretGlobal,
        onChanged: (b) {
          pausedSecretGlobal = b == true;
          setState(() {});
          if (Platform.isAndroid) {
            _pausedSecretPlugin.disableScreenshot(pausedSecretGlobal);
          } else {
            _pausedSecretPlugin.pausedSecret(pausedSecretGlobal);
          }
        },
      ),
      CheckboxListTile(
        title: const Text("screenshotListener"),
        subtitle: const Text(
          "support android and ios\n"
          "below android14 requires permission",
        ),
        value: screenshotListener != null,
        onChanged: (b) {
          if (b == true) {
            if (Platform.isAndroid) {}
            screenshotListener = _pausedSecretPlugin.onScreenshot().listen(
              (event) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Screenshot running")),
                );
              },
            );
          } else {
            screenshotListener?.cancel();
            screenshotListener = null;
          }
          setState(() {});
        },
      ),
      ..._bOverlay(context),
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      const SizedBox(),
    ];
  }

  List<Widget> _bOverlay(BuildContext context) {
    return [
      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        child: const Text("SecretOverlayView"),
      ),
      CheckboxListTile(
        title: const Text("pausedSecretOverlay"),
        subtitle: const Text(
          "support android and ios\n"
          "some android device no support\n"
          "they onPaused cannot draw screen view",
        ),
        value: overlay[0],
        onChanged: (b) {
          overlay[0] = b == true;
          if (overlay[0]) {
            PausedSecret.addPausedSecretOverlay(context);
          } else {
            PausedSecret.removePausedSecretOverlay();
          }
          setState(() {});
        },
      ),
      CheckboxListTile(
        title: const Text("resumedSecretOverlay"),
        value: overlay[1],
        onChanged: (b) {
          overlay[1] = b == true;
          setState(() {});
          if (overlay[1]) {
            PausedSecret.addResumedSecretOverlay(context);
          } else {
            PausedSecret.removeResumedSecretOverlay();
          }
        },
      ),
      CheckboxListTile(
        title: const Text("watermarkOverlay"),
        value: overlay[2],
        onChanged: (b) {
          overlay[2] = b == true;
          setState(() {});
          if (overlay[2]) {
            PausedSecret.addWatermarkOverlay(context, "jawa0919@163.com");
          } else {
            PausedSecret.removeWatermarkOverlay();
          }
        },
      ),
    ];
  }
}
