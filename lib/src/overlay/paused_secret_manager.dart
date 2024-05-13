import 'dart:ui';

import 'package:flutter/material.dart';

class PausedSecretManager {
  PausedSecretManager._();

  static OverlayEntry? _overlayEntry;

  static void add(BuildContext context) {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return const PausedSecretOverlayView();
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  static void remove() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class PausedSecretOverlayView extends StatefulWidget {
  const PausedSecretOverlayView({super.key});

  @override
  State<PausedSecretOverlayView> createState() =>
      _PausedSecretOverlayViewState();
}

class _PausedSecretOverlayViewState extends State<PausedSecretOverlayView>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  bool _lock = false;
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10),
    )..addListener(() => setState(() {}));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('$state paused_secret_manager.dart ~ 51');
    if (state == AppLifecycleState.resumed) {
      hideOverlay();
    } else if (state == AppLifecycleState.inactive) {
      showOverlay();
    }
    super.didChangeAppLifecycleState(state);
  }

  void showOverlay() {
    _lock = true;
    _anim.value = 1;
    setState(() {});
  }

  void hideOverlay() {
    _lock = false;
    _anim.animateBack(0).orCancel;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: _lock == false,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 20 * _anim.value,
          sigmaY: 20 * _anim.value,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.6 * _anim.value),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
