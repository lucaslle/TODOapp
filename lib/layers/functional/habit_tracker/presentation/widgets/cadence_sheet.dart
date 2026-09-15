import 'package:flutter/material.dart';

import '../../../../technical/theme/cadence_colors.dart';
import '../../../../technical/theme/cadence_text_styles.dart';
import '../../../../technical/theme/widgets/sheet_handle.dart';

/// The bottom sheet shell shared by every sheet in the app: rounded top, grey
/// surface, handle, and enough bottom padding to clear the keyboard.
class CadenceSheet extends StatelessWidget {
  const CadenceSheet({required this.child, super.key});

  final Widget child;

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) => showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0x00000000),
    barrierColor: CadenceColors.scrim,
    builder: builder,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      decoration: BoxDecoration(
        color: CadenceColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: CadenceColors.textAt(0.1))),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            26 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[const SheetHandle(), child],
          ),
        ),
      ),
    );
  }
}

/// The Tâche / Routine switch at the top of the composer.
class SheetSegmentedTabs extends StatelessWidget {
  const SheetSegmentedTabs({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: CadenceColors.textAt(0.07),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: <Widget>[
          for (int index = 0; index < labels.length; index++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(index),
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: index == selectedIndex ? CadenceColors.white : null,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    labels[index],
                    style: CadenceTextStyles.button(
                      size: 12,
                      weight: FontWeight.w500,
                      color: index == selectedIndex
                          ? CadenceColors.onWhite
                          : CadenceColors.textAt(0.6),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Underlined text field used across the sheets.
class SheetTextField extends StatelessWidget {
  const SheetTextField({
    required this.controller,
    required this.hintText,
    this.fontSize = 18,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final double fontSize;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      textCapitalization: TextCapitalization.sentences,
      cursorColor: CadenceColors.white,
      style: CadenceTextStyles.body(
        size: fontSize,
        height: 1.2,
        letterSpacing: -0.012,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        hintStyle: CadenceTextStyles.body(
          size: fontSize,
          height: 1.2,
          color: CadenceColors.textAt(0.35),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: CadenceColors.textAt(0.2)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: CadenceColors.white),
        ),
      ),
    );
  }
}
