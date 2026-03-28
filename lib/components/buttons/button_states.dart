part of 'buttons.dart';

typedef ButtonStateProperty<T extends Object?, S extends Object?> =
    StateProperty<T, ButtonStates<S>>;

mixin ButtonStates<S extends Object?> implements InteractiveStates {
  S get settings;
}

mixin ButtonDisabledStates<S extends Object?>
    implements ButtonStates<S>, InteractiveDisabledStates {}

mixin ButtonEnabledStates<S extends Object?>
    implements ButtonStates<S>, InteractiveEnabledStates {}

mixin ToggleButtonStates<S extends Object?>
    implements ButtonStates<S>, SelectableStates {}

sealed class _ButtonStates<S extends Object?>
    with Diagnosticable, ButtonStates<S> {
  const _ButtonStates({required this.settings});

  factory _ButtonStates.fromButtonStates(ButtonStates<S> states) =>
      switch (states) {
        final ToggleButtonStates<S> states =>
          _ToggleButtonStates.fromToggleButtonStates(states),
        final ButtonStates<S> states => _DefaultButtonStates.fromButtonStates(
          states,
        ),
      };

  @override
  final S settings;

  bool? get isSelected;

  bool get isDisabled;

  bool get isHovered;

  bool get isFocused;

  bool get isPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<S>("settings", settings));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is _ButtonStates<S> &&
          isSelected == other.isSelected &&
          isDisabled == other.isDisabled &&
          isHovered == other.isHovered &&
          isFocused == other.isFocused &&
          isPressed == other.isPressed &&
          settings == other.settings;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isSelected,
    isDisabled,
    isHovered,
    isFocused,
    isPressed,
    settings,
  );
}

sealed class _DefaultButtonStates<S extends Object?> extends _ButtonStates<S> {
  const _DefaultButtonStates({required super.settings});

  const factory _DefaultButtonStates.disabled({required S settings}) =
      _DefaultButtonDisabledStates<S>;

  const factory _DefaultButtonStates.enabled({
    required S settings,
    bool isHovered,
    bool isFocused,
    bool isPressed,
  }) = _DefaultButtonEnabledStates<S>;

  factory _DefaultButtonStates.fromInteractiveStates(
    InteractiveStates states, {
    required S settings,
  }) => switch (states) {
    InteractiveEnabledStates(
      :final isHovered,
      :final isFocused,
      :final isPressed,
    ) =>
      .enabled(
        settings: settings,
        isHovered: isHovered,
        isFocused: isFocused,
        isPressed: isPressed,
      ),
    InteractiveDisabledStates() || _ => .disabled(settings: settings),
  };

  factory _DefaultButtonStates.fromButtonStates(ButtonStates<S> states) =>
      .fromInteractiveStates(states, settings: states.settings);

  factory _DefaultButtonStates.fromWidgetStates(
    WidgetStates states, {
    required S settings,
    bool? isDisabled,
    bool? isHovered,
    bool? isFocused,
    bool? isPressed,
  }) {
    states as StrictSet<WidgetState>;
    final resolvedIsDisabled = isDisabled ?? states.contains(.disabled);
    return resolvedIsDisabled
        ? .disabled(settings: settings)
        : .enabled(
            settings: settings,
            isHovered: isHovered ?? states.contains(.hovered),
            isFocused: isFocused ?? states.contains(.focused),
            isPressed: isPressed ?? states.contains(.pressed),
          );
  }

  @override
  bool? get isSelected => null;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      FlagProperty(
        "isDisabled",
        value: isDisabled,
        showName: false,
        ifFalse: "enabled",
        ifTrue: "disabled",
      ),
    );
  }
}

class _DefaultButtonDisabledStates<S extends Object?>
    extends _DefaultButtonStates<S>
    with ButtonDisabledStates<S> {
  const _DefaultButtonDisabledStates({required super.settings});

  @override
  bool get isDisabled => true;

  @override
  bool get isHovered => false;

  @override
  bool get isFocused => false;

  @override
  bool get isPressed => false;
}

class _DefaultButtonEnabledStates<S extends Object?>
    extends _DefaultButtonStates<S>
    with ButtonEnabledStates<S> {
  const _DefaultButtonEnabledStates({
    required super.settings,
    this.isHovered = false,
    this.isFocused = false,
    this.isPressed = false,
  });

  @override
  bool get isDisabled => false;

  @override
  final bool isHovered;

  @override
  final bool isFocused;

  @override
  final bool isPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        FlagProperty(
          "isHovered",
          value: isHovered,
          defaultValue: false,
          showName: false,
          ifTrue: "hovered",
        ),
      )
      ..add(
        FlagProperty(
          "isFocused",
          value: isFocused,
          defaultValue: false,
          showName: false,
          ifTrue: "focused",
        ),
      )
      ..add(
        FlagProperty(
          "isPressed",
          value: isPressed,
          defaultValue: false,
          showName: false,
          ifTrue: "pressed",
        ),
      );
  }
}

sealed class _ToggleButtonStates<S extends Object?>
    extends _DefaultButtonStates<S>
    with ToggleButtonStates<S> {
  const _ToggleButtonStates({
    required super.settings,
    required this.isSelected,
  });

  const factory _ToggleButtonStates.disabled({
    required S settings,
    required bool isSelected,
  }) = _ToggleButtonDisabledStates<S>;

  const factory _ToggleButtonStates.enabled({
    required S settings,
    required bool isSelected,
    bool isHovered,
    bool isFocused,
    bool isPressed,
  }) = _ToggleButtonEnabledStates<S>;

  factory _ToggleButtonStates.fromInteractiveStates(
    InteractiveStates states, {
    required S settings,
    required bool isSelected,
  }) => switch (states) {
    InteractiveEnabledStates(
      :final isHovered,
      :final isFocused,
      :final isPressed,
    ) =>
      .enabled(
        settings: settings,
        isSelected: isSelected,
        isHovered: isHovered,
        isFocused: isFocused,
        isPressed: isPressed,
      ),
    InteractiveDisabledStates() ||
    _ => .disabled(settings: settings, isSelected: isSelected),
  };

  factory _ToggleButtonStates.fromToggleButtonStates(
    ToggleButtonStates<S> states,
  ) => .fromInteractiveStates(
    states,
    settings: states.settings,
    isSelected: states.isSelected,
  );

  factory _ToggleButtonStates.fromWidgetStates(
    WidgetStates states, {
    required S settings,
    bool? isSelected,
    bool? isDisabled,
    bool? isHovered,
    bool? isFocused,
    bool? isPressed,
  }) {
    states as StrictSet<WidgetState>;
    final resolvedIsSelected = isSelected ?? states.contains(.selected);
    final resolvedIsDisabled = isDisabled ?? states.contains(.disabled);
    return resolvedIsDisabled
        ? .disabled(settings: settings, isSelected: resolvedIsSelected)
        : .enabled(
            settings: settings,
            isSelected: resolvedIsSelected,
            isHovered: isHovered ?? states.contains(.hovered),
            isFocused: isFocused ?? states.contains(.focused),
            isPressed: isPressed ?? states.contains(.pressed),
          );
  }

  @override
  final bool isSelected;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        FlagProperty(
          "isSelected",
          value: isSelected,
          showName: false,
          ifFalse: "unselected",
          ifTrue: "selected",
        ),
      )
      ..add(
        FlagProperty(
          "isDisabled",
          value: isDisabled,
          showName: false,
          ifFalse: "enabled",
          ifTrue: "disabled",
        ),
      );
  }
}

class _ToggleButtonDisabledStates<S extends Object?>
    extends _ToggleButtonStates<S>
    with ButtonDisabledStates<S> {
  const _ToggleButtonDisabledStates({
    required super.settings,
    required super.isSelected,
  });

  @override
  bool get isDisabled => true;

  @override
  bool get isHovered => false;

  @override
  bool get isFocused => false;

  @override
  bool get isPressed => false;
}

class _ToggleButtonEnabledStates<S extends Object?>
    extends _ToggleButtonStates<S>
    with ButtonEnabledStates<S> {
  const _ToggleButtonEnabledStates({
    required super.settings,
    required super.isSelected,
    this.isHovered = false,
    this.isFocused = false,
    this.isPressed = false,
  });

  @override
  bool get isDisabled => false;

  @override
  final bool isHovered;

  @override
  final bool isFocused;

  @override
  final bool isPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        FlagProperty(
          "isHovered",
          value: isHovered,
          defaultValue: false,
          showName: false,
          ifTrue: "hovered",
        ),
      )
      ..add(
        FlagProperty(
          "isFocused",
          value: isFocused,
          defaultValue: false,
          showName: false,
          ifTrue: "focused",
        ),
      )
      ..add(
        FlagProperty(
          "isPressed",
          value: isPressed,
          defaultValue: false,
          showName: false,
          ifTrue: "pressed",
        ),
      );
  }
}
