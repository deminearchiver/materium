import 'dart:math';

import 'package:hsluv/hsluv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:materium/flutter.dart';
import 'package:materium/components/generated_form_modal.dart';
import 'package:materium/providers/source_provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:collection/collection.dart';

abstract class GeneratedFormItem {
  late String key;
  late String label;
  late List<Widget> belowWidgets;
  late dynamic defaultValue;
  List<dynamic> additionalValidators;
  dynamic ensureType(dynamic val);
  GeneratedFormItem clone();

  GeneratedFormItem(
    this.key, {
    this.label = 'Input',
    this.belowWidgets = const [],
    this.defaultValue,
    this.additionalValidators = const [],
  });
}

class GeneratedFormTextField extends GeneratedFormItem {
  late bool required;
  late int max;
  late String? hint;
  late bool password;
  late TextInputType? textInputType;
  late List<String>? autoCompleteOptions;

  GeneratedFormTextField(
    super.key, {
    super.label,
    super.belowWidgets,
    String super.defaultValue = '',
    List<String? Function(String? value)> super.additionalValidators = const [],
    this.required = true,
    this.max = 1,
    this.hint,
    this.password = false,
    this.textInputType,
    this.autoCompleteOptions,
  });

  @override
  String ensureType(val) {
    return val.toString();
  }

  @override
  GeneratedFormTextField clone() {
    return GeneratedFormTextField(
      key,
      label: label,
      belowWidgets: belowWidgets,
      defaultValue: defaultValue,
      additionalValidators: List.from(additionalValidators),
      required: required,
      max: max,
      hint: hint,
      password: password,
      textInputType: textInputType,
    );
  }
}

class GeneratedFormDropdown extends GeneratedFormItem {
  late List<MapEntry<String, String>>? opts;
  List<String>? disabledOptKeys;

  GeneratedFormDropdown(
    super.key,
    this.opts, {
    super.label,
    super.belowWidgets,
    String super.defaultValue = '',
    this.disabledOptKeys,
    List<String? Function(String? value)> super.additionalValidators = const [],
  });

  @override
  String ensureType(val) {
    return val.toString();
  }

  @override
  GeneratedFormDropdown clone() {
    return GeneratedFormDropdown(
      key,
      opts?.map((e) => MapEntry(e.key, e.value)).toList(),
      label: label,
      belowWidgets: belowWidgets,
      defaultValue: defaultValue,
      disabledOptKeys: disabledOptKeys != null
          ? List.from(disabledOptKeys!)
          : null,
      additionalValidators: List.from(additionalValidators),
    );
  }
}

class GeneratedFormSwitch extends GeneratedFormItem {
  bool disabled = false;

  GeneratedFormSwitch(
    super.key, {
    super.label,
    super.belowWidgets,
    bool super.defaultValue = false,
    bool disabled = false,
    List<String? Function(bool value)> super.additionalValidators = const [],
  });

  @override
  bool ensureType(val) {
    return val == true || val == 'true';
  }

  @override
  GeneratedFormSwitch clone() {
    return GeneratedFormSwitch(
      key,
      label: label,
      belowWidgets: belowWidgets,
      defaultValue: defaultValue,
      disabled: false,
      additionalValidators: List.from(additionalValidators),
    );
  }
}

class GeneratedFormTagInput extends GeneratedFormItem {
  late MapEntry<String, String>? deleteConfirmationMessage;
  late bool singleSelect;
  late WrapAlignment alignment;
  late String emptyMessage;
  late bool showLabelWhenNotEmpty;
  GeneratedFormTagInput(
    super.key, {
    super.label,
    super.belowWidgets,
    Map<String, MapEntry<int, bool>> super.defaultValue = const {},
    List<String? Function(Map<String, MapEntry<int, bool>> value)>
        super.additionalValidators =
        const [],
    this.deleteConfirmationMessage,
    this.singleSelect = false,
    this.alignment = WrapAlignment.start,
    this.emptyMessage = 'Input',
    this.showLabelWhenNotEmpty = true,
  });

  @override
  Map<String, MapEntry<int, bool>> ensureType(val) {
    return val is Map<String, MapEntry<int, bool>> ? val : {};
  }

  @override
  GeneratedFormTagInput clone() {
    return GeneratedFormTagInput(
      key,
      label: label,
      belowWidgets: belowWidgets,
      defaultValue: defaultValue,
      additionalValidators: List.from(additionalValidators),
      deleteConfirmationMessage: deleteConfirmationMessage,
      singleSelect: singleSelect,
      alignment: alignment,
      emptyMessage: emptyMessage,
      showLabelWhenNotEmpty: showLabelWhenNotEmpty,
    );
  }
}

typedef OnValueChanges =
    void Function(Map<String, dynamic> values, bool valid, bool isBuilding);

class GeneratedForm extends StatefulWidget {
  const GeneratedForm({
    super.key,
    required this.items,
    required this.onValueChanges,
  });

  final List<List<GeneratedFormItem>> items;
  final OnValueChanges onValueChanges;

  @override
  State<GeneratedForm> createState() => _GeneratedFormState();
}

List<List<GeneratedFormItem>> cloneFormItems(
  List<List<GeneratedFormItem>> items,
) {
  List<List<GeneratedFormItem>> clonedItems = [];
  for (var row in items) {
    List<GeneratedFormItem> clonedRow = [];
    for (var it in row) {
      clonedRow.add(it.clone());
    }
    clonedItems.add(clonedRow);
  }
  return clonedItems;
}

class GeneratedFormSubForm extends GeneratedFormItem {
  final List<List<GeneratedFormItem>> items;

  GeneratedFormSubForm(
    super.key,
    this.items, {
    super.label,
    super.belowWidgets,
    super.defaultValue = const [],
  });

  @override
  dynamic ensureType(val) {
    return val; // Not easy to validate List<Map<String, dynamic>>
  }

  @override
  GeneratedFormSubForm clone() {
    return GeneratedFormSubForm(
      key,
      cloneFormItems(items),
      label: label,
      belowWidgets: belowWidgets,
      defaultValue: defaultValue,
    );
  }
}

// Generates a color in the HSLuv (Pastel) color space
// https://pub.dev/documentation/hsluv/latest/hsluv/Hsluv/hpluvToRgb.html
Color generateRandomLightColor() {
  final randomSeed = Random().nextInt(120);
  // https://en.wikipedia.org/wiki/Golden_angle
  final goldenAngle = 180 * (3 - sqrt(5));
  // Generate next golden angle hue
  final double hue = randomSeed * goldenAngle;
  // Map from HPLuv color space to RGB, use constant saturation=100, lightness=70
  final List<double> rgbValuesDbl = Hsluv.hpluvToRgb([hue, 100, 70]);
  // Map RBG values from 0-1 to 0-255:
  final List<int> rgbValues = rgbValuesDbl
      .map((rgb) => (rgb * 255).toInt())
      .toList();
  return Color.fromARGB(255, rgbValues[0], rgbValues[1], rgbValues[2]);
}

int generateRandomNumber(
  int seed1, {
  int seed2 = 0,
  int seed3 = 0,
  max = 10000,
}) {
  int combinedSeed = seed1.hashCode ^ seed2.hashCode ^ seed3.hashCode;
  Random random = Random(combinedSeed);
  int randomNumber = random.nextInt(max);
  return randomNumber;
}

bool validateTextField(TextFormField tf) =>
    (tf.key as GlobalKey<FormFieldState>).currentState?.isValid == true;

class _GeneratedFormState extends State<GeneratedForm> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> values = {};
  late List<List<Widget>> formInputs;
  List<List<Widget>> rows = [];
  String? initKey;
  int forceUpdateKeyCount = 0;

  // If any value changes, call this to update the parent with value and validity
  void someValueChanged({bool isBuilding = false, bool forceInvalid = false}) {
    final Map<String, dynamic> returnValues = values;
    var valid = true;
    for (var r = 0; r < formInputs.length; r++) {
      for (var i = 0; i < formInputs[r].length; i++) {
        if (formInputs[r][i] is TextFormField) {
          valid = valid && validateTextField(formInputs[r][i] as TextFormField);
        }
      }
    }
    if (forceInvalid) {
      valid = false;
    }
    widget.onValueChanges(returnValues, valid, isBuilding);
  }

  void initForm() {
    initKey = widget.key.toString();
    // Initialize form values as all empty
    values.clear();
    for (final row in widget.items) {
      for (final e in row) {
        values[e.key] = e.defaultValue;
      }
    }

    // Dynamically create form inputs
    formInputs = widget.items.asMap().entries.map((row) {
      return row.value.asMap().entries.map((e) {
        final formItem = e.value;
        if (formItem is GeneratedFormTextField) {
          final formFieldKey = GlobalKey<FormFieldState<Object?>>();
          final ctrl = TextEditingController(text: values[formItem.key]);
          return TypeAheadField<String>(
            controller: ctrl,
            builder: (context, controller, focusNode) {
              return TextFormField(
                controller: ctrl,
                focusNode: focusNode,
                keyboardType: formItem.textInputType,
                obscureText: formItem.password,
                autocorrect: !formItem.password,
                enableSuggestions: !formItem.password,
                key: formFieldKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {
                  setState(() {
                    values[formItem.key] = value;
                    someValueChanged();
                  });
                },
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  filled: true,
                  helperText: formItem.label + (formItem.required ? ' *' : ''),
                  hintText: formItem.hint,
                ),
                minLines: formItem.max <= 1 ? null : formItem.max,
                maxLines: formItem.max <= 1 ? 1 : formItem.max,
                validator: (value) {
                  if (formItem.required &&
                      (value == null || value.trim().isEmpty)) {
                    return '${formItem.label} ${tr('requiredInBrackets')}';
                  }
                  for (final validator in formItem.additionalValidators) {
                    final String? result = validator(value);
                    if (result != null) {
                      return result;
                    }
                  }
                  return null;
                },
              );
            },
            itemBuilder: (context, value) {
              return ListTile(title: Text(value));
            },
            onSelected: (value) {
              ctrl.text = value;
              setState(() {
                values[formItem.key] = value;
                someValueChanged();
              });
            },
            suggestionsCallback: (search) {
              return formItem.autoCompleteOptions
                  ?.where((t) => t.toLowerCase().contains(search.toLowerCase()))
                  .toList();
            },
            hideOnEmpty: true,
          );
        } else if (formItem is GeneratedFormDropdown) {
          if (formItem.opts!.isEmpty) {
            return Text(tr('dropdownNoOptsError'));
          }
          return DropdownMenuFormField<Object>(
            expandedInsets: EdgeInsets.zero,
            inputDecorationTheme: const InputDecorationThemeData(
              border: UnderlineInputBorder(),
              filled: true,
            ),
            label: Text(formItem.label),
            initialSelection: values[formItem.key],
            dropdownMenuEntries: formItem.opts!
                .map(
                  (e2) => DropdownMenuEntry(
                    value: e2.key,
                    enabled: formItem.disabledOptKeys?.contains(e2.key) != true,
                    label: e2.value,
                  ),
                )
                .toList(),
            onSelected: (value) => setState(() {
              values[formItem.key] = value ?? formItem.opts!.first.key;
              someValueChanged();
            }),
          );
        } else if (formItem is GeneratedFormSubForm) {
          values[formItem.key] = [];
          for (final Map<String, dynamic> v
              in ((formItem.defaultValue ?? []) as List<dynamic>)) {
            final fullDefaults = getDefaultValuesFromFormItems(formItem.items);
            for (final element in v.entries) {
              fullDefaults[element.key] = element.value;
            }
            values[formItem.key].add(fullDefaults);
          }
          return Container();
        } else {
          return Container(); // Some input types added in build
        }
      }).toList();
    }).toList();
    someValueChanged(isBuilding: true);
  }

  @override
  void initState() {
    super.initState();
    initForm();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    if (widget.key.toString() != initKey) {
      initForm();
    }
    for (var r = 0; r < formInputs.length; r++) {
      for (var e = 0; e < formInputs[r].length; e++) {
        final fieldKey = widget.items[r][e].key;
        if (widget.items[r][e] is GeneratedFormSwitch) {
          formInputs[r][e] = Flex.horizontal(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible.loose(child: Text(widget.items[r][e].label)),
              const SizedBox(width: 8),
              Switch(
                checked: values[fieldKey],
                onCheckedChanged:
                    (widget.items[r][e] as GeneratedFormSwitch).disabled
                    ? null
                    : (value) {
                        setState(() {
                          values[fieldKey] = value;
                          someValueChanged();
                        });
                      },
              ),
            ],
          );
        } else if (widget.items[r][e] is GeneratedFormTagInput) {
          void onAddPressed() {
            showDialog<Map<String, dynamic>?>(
              context: context,
              builder: (ctx) {
                return GeneratedFormModal(
                  title: widget.items[r][e].label,
                  items: [
                    [GeneratedFormTextField('label', label: tr('label'))],
                  ],
                );
              },
            ).then((value) {
              final String? label = value?['label'];
              if (label != null) {
                setState(() {
                  var temp =
                      values[fieldKey] as Map<String, MapEntry<int, bool>>?;
                  temp ??= {};
                  if (temp[label] == null) {
                    final singleSelect =
                        (widget.items[r][e] as GeneratedFormTagInput)
                            .singleSelect;
                    final someSelected = temp.entries
                        .where((element) => element.value.value)
                        .isNotEmpty;
                    temp[label] = MapEntry(
                      generateRandomLightColor().toARGB32(),
                      !(someSelected && singleSelect),
                    );
                    values[fieldKey] = temp;
                    someValueChanged();
                  }
                });
              }
            });
          }

          formInputs[r][e] = Flex.vertical(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if ((values[fieldKey] as Map<String, MapEntry<int, bool>>?)
                          ?.isNotEmpty ==
                      true &&
                  (widget.items[r][e] as GeneratedFormTagInput)
                      .showLabelWhenNotEmpty)
                Flex.vertical(
                  crossAxisAlignment:
                      (widget.items[r][e] as GeneratedFormTagInput).alignment ==
                          WrapAlignment.center
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.stretch,
                  children: [
                    Text(widget.items[r][e].label),
                    const SizedBox(height: 8),
                  ],
                ),
              Wrap(
                alignment:
                    (widget.items[r][e] as GeneratedFormTagInput).alignment,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12.0,
                runSpacing: 8.0,
                children: [
                  // (values[fieldKey] as Map<String, MapEntry<int, bool>>?)
                  //             ?.isEmpty ==
                  //         true
                  //     ? Text(
                  //         (widget.items[r][e] as GeneratedFormTagInput)
                  //             .emptyMessage,
                  //       )
                  //     : const SizedBox.shrink(),
                  // TODO: get rid of category colors across the app
                  // TODO: make categories be tags
                  ...(values[fieldKey] as Map<String, MapEntry<int, bool>>?)
                          ?.entries
                          .map((e2) {
                            final isSelected = e2.value.value;
                            return FilledButton(
                              onPressed: () {
                                final value = !isSelected;
                                setState(() {
                                  (values[fieldKey]
                                      as Map<String, MapEntry<int, bool>>)[e2
                                      .key] = MapEntry(
                                    (values[fieldKey]
                                            as Map<
                                              String,
                                              MapEntry<int, bool>
                                            >)[e2.key]!
                                        .key,
                                    value,
                                  );
                                  if ((widget.items[r][e]
                                              as GeneratedFormTagInput)
                                          .singleSelect &&
                                      value == true) {
                                    for (var key
                                        in (values[fieldKey]
                                                as Map<
                                                  String,
                                                  MapEntry<int, bool>
                                                >)
                                            .keys) {
                                      if (key != e2.key) {
                                        (values[fieldKey]
                                            as Map<
                                              String,
                                              MapEntry<int, bool>
                                            >)[key] = MapEntry(
                                          (values[fieldKey]
                                                  as Map<
                                                    String,
                                                    MapEntry<int, bool>
                                                  >)[key]!
                                              .key,
                                          false,
                                        );
                                      }
                                    }
                                  }
                                  someValueChanged();
                                });
                              },
                              style: ButtonStyle(
                                animationDuration: Duration.zero,
                                elevation: const WidgetStatePropertyAll(0.0),
                                shadowColor: WidgetStateColor.transparent,
                                minimumSize: const WidgetStatePropertyAll(
                                  Size(48.0, 40.0),
                                ),
                                fixedSize: const WidgetStatePropertyAll(null),
                                maximumSize: const WidgetStatePropertyAll(
                                  Size.infinite,
                                ),
                                padding: const WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 10.0,
                                  ),
                                ),
                                iconSize: const WidgetStatePropertyAll(20.0),
                                shape: WidgetStatePropertyAll(
                                  CornersBorder.rounded(
                                    corners: Corners.all(
                                      isSelected
                                          ? shapeTheme.corner.medium
                                          : shapeTheme.corner.full,
                                    ),
                                  ),
                                ),
                                overlayColor: WidgetStateLayerColor(
                                  color: WidgetStatePropertyAll(
                                    isSelected
                                        ? colorTheme.onSecondary
                                        : colorTheme.onSecondaryContainer,
                                  ),
                                  opacity: stateTheme.stateLayerOpacity,
                                ),
                                backgroundColor:
                                    WidgetStateProperty.resolveWith(
                                      (states) =>
                                          states.contains(WidgetState.disabled)
                                          ? colorTheme.onSurface.withValues(
                                              alpha: 0.1,
                                            )
                                          : isSelected
                                          ? colorTheme.secondary
                                          : colorTheme.secondaryContainer,
                                    ),
                                foregroundColor:
                                    WidgetStateProperty.resolveWith(
                                      (states) =>
                                          states.contains(WidgetState.disabled)
                                          ? colorTheme.onSurface.withValues(
                                              alpha: 0.38,
                                            )
                                          : isSelected
                                          ? colorTheme.onSecondary
                                          : colorTheme.onSecondaryContainer,
                                    ),
                                textStyle: WidgetStateProperty.resolveWith(
                                  (states) =>
                                      (isSelected
                                              ? typescaleTheme
                                                    .labelLargeEmphasized
                                              : typescaleTheme.labelLarge)
                                          .toTextStyle(),
                                ),
                              ),
                              child: Text(
                                e2.key,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                            // return Padding(
                            //   padding: const EdgeInsets.symmetric(
                            //     horizontal: 4,
                            //   ),
                            //   child: ChoiceChip(
                            //     label: Text(e2.key),
                            //     backgroundColor: Color(
                            //       e2.value.key,
                            //     ).withAlpha(50),
                            //     selectedColor: Color(e2.value.key),
                            //     visualDensity: VisualDensity.compact,
                            //     selected: e2.value.value,
                            // onSelected: (value) {
                            //   setState(() {
                            //     (values[fieldKey]
                            //         as Map<String, MapEntry<int, bool>>)[e2
                            //         .key] = MapEntry(
                            //       (values[fieldKey]
                            //               as Map<
                            //                 String,
                            //                 MapEntry<int, bool>
                            //               >)[e2.key]!
                            //           .key,
                            //       value,
                            //     );
                            //     if ((widget.items[r][e]
                            //                 as GeneratedFormTagInput)
                            //             .singleSelect &&
                            //         value == true) {
                            //       for (var key
                            //           in (values[fieldKey]
                            //                   as Map<
                            //                     String,
                            //                     MapEntry<int, bool>
                            //                   >)
                            //               .keys) {
                            //         if (key != e2.key) {
                            //           (values[fieldKey]
                            //               as Map<
                            //                 String,
                            //                 MapEntry<int, bool>
                            //               >)[key] = MapEntry(
                            //             (values[fieldKey]
                            //                     as Map<
                            //                       String,
                            //                       MapEntry<int, bool>
                            //                     >)[key]!
                            //                 .key,
                            //             false,
                            //           );
                            //         }
                            //       }
                            //     }
                            //     someValueChanged();
                            //   });
                            // },
                            //   ),
                            // );
                          }) ??
                      [const SizedBox.shrink()],
                ],
              ),
              Flex.horizontal(
                mainAxisAlignment:
                    (values[fieldKey] as Map<String, MapEntry<int, bool>>?)
                            ?.isEmpty ==
                        true
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.center,
                children: [
                  if ((values[fieldKey] as Map<String, MapEntry<int, bool>>?)
                          ?.values
                          .where((e) => e.value)
                          .length ==
                      1) ...[
                    IconButton(
                      onPressed: () {
                        setState(() {
                          final temp =
                              values[fieldKey]
                                  as Map<String, MapEntry<int, bool>>;
                          // get selected category str where bool is true
                          final oldEntry = temp.entries.firstWhere(
                            (entry) => entry.value.value,
                          );
                          // generate new color, ensure it is not the same
                          int newColor = oldEntry.value.key;
                          while (oldEntry.value.key == newColor) {
                            newColor = generateRandomLightColor().toARGB32();
                          }
                          // Update entry with new color, remain selected
                          temp.update(
                            oldEntry.key,
                            (old) => MapEntry(newColor, old.value),
                          );
                          values[fieldKey] = temp;
                          someValueChanged();
                        });
                      },
                      style: ButtonStyle(
                        animationDuration: Duration.zero,
                        elevation: const WidgetStatePropertyAll(0.0),
                        shadowColor: WidgetStateColor.transparent,
                        minimumSize: const WidgetStatePropertyAll(Size.zero),
                        fixedSize: const WidgetStatePropertyAll(
                          Size(52.0, 40.0),
                        ),
                        maximumSize: const WidgetStatePropertyAll(
                          Size.infinite,
                        ),
                        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                        iconSize: const WidgetStatePropertyAll(24.0),
                        shape: WidgetStatePropertyAll(
                          CornersBorder.rounded(
                            corners: Corners.all(shapeTheme.corner.full),
                          ),
                        ),
                        overlayColor: WidgetStateLayerColor(
                          color: WidgetStatePropertyAll(
                            colorTheme.onSurfaceVariant,
                          ),
                          opacity: stateTheme.stateLayerOpacity,
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.disabled)
                              ? colorTheme.onSurface.withValues(alpha: 0.1)
                              : colorTheme.surfaceContainerHighest,
                        ),
                        iconColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.disabled)
                              ? colorTheme.onSurface.withValues(alpha: 0.38)
                              : colorTheme.onSurfaceVariant,
                        ),
                      ),
                      icon: const IconLegacy(Symbols.format_color_fill_rounded),
                      tooltip: tr('colour'),
                    ),
                    const SizedBox(width: 12.0),
                  ],
                  if ((values[fieldKey] as Map<String, MapEntry<int, bool>>?)
                          ?.values
                          .where((e) => e.value)
                          .isNotEmpty ==
                      true) ...[
                    IconButton(
                      onPressed: () {
                        void fn() {
                          setState(() {
                            final temp =
                                values[fieldKey]
                                      as Map<String, MapEntry<int, bool>>
                                  ..removeWhere((key, value) => value.value);
                            values[fieldKey] = temp;
                            someValueChanged();
                          });
                        }

                        if ((widget.items[r][e] as GeneratedFormTagInput)
                                .deleteConfirmationMessage !=
                            null) {
                          final message =
                              (widget.items[r][e] as GeneratedFormTagInput)
                                  .deleteConfirmationMessage!;
                          showDialog<Map<String, dynamic>?>(
                            context: context,
                            builder: (ctx) {
                              return GeneratedFormModal(
                                title: message.key,
                                message: message.value,
                                items: const [],
                              );
                            },
                          ).then((value) {
                            if (value != null) {
                              fn();
                            }
                          });
                        } else {
                          fn();
                        }
                      },
                      style: ButtonStyle(
                        animationDuration: Duration.zero,
                        elevation: const WidgetStatePropertyAll(0.0),
                        shadowColor: WidgetStateColor.transparent,
                        minimumSize: const WidgetStatePropertyAll(Size.zero),
                        fixedSize: const WidgetStatePropertyAll(
                          Size(52.0, 40.0),
                        ),
                        maximumSize: const WidgetStatePropertyAll(
                          Size.infinite,
                        ),
                        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                        iconSize: const WidgetStatePropertyAll(24.0),
                        shape: WidgetStatePropertyAll(
                          CornersBorder.rounded(
                            corners: Corners.all(shapeTheme.corner.full),
                          ),
                        ),
                        overlayColor: WidgetStateLayerColor(
                          color: WidgetStatePropertyAll(
                            colorTheme.onSurfaceVariant,
                          ),
                          opacity: stateTheme.stateLayerOpacity,
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.disabled)
                              ? colorTheme.onSurface.withValues(alpha: 0.1)
                              : colorTheme.surfaceContainerHighest,
                        ),
                        iconColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.disabled)
                              ? colorTheme.onSurface.withValues(alpha: 0.38)
                              : colorTheme.onSurfaceVariant,
                        ),
                      ),
                      icon: const IconLegacy(Symbols.remove_rounded),
                      tooltip: tr('remove'),
                    ),
                    const SizedBox(width: 12.0),
                  ],
                  if ((values[fieldKey] as Map<String, MapEntry<int, bool>>?)
                          ?.isEmpty ==
                      true)
                    FilledButton.icon(
                      onPressed: onAddPressed,
                      style: ButtonStyle(
                        animationDuration: Duration.zero,
                        elevation: const WidgetStatePropertyAll(0.0),
                        shadowColor: WidgetStateColor.transparent,
                        minimumSize: const WidgetStatePropertyAll(
                          Size(48.0, 40.0),
                        ),
                        fixedSize: const WidgetStatePropertyAll(null),
                        maximumSize: const WidgetStatePropertyAll(
                          Size.infinite,
                        ),
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                        ),
                        iconSize: const WidgetStatePropertyAll(20.0),
                        shape: WidgetStatePropertyAll(
                          CornersBorder.rounded(
                            corners: Corners.all(shapeTheme.corner.medium),
                          ),
                        ),

                        overlayColor: WidgetStateLayerColor(
                          color: WidgetStatePropertyAll(
                            colorTheme.onSurfaceVariant,
                          ),
                          opacity: stateTheme.stateLayerOpacity,
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.disabled)
                              ? colorTheme.onSurface.withValues(alpha: 0.1)
                              : colorTheme.surfaceContainerHighest,
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.disabled)
                              ? colorTheme.onSurface.withValues(alpha: 0.38)
                              : colorTheme.onSurfaceVariant,
                        ),
                        textStyle: WidgetStateProperty.resolveWith(
                          (states) => typescaleTheme.labelLarge.toTextStyle(),
                        ),
                      ),
                      icon: const IconLegacy(Symbols.add_rounded),
                      label: Text(
                        (widget.items[r][e] as GeneratedFormTagInput).label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else
                    IconButton(
                      onPressed: onAddPressed,
                      style: ButtonStyle(
                        animationDuration: Duration.zero,
                        elevation: const WidgetStatePropertyAll(0.0),
                        shadowColor: WidgetStateColor.transparent,
                        minimumSize: const WidgetStatePropertyAll(Size.zero),
                        fixedSize: const WidgetStatePropertyAll(
                          Size(52.0, 40.0),
                        ),
                        maximumSize: const WidgetStatePropertyAll(
                          Size.infinite,
                        ),
                        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                        iconSize: const WidgetStatePropertyAll(24.0),
                        shape: WidgetStatePropertyAll(
                          CornersBorder.rounded(
                            corners: Corners.all(shapeTheme.corner.full),
                          ),
                        ),
                        overlayColor: WidgetStateLayerColor(
                          color: WidgetStatePropertyAll(
                            colorTheme.onSurfaceVariant,
                          ),
                          opacity: stateTheme.stateLayerOpacity,
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.disabled)
                              ? colorTheme.onSurface.withValues(alpha: 0.1)
                              : colorTheme.surfaceContainerHighest,
                        ),
                        iconColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.disabled)
                              ? colorTheme.onSurface.withValues(alpha: 0.38)
                              : colorTheme.onSurfaceVariant,
                        ),
                      ),
                      icon: const IconLegacy(Symbols.add_rounded),
                      tooltip: tr('add'),
                    ),
                ],
              ),
            ],
          );
        } else if (widget.items[r][e] is GeneratedFormSubForm) {
          final List<Widget> subformColumn = [];
          final compact =
              (widget.items[r][e] as GeneratedFormSubForm).items.length == 1 &&
              (widget.items[r][e] as GeneratedFormSubForm).items[0].length == 1;
          for (var i = 0; i < values[fieldKey].length; i++) {
            final internalFormKey = ValueKey(
              generateRandomNumber(
                values[fieldKey].length,
                seed2: i,
                seed3: forceUpdateKeyCount,
              ),
            );
            subformColumn.add(
              Flex.vertical(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!compact) const SizedBox(height: 16),
                  if (!compact)
                    Text(
                      '${(widget.items[r][e] as GeneratedFormSubForm).label} (${i + 1})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  GeneratedForm(
                    key: internalFormKey,
                    items:
                        cloneFormItems(
                              (widget.items[r][e] as GeneratedFormSubForm)
                                  .items,
                            )
                            .map(
                              (x) => x.map((y) {
                                y
                                  ..defaultValue = values[fieldKey]?[i]?[y.key]
                                  ..key =
                                      '${y.key.toString()},$internalFormKey';
                                return y;
                              }).toList(),
                            )
                            .toList(),
                    onValueChanges: (values, valid, isBuilding) {
                      values = values.map(
                        (key, value) => MapEntry(key.split(',')[0], value),
                      );
                      if (valid) {
                        this.values[fieldKey]?[i] = values;
                      }
                      someValueChanged(
                        isBuilding: isBuilding,
                        forceInvalid: !valid,
                      );
                    },
                  ),
                  Flex.horizontal(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton.icon(
                        onPressed: (values[fieldKey].length > 0)
                            ? () {
                                final temp = List.from(values[fieldKey])
                                  ..removeAt(i);
                                values[fieldKey] = List.from(temp);
                                forceUpdateKeyCount++;
                                someValueChanged();
                              }
                            : null,
                        style: ButtonStyle(
                          animationDuration: Duration.zero,
                          elevation: const WidgetStatePropertyAll(0.0),
                          shadowColor: WidgetStateColor.transparent,
                          minimumSize: const WidgetStatePropertyAll(
                            Size(48.0, 32.0),
                          ),
                          fixedSize: const WidgetStatePropertyAll(null),
                          maximumSize: const WidgetStatePropertyAll(
                            Size.infinite,
                          ),
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 6.0,
                            ),
                          ),
                          iconSize: const WidgetStatePropertyAll(20.0),
                          shape: WidgetStatePropertyAll(
                            CornersBorder.rounded(
                              corners: Corners.all(shapeTheme.corner.medium),
                            ),
                          ),
                          overlayColor: WidgetStateLayerColor(
                            color: WidgetStatePropertyAll(colorTheme.error),
                            opacity: stateTheme.stateLayerOpacity,
                          ),
                          backgroundColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.disabled)
                                ? colorTheme.onSurface.withValues(alpha: 0.1)
                                : Colors.transparent,
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.disabled)
                                ? colorTheme.onSurface.withValues(alpha: 0.38)
                                : colorTheme.error,
                          ),
                          textStyle: WidgetStateProperty.resolveWith(
                            (states) => typescaleTheme.labelLarge.toTextStyle(),
                          ),
                        ),
                        icon: const IconLegacy(Symbols.delete_rounded, fill: 0),
                        label: Text(
                          '${(widget.items[r][e] as GeneratedFormSubForm).label} (${i + 1})',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          subformColumn.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 0, top: 8),
              child: Flex.horizontal(
                children: [
                  Flexible.tight(
                    child: FilledButton.icon(
                      onPressed: () {
                        values[fieldKey].add(
                          getDefaultValuesFromFormItems(
                            (widget.items[r][e] as GeneratedFormSubForm).items,
                          ),
                        );
                        forceUpdateKeyCount++;
                        someValueChanged();
                      },
                      style: ButtonStyle(
                        animationDuration: Duration.zero,
                        elevation: const WidgetStatePropertyAll(0.0),
                        shadowColor: WidgetStateColor.transparent,
                        minimumSize: const WidgetStatePropertyAll(
                          Size(48.0, 40.0),
                        ),
                        fixedSize: const WidgetStatePropertyAll(null),
                        maximumSize: const WidgetStatePropertyAll(
                          Size.infinite,
                        ),
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                        ),
                        iconSize: const WidgetStatePropertyAll(20.0),
                        shape: WidgetStatePropertyAll(
                          CornersBorder.rounded(
                            corners: Corners.all(shapeTheme.corner.full),
                          ),
                        ),
                        side: WidgetStatePropertyAll(
                          BorderSide(
                            width: 1.0,
                            color: colorTheme.outlineVariant,
                          ),
                        ),
                        overlayColor: WidgetStateLayerColor(
                          color: WidgetStatePropertyAll(
                            colorTheme.onSurfaceVariant,
                          ),
                          opacity: stateTheme.stateLayerOpacity,
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.disabled)
                              ? colorTheme.onSurface.withValues(alpha: 0.1)
                              : Colors.transparent,
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.disabled)
                              ? colorTheme.onSurface.withValues(alpha: 0.38)
                              : colorTheme.onSurfaceVariant,
                        ),
                        textStyle: WidgetStateProperty.resolveWith(
                          (states) => typescaleTheme.labelLarge.toTextStyle(),
                        ),
                      ),
                      icon: const IconLegacy(Symbols.add_rounded),
                      label: Text(
                        (widget.items[r][e] as GeneratedFormSubForm).label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
          formInputs[r][e] = Flex.vertical(children: subformColumn);
        }
      }
    }

    rows.clear();
    formInputs.asMap().entries.forEach((rowInputs) {
      if (rowInputs.key > 0) {
        rows.add([
          SizedBox(
            height: widget.items[rowInputs.key - 1][0] is GeneratedFormSwitch
                ? 8
                : 25,
          ),
        ]);
      }
      final rowItems = <Widget>[];
      rowInputs.value.asMap().entries.forEach((rowInput) {
        if (rowInput.key > 0) {
          rowItems.add(const SizedBox(width: 20));
        }
        rowItems.add(
          Flexible.tight(
            child: Flex.vertical(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                rowInput.value,
                ...widget.items[rowInputs.key][rowInput.key].belowWidgets,
              ],
            ),
          ),
        );
      });
      rows.add(rowItems);
    });

    return Form(
      key: _formKey,
      child: Flex.vertical(
        children: [
          ...rows.map(
            (row) => Flex.horizontal(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [...row.map((e) => e)],
            ),
          ),
        ],
      ),
    );
  }
}
