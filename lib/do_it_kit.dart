/// do_it_kit — everything on one class: Do
///
/// - Do(state, builder)          reactive widget
/// - Do.put / Do.find            dependency injection
/// - Do.to / Do.back             named route navigation (no context)
/// - Do.push / Do.pop            context navigation
/// - Do.toggleTheme()            theme manager
/// - Do.api.get/post/put/delete  HTTP client
/// - Do.width / Do.height        screen size
library do_it_kit;

export 'src/reactive_state.dart';
export 'src/do.dart';
