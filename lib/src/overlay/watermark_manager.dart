import 'dart:math';

import 'package:flutter/material.dart';

class WatarmarkManager {
  WatarmarkManager._();

  static OverlayEntry? _overlayEntry;

  static void add(
    BuildContext context,
    String watermark, {
    int rowCount = 2,
    int columnCount = 8,
    TextStyle textStyle = const TextStyle(
      color: Color(0x08000000),
      fontSize: 14,
      decoration: TextDecoration.none,
    ),
  }) {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return WatarmarkView(
          text: watermark,
          rowCount: rowCount,
          columnCount: columnCount,
          textStyle: textStyle,
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  static void remove() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class WatarmarkView extends StatelessWidget {
  final String text;
  final int rowCount;
  final int columnCount;
  final TextStyle textStyle;

  const WatarmarkView({
    super.key,
    required this.text,
    required this.textStyle,
    required this.rowCount,
    required this.columnCount,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        children: [
          ...Iterable.generate(columnCount).map(
            (_) => Expanded(
              child: Row(
                children: [
                  ...Iterable.generate(rowCount).map(
                    (_) => Expanded(
                      child: _buildItem(context),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(2),
      child: Transform.rotate(
        angle: pi / 10,
        child: Text(text, style: textStyle),
      ),
    );
  }
}
