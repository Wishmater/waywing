# Configuration Classes

This document lists all configuration classes marked with `@Config()`.

## ThemeConfig


|name|description|type|default|
|--|--|--|--|
|mode||ThemeMode|ThemeMode.system|
|fontFamily| Use this to set a custom font|String?|null|
|fontSize| Set the font size|double|14.00|
|iconPriority||List\<IconType\>|[IconType.flutter, IconType.direct, IconType.linux, IconType.nerdFont]|
|iconFlutterVariation||ConfigIconVariation|ConfigIconVariation.normal|
|iconFlutterTwoTone||bool|false|
|iconFlutterFill||double|0.00|
|iconFlutterWeight||double|400.00|
|primaryColor||MyColor|MyColor(0xFF2196F3)|
|secondaryColor||MyColor?|null|
|tertiaryColor||MyColor?|null|
|errorColor||MyColor?|null|
|backgroundColor||MyColor?|null|
|foregroundColor||MyColor?|null|
|backgroundOpacity||double|1.00|
|shadows||double|1.00|
|buttonRounding||double|12.00|
|containerRounding||double|24.00|
|activeBorderSize||double|2.00|
|_inactiveBorderSize||double?|null|
|activeBorderColors||List\<MyColor\>|[MyColor(0xee33ccff), MyColor(0xee00ff99)]|
|inactiveBorderColors||List\<MyColor\>|[MyColor(0xaa595959)]|
|activeBorderAngle||double|45.00|
|inactiveBorderAngle||double|45.00|

## MainConfig


|name|description|type|default|
|--|--|--|--|
|monitor||int|0|
|socket||String?|null|
|focusGrab||bool|false|
|focusContainerOnMouseOver||bool|true|
|animationEnable||bool|true|
|animationSpeed||double|1.00|
|animationDamping||double|1.00|
|animationFitting||AnimationFitting|AnimationFitting.clip|
|animationSwitching||AnimationSwitching|AnimationSwitching.fadeThrough|
|requestKeyboardFocus||bool|false|
|internalUsePainter||bool|false|
|logging||[LoggingConfig](#LoggingConfig)||
|theme||[ThemeConfig](#ThemeConfig)||
|dynamicSchemas||List\<(String, Object)\>||

## FeathersContainer


|name|description|type|default|
|--|--|--|--|
|dynamicSchemas||List\<(String, Object)\>||

## LoggingConfig


|name|description|type|default|
|--|--|--|--|
|levelFilter||Level|(kDebugMode ? Level.trace : Level.info)|
|typeLevelFilters||Map\<String, Level\>|{ }|
|output||String?|null|

## ModalConfig


|name|description|type|default|
|--|--|--|--|
|barrierColor||MyColor|MyColor(0x8A000000)|
|barrierDismissable||bool|true|
|width||double|400.00|
|height||double|400.00|
|maxWidth||double?|null|
|maxHeight||double?|null|
|dynamicSchemas||List\<(String, Object)\>||

## ClockConfig


|name|description|type|default|
|--|--|--|--|
|militar||bool|false|

## LauncherConfig


|name|description|type|default|
|--|--|--|--|
|iconSize||int?|null|
|showScrollBar||bool|true|

## VolumeConfig


|name|description|type|default|
|--|--|--|--|
|showPercentageIndicator||bool|true|
|showSeparateMicIndicator||bool|false|
|maxVolume||int|100|
|volumeStep||int|5|
|showTooltipOnVolumeChange||bool|true|

## BarConfig


|name|description|type|default|
|--|--|--|--|
|side||ScreenEdge|ScreenEdge.bottom|
|size||int|30|
|marginLeft||double|0.00|
|marginRight||double|0.00|
|marginTop||double|0.00|
|marginBottom||double|0.00|
|_exclusiveSizeLeft||double?|null|
|_exclusiveSizeRight||double?|null|
|_exclusiveSizeTop||double?|null|
|_exclusiveSizeBottom||double?|null|
|_rounding||double?|null|
|_indicatorMinSize||double?|null|
|_indicatorPadding||double?|null|
|dynamicSchemas||List\<(String, Object)\>||

## BarFeathersContainer


|name|description|type|default|
|--|--|--|--|
|dynamicSchemas||List\<(String, Object)\>||

## NotificationsConfig


|name|description|type|default|
|--|--|--|--|
|alignment||Alignment|Alignment.topLeft|
|marginLeft||double|32.00|
|marginRight||double|32.00|
|marginTop||double|32.00|
|marginBottom||double|32.00|
|autoExpand||bool|false|
|showProgressBar||bool|false|

## SpacerConfig


|name|description|type|default|
|--|--|--|--|
|size||double|12.00|

## DividerConfig


|name|description|type|default|
|--|--|--|--|
|size||double|12.00|
|thickness||double|2.00|
|indent||double|6.00|

## NetworkManagerConfig


|name|description|type|default|
|--|--|--|--|
|showConnectionNameIndicator||bool|false|
|showUploadIndicator||bool|false|
|showDownloadIndicator||bool|false|
|showThroughputIndicator||bool|true|
|deviceTypeFilter||List\<String\>|[ ]|

## KbLayoutServiceConfig


|name|description|type|default|
|--|--|--|--|
|pullInterval| pull interval in milliseconds|int|500|

## BatteryConfig


|name|description|type|default|
|--|--|--|--|
|enableProfile| Enable powerprofile functionality&#10;&#10; this option only matters if powerprofiles is installed in the system&#10; otherwise profile service will be disable nonetheless|bool|true|
|automaticProfileChanging| Enable automatic handling of powerprofile changing depending on the battery level|bool|true|
|saverProfile| Profile to be set when the battery level is below the threshold|String|"power-saver"|
|normalProfile| Profile to be set when the battery level is above the threshold|String|"balanced"|
|batteryThreshold| Battery level threshold|double|30.00|

