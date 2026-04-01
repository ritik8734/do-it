import 'package:flutter/material.dart';
import 'package:do_it_kit/do_it_kit.dart';

// ─── Services (registered via DI) ────────────────────────────────────────────

class CounterService {
  final count = DoState(0);
  void increment() => count.set((n) => n + 1);
  void decrement() => count.set((n) => n - 1);
}

class UserService {
  final userName = DoState('World');
}

// ─── App setup ────────────────────────────────────────────────────────────────

void main() {
  // DI — register services once
  Do.put(CounterService());
  Do.put(UserService());

  // API — configure once
  Do.api.baseUrl = 'https://jsonplaceholder.typicode.com';

  // Named routes
  DoRouter.define('/', ([_]) => const HomePage());
  DoRouter.define('/detail', ([args]) => DetailPage(args: args));
  DoRouter.define('/api-demo', ([_]) => const ApiDemoPage());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // DoThemeBuilder rebuilds MaterialApp when theme changes
    return DoThemeBuilder(
      builder: (themeMode) => MaterialApp(
        title: 'do_it_kit example',
        navigatorKey: DoRouter.key, // required for Do.to / Do.back
        onGenerateRoute: DoRouter.onGenerateRoute,
        theme: DoTheme.light,
        darkTheme: DoTheme.dark,
        themeMode: themeMode,
        initialRoute: '/',
      ),
    );
  }
}

// ─── Home Page ────────────────────────────────────────────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = Do.find<CounterService>();
    final user = Do.find<UserService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('do_it_kit'),
        actions: const [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: Do.toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Screen size
            Text(
              'Screen: ${Do.width(context).toStringAsFixed(0)} × '
              '${Do.height(context).toStringAsFixed(0)}  '
              '${Do.isTablet(context) ? '(tablet)' : '(phone)'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),

            // Reactive counter — only this Text rebuilds
            Do(
                counter.count,
                (v) => Text(
                      'Count: $v',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    )),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                    onPressed: counter.decrement, child: const Text('-')),
                const SizedBox(width: 16),
                FilledButton(
                    onPressed: counter.increment, child: const Text('+')),
              ],
            ),
            const Divider(height: 40),

            // Reactive greeting — only this Text rebuilds
            Do(
                user.userName,
                (name) => Text(
                      'Hello, $name!',
                      textAlign: TextAlign.center,
                    )),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => user.userName.value = 'do_it_kit',
              child: const Text('Change name'),
            ),
            const Divider(height: 40),

            // Named route navigation — no context needed
            FilledButton(
              onPressed: () => Do.to('/detail', args: {'id': 42}),
              child: const Text('Go to Detail (named route)'),
            ),
            const SizedBox(height: 8),

            // Context navigation
            FilledButton.tonal(
              onPressed: () => Do.push(context, () => const ApiDemoPage()),
              child: const Text('API Demo (context push)'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Detail Page ──────────────────────────────────────────────────────────────

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, this.args});
  final Object? args;

  @override
  Widget build(BuildContext context) {
    final map = args as Map?;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Received id: ${map?['id']}'),
            const SizedBox(height: 24),
            const FilledButton(
              onPressed: Do.back,
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── API Demo Page ────────────────────────────────────────────────────────────

class ApiDemoPage extends StatelessWidget {
  const ApiDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final result = DoState<String>('Press the button');

    return Scaffold(
      appBar: AppBar(title: const Text('API Demo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Do(result, (v) => Text(v, textAlign: TextAlign.center)),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  result.value = 'Loading...';
                  final res = await Do.api.get<Map<String, dynamic>>(
                    '/todos/1',
                    fromJson: (d) => Map<String, dynamic>.from(d as Map),
                  );
                  switch (res) {
                    case DoSuccess(:final data):
                      result.value = 'Title: ${data['title']}';
                    case DoError(:final message):
                      result.value = 'Error: $message';
                  }
                },
                child: const Text('Fetch /todos/1'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
