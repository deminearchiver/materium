library;

// SDK packages

export 'package:flutter/foundation.dart' hide clampDouble;

export 'package:flutter/services.dart';

export 'package:flutter/physics.dart';

export 'package:flutter/rendering.dart'
    hide
        ChildLayoutHelper,
        FlexParentData,
        FloatingHeaderSnapConfiguration,
        OverScrollHeaderStretchConfiguration,
        PersistentHeaderShowOnScreenConfiguration,
        RenderFlex,
        RenderPadding;

export 'package:flutter/material.dart'
    hide
        // package:layout
        // ---
        Padding,
        Align,
        Center,
        Flex,
        Row,
        Column,
        Flexible,
        Expanded,
        Spacer,
        // ---
        // package:material
        // ---
        WidgetStateProperty,
        WidgetStatesConstraint,
        WidgetStateMap,
        WidgetStateMapper,
        WidgetStatePropertyAll,
        WidgetStatesController,
        // ---
        Material,
        MaterialType,
        // ---
        Icon,
        IconTheme,
        IconThemeData,
        // ---
        // Force migration to Material Symbols
        Icons,
        AnimatedIcons,
        // ---
        CircularProgressIndicator,
        LinearProgressIndicator,
        ProgressIndicator,
        // ---
        Checkbox,
        CheckboxTheme,
        CheckboxThemeData,
        // ---
        Switch,
        SwitchTheme,
        SwitchThemeData;

// Third-party packages

export 'package:layout/layout.dart';
export 'package:material/material.dart';
export 'package:material/material_symbols.dart';
export 'package:meta/meta.dart';

// Adjacent libraries

export 'assets/assets.gen.dart';
export 'assets/fonts.dart';
export 'assets/fonts.gen.dart';
export 'components/combining_builder.dart';
export 'components/inverse_center_optically.dart';
export 'components/list_item.dart';
export 'i18n/i18n.dart';
export 'theme/extended_color.dart';
export 'theme/legacy.dart';
export 'theme/semantic_colors.dart';
export 'theme/static_colors.dart';
export 'theme/theme.dart';
export 'theme/typography.dart';
export 'extensions.dart';
export 'optional.dart';
