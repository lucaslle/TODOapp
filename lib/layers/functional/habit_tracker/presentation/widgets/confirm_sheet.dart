import 'package:flutter/material.dart';

import '../../../../technical/theme/cadence_colors.dart';
import '../../../../technical/theme/cadence_text_styles.dart';
import '../../../../technical/theme/widgets/pill_button.dart';
import 'cadence_sheet.dart';

/// Asks before something that cannot be undone.
class ConfirmSheet extends StatelessWidget {
  const ConfirmSheet({
    required this.title,
    required this.body,
    required this.confirmLabel,
    super.key,
  });

  final String title;
  final String body;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    return CadenceSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            style: CadenceTextStyles.display(size: 24, letterSpacing: -0.035),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: CadenceTextStyles.body(
              size: 14,
              color: CadenceColors.textAt(0.55),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: <Widget>[
              PillButton(
                label: 'Annuler',
                variant: PillButtonVariant.outlined,
                fontSize: 14,
                onPressed: () => Navigator.of(context).pop(false),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PillButton(
                  label: confirmLabel,
                  isExpanded: true,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Single-field sheet, used to set the display name.
class TextPromptSheet extends StatefulWidget {
  const TextPromptSheet({
    required this.title,
    required this.hintText,
    required this.confirmLabel,
    this.initialValue = '',
    super.key,
  });

  final String title;
  final String hintText;
  final String confirmLabel;
  final String initialValue;

  @override
  State<TextPromptSheet> createState() => _TextPromptSheetState();
}

class _TextPromptSheetState extends State<TextPromptSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    return CadenceSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            widget.title,
            style: CadenceTextStyles.display(size: 24, letterSpacing: -0.035),
          ),
          const SizedBox(height: 16),
          SheetTextField(
            controller: _controller,
            hintText: widget.hintText,
            autofocus: true,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              PillButton(
                label: 'Annuler',
                variant: PillButtonVariant.outlined,
                fontSize: 14,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PillButton(
                  label: widget.confirmLabel,
                  isExpanded: true,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
