# do_it

A Flutter package that replaces three common Flutter boilerplate patterns with clean, minimal APIs.

| Instead of | Use |
|---|---|
| `setState(() { ... })` | `ReactiveState` + `ReactiveBuilder` |
| `Navigator.pushNamed(...)` | `AppRouter.push(...)` |
| `MediaQuery.of(context).size.width` | `ScreenSize.width(context)` |

## Getting started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  do_it: ^0.0.1
```

Then import:

```dart
import 'package:do_it/do_it.dart';
```

## Usage

### ReactiveState — replaces `setState`

No `StatefulWidget` needed. Declare state anywhere, rebuild only the widget that needs it.

```dart
final count = ReactiveState(0);

// update value — triggers rebuild in any listening ReactiveBuilder
count.update((n) => n + 1);

// or set directly
count.value = 42;
```

```dart
ReactiveBuilder<int>(
  state: count,
  builder: (context, value) => Text('$value'),
)
```

### AppRouter — replaces `Navigator`

```dart
AppRouter.push(context, '/details', arguments: {'id': 1});
AppRouter.pushReplacement(context, '/home');
AppRouter.pushAndClearStack(context, '/login');
AppRouter.pop(context);
AppRouter.popUntil(context, '/home');
AppRouter.canPop(context);
```

### ScreenSize — replaces `MediaQuery` width/height

Uses `MediaQuery.sizeOf` internally — more efficient than `MediaQuery.of`.

```dart
ScreenSize.width(context)               // full width
ScreenSize.height(context)              // full height
ScreenSize.widthPercent(context, 80)    // 80% of width
ScreenSize.heightPercent(context, 50)   // 50% of height
ScreenSize.isTablet(context)            // width >= 600
ScreenSize.isDesktop(context)           // width >= 1200
ScreenSize.isLandscape(context)
ScreenSize.isPortrait(context)
```

## Additional information

- File issues and PRs at [github.com/your-username/do_it](https://github.com/your-username/do_it)
- Contributions welcome
