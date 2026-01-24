import 'package:easy_localization/easy_localization.dart';
import 'package:materium/flutter.dart';
import 'package:materium/components/generated_form.dart';
import 'package:materium/providers/settings_new.dart';
import 'package:provider/provider.dart';

class GeneratedFormModal extends StatefulWidget {
  const GeneratedFormModal({
    super.key,
    required this.title,
    required this.items,
    this.initValid = false,
    this.message = '',
    this.additionalWidgets = const [],
    this.singleNullReturnButton,
    this.primaryActionColour,
  });

  final String title;
  final String message;
  final List<List<GeneratedFormItem>> items;
  final bool initValid;
  final List<Widget> additionalWidgets;
  final String? singleNullReturnButton;
  final Color? primaryActionColour;

  @override
  State<GeneratedFormModal> createState() => _GeneratedFormModalState();
}

class _GeneratedFormModalState extends State<GeneratedFormModal> {
  Map<String, dynamic> values = {};
  bool valid = false;

  @override
  void initState() {
    super.initState();
    valid = widget.initValid || widget.items.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final useBlackTheme = context.select<SettingsService, bool>(
      (settings) => settings.useBlackTheme.value,
    );
    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    return AlertDialog(
      backgroundColor: useBlackTheme
          ? colorTheme.surfaceContainerLow
          : colorTheme.surfaceContainerHigh,
      scrollable: true,
      title: Text(
        widget.title,
        style: typescaleTheme.headlineSmallEmphasized.toTextStyle(
          color: colorTheme.onSurface,
        ),
      ),
      content: Flex.vertical(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.message.isNotEmpty) Text(widget.message),
          if (widget.message.isNotEmpty) const SizedBox(height: 16),
          GeneratedForm(
            items: widget.items,
            onValueChanges: (values, valid, isBuilding) {
              if (isBuilding) {
                this.values = values;
                this.valid = valid;
              } else {
                setState(() {
                  this.values = values;
                  this.valid = valid;
                });
              }
            },
            textFieldType: .outlined,
          ),
          if (widget.additionalWidgets.isNotEmpty) ...widget.additionalWidgets,
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 24.0 - 4.0,
      ),
      actions: [
        TextButton(
          style: LegacyThemeFactory.createButtonStyle(
            colorTheme: colorTheme,
            elevationTheme: elevationTheme,
            shapeTheme: shapeTheme,
            stateTheme: stateTheme,
            typescaleTheme: typescaleTheme,
            size: .small,
            shape: .round,
            color: .text,
          ),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: Text(
            widget.singleNullReturnButton == null
                ? tr('cancel')
                : widget.singleNullReturnButton!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.singleNullReturnButton == null)
          TextButton(
            // TODO: find usages of primaryActionColour
            // style: widget.primaryActionColour == null
            //     ? null
            //     : TextButton.styleFrom(
            //         foregroundColor: widget.primaryActionColour,
            //       ),
            style: LegacyThemeFactory.createButtonStyle(
              colorTheme: colorTheme,
              elevationTheme: elevationTheme,
              shapeTheme: shapeTheme,
              stateTheme: stateTheme,
              typescaleTheme: typescaleTheme,
              size: .small,
              shape: .round,
              color: .text,
            ),
            onPressed: !valid
                ? null
                : () {
                    if (valid) {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop(values);
                    }
                  },
            child: Text(
              tr('continue'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
