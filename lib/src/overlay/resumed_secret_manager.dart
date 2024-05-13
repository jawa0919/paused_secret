import 'dart:ui';

import 'package:flutter/material.dart';

class ResumedSecretManager {
  ResumedSecretManager._();

  static OverlayEntry? _overlayEntry;

  static void add(
    BuildContext context, {
    Widget Function(BuildContext context, void Function() hide)? builder,
  }) {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return ResumedSecretOverlayView(builder: builder);
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  static void remove() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class ResumedSecretOverlayView extends StatefulWidget {
  final Widget Function(BuildContext context, void Function() hide)? builder;

  const ResumedSecretOverlayView({
    super.key,
    required this.builder,
  });

  @override
  State<ResumedSecretOverlayView> createState() =>
      _ResumedSecretOverlayViewState();
}

class _ResumedSecretOverlayViewState extends State<ResumedSecretOverlayView>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  bool _lock = false;
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _anim = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration * 2,
    )..addListener(() => setState(() {}));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
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
    return Stack(
      children: [
        IgnorePointer(
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
        ),
        if (_lock)
          widget.builder != null
              ? widget.builder!(context, hideOverlay)
              : Center(
                  child: ElevatedButton(
                    onPressed: () => hideOverlay(),
                    child: const Text("Hide Secret Overlay"),
                  ),
                )
      ],
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
