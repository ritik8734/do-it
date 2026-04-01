# do_it_kit

A Flutter package that replaces Flutter boilerplate with a single, clean `Do` class.

| Feature | API |
|---|---|
| Reactive state (replaces `setState`) | `DoState` + `Do(state, builder)` |
| Dependency injection (like `Get.put`) | `Do.put` / `Do.find` |
| Named route navigation (no context) | `Do.to` / `Do.back` |
| Context navigation | `Do.push` / `Do.pop` |
| Theme manager | `DoTheme` / `Do.toggleTheme()` |
| HTTP client (Dio wrapper) | `Do.api.get` / `.post` / `.put` / `.delete` |
| Screen size | `Do.width` / `Do.height` / `Do.widthPercent` |

---

## Installation

```yaml
dependencies:
  do_it_kit: ^0.1.0
```

```dart
import 'package:do_it_kit/do_it_kit.dart';
```

---

## Reactive State

Replaces `setState` and `StatefulWidget`. Declare state anywhere — only the wrapped widget rebuilds.

```dart
final count = DoState(0);

// update via callback
count.set((n) => n + 1);

// or set directly
count.value = 42;
```

Wrap any widget with `Do(state, builder)` — only that widget rebuilds when state changes:

```dart
Do(count, (value) => Text('$value'))
```

Multiple states, independent rebuilds:

```dart
final name = DoState('Flutter');
final count = DoState(0);

Column(
  children: [
    Do(name,  (v) => Text('Hello, $v')),   // rebuilds only when name changes
    Do(count, (v) => Text('Count: $v')),   // rebuilds only when count changes
  ],
)
```

---

## Dependency Injection

Register and retrieve services globally — like `Get.put` / `Get.find`.

```dart
// register once (e.g. in main())
Do.put(ApiService());
Do.put(AuthService(), tag: 'admin');  // optional tag for multiple instances

// retrieve anywhere
Do.find<ApiService>().fetchUsers();
Do.find<AuthService>(tag: 'admin');

// check if registered
DoInjector.isRegistered<ApiService>();

// remove
Do.delete<ApiService>();
```

---

## Named Route Navigation

No `BuildContext` needed. Attach `DoRouter.key` and `DoRouter.onGenerateRoute` to `MaterialApp` once, then navigate from anywhere.

**Setup:**

```dart
void main() {
  DoRouter.define('/',        ([_]) => HomePage());
  DoRouter.define('/detail',  ([args]) => DetailPage(args: args));
  DoRouter.define('/login',   ([_]) => LoginPage());

  runApp(MyApp());
}

MaterialApp(
  navigatorKey: DoRouter.key,
  onGenerateRoute: DoRouter.onGenerateRoute,
  initialRoute: '/',
)
```

**Navigate:**

```dart
Do.to('/detail', args: {'id': 1});   // push
Do.off('/home');                      // replace current
Do.offAll('/login');                  // push + clear stack
Do.back();                            // pop
Do.back('result');                    // pop with result
```

---

## Context Navigation

Builder-based navigation when you have a `BuildContext`:

```dart
Do.push(context, () => DetailPage());
Do.pushReplace(context, () => HomePage());
Do.pushAndClear(context, () => LoginPage());
Do.pop(context);
Do.pop(context, result);
```

---

## Theme Manager

Reactive theme switching — `DoThemeBuilder` rebuilds `MaterialApp` automatically.

**Setup:**

```dart
// optionally customize themes
DoTheme.light = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue));
DoTheme.dark  = ThemeData.dark();

DoThemeBuilder(
  builder: (themeMode) => MaterialApp(
    theme: DoTheme.light,
    darkTheme: DoTheme.dark,
    themeMode: themeMode,
    home: HomePage(),
  ),
)
```

**Control:**

```dart
Do.toggleTheme();                  // light ↔ dark
Do.setTheme(ThemeMode.dark);       // set explicitly
Do.isDark;                         // bool
```

---

## API Client

Dio-based HTTP client. Configure once, use everywhere via `Do.api`.

**Setup:**

```dart
Do.api.baseUrl = 'https://api.example.com';
Do.api.headers['Authorization'] = 'Bearer $token';
Do.api.addInterceptor(LogInterceptor());  // optional
```

**Requests:**

```dart
// GET
final result = await Do.api.get('/users');

// GET with query params + typed response
final result = await Do.api.get<List<User>>(
  '/users',
  query: {'page': 1},
  fromJson: (d) => (d as List).map(User.fromJson).toList(),
);

// POST
final result = await Do.api.post('/users', body: {'name': 'Alice'});

// PUT / PATCH / DELETE
await Do.api.put('/users/1', body: data);
await Do.api.patch('/users/1', body: data);
await Do.api.delete('/users/1');
```

**Handle the result:**

Every call returns `DoResult<T>` — either `DoSuccess` or `DoError`. Use pattern matching:

```dart
switch (result) {
  case DoSuccess(:final data):
    print(data);
  case DoError(:final message, :final statusCode):
    print('$statusCode: $message');
}
```

---

## Screen Size

Uses `MediaQuery.sizeOf` internally — more efficient than `MediaQuery.of`.

```dart
Do.width(context)                    // full screen width
Do.height(context)                   // full screen height
Do.widthPercent(context, 50)         // 50% of screen width
Do.heightPercent(context, 30)        // 30% of screen height
Do.isTablet(context)                 // width >= 600
Do.isDesktop(context)                // width >= 1200
Do.isLandscape(context)              // landscape orientation
```

---

## Full Example

```dart
import 'package:flutter/material.dart';
import 'package:do_it_kit/do_it_kit.dart';

class CounterService {
  final count = DoState(0);
  void increment() => count.set((n) => n + 1);
}

void main() {
  Do.put(CounterService());
  Do.api.baseUrl = 'https://api.example.com';

  DoRouter.define('/', ([_]) => const HomePage());
  DoRouter.define('/detail', ([args]) => DetailPage(args: args));

  runApp(
    DoThemeBuilder(
      builder: (mode) => MaterialApp(
        navigatorKey: DoRouter.key,
        onGenerateRoute: DoRouter.onGenerateRoute,
        theme: DoTheme.light,
        darkTheme: DoTheme.dark,
        themeMode: mode,
        initialRoute: '/',
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = Do.find<CounterService>();
    return Scaffold(
      appBar: AppBar(
        title: Text('${Do.width(context).toStringAsFixed(0)}px wide'),
        actions: [
          IconButton(icon: const Icon(Icons.brightness_6), onPressed: Do.toggleTheme),
        ],
      ),
      body: Center(
        // only this Text rebuilds on count change
        child: Do(counter.count, (v) => Text('$v', style: const TextStyle(fontSize: 48))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: counter.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

## Additional Information

- Issues & PRs: [github.com/your-username/do_it_kit](https://github.com/your-username/do_it_kit)
- Contributions welcome
