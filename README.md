# WayWing

# Developing

## Using custom "Winged" flutter widgets

To properly support our theming and functionality, make sure to use our following custom widgets instead of the default flutter counterparts. Using the default flutter widgets will cause them to look off, not react to style config, or not function properly.

### Use WingedButton instead of default flutter Button, InkWell, ListTile, etc.

WingedButton works similarly to builtin flutter material button widgets, but follows the user config and waywing style.

### Use WingedIcon instead of Icon widget

WingedIcon is a custom widget that accepts any combination of a flutter icon, the name for an xdg icon, or a textIcon character from something like a NerdFont. At runtime, the appropriate alternative will be rendered according to user config, and fallbacks will be used in the order defined in user config.

- **Use SymbolsVaried instead of default flutter Icons**
For the actual IconData you pass to WingedIcon.flutterIcon, prefer using a constant from SymbolsVaried, which has all [official material symbol icons](https://fonts.google.com/icons). You can use other IconData, but it won't support customization like fill, weight, variant, etc.

### Use Motions instead of default flutter animations.

We use [Material Motions](https://pub.dev/packages/motor). (TODO: 1 write about why we use this, benefits vs. normal animations)

- **Use implicit motion widgets (MotionContainer, MotionPadding, etc.) instead of default flutter implicitly animated widgets (AnimatedContainer, AnimatedPadding, etc.).**
The implicit motion widgets work exactly like flutter implicitly animated widgets. The only difference is they receive a Motion instead of duration and curve.

- **Use MotionController instead of AnimationController.**
MotionController works very similarly to AnimationController, but there are some differences, see relevant [motor package docs](https://pub.dev/packages/motor#low-level-motion-control).

The Motions used on widgets and controllers should be obtained be from config, for example: `mainConfig.motions.standard.spatial.normal`. To understand how to decide which motion to use, see [material design spec](https://m3.material.io/styles/motion/overview/how-it-works#91dfe12e-1e79-4417-a27e-33049358b149).

### Use WingedContainer instead of Card or Material

This is only relevant when creating new surfaces, like when implementing a new Wing; if you are only creating a Feather then the Wing where it will be added should take care of this. WingedContainer is a widget that should be the root of any surface you create. It provides a background, shadows, and flutter Material base all according to waywing config. Also, WingedContainer creates an InputRegion (TODO: 1 add link to explain InputRegion) by default, so if you try to create a new surface without it, mouse input won't work.

- **Use ExternalRoundedCornersBorder instead of RoundedRectangleBorder.** It can do everything RoundedRectangleBorder can do
and also supports the "external" curving out corners, by setting negative radius. It also has support for active/inactive 
borders when used in a WingedContainer. The shape of a WingedContainer should always be ExternalRoundedCornersBorder, unless
you want to implement a really weird custom shape.

### Use WingedPopover instead of Dialogs, Pages, Tooltips, etc.

TODO: 1 write WingedPopover docs, kinda complicated. Also about WingedModal and WingedContextMenu

