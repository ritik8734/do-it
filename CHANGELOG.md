## 0.1.0

* Added `Do.put` / `Do.find` — dependency injection.
* Added `DoRouter` — named route management, no context needed.
* Added `DoTheme` / `DoThemeBuilder` — reactive theme switching.
* Added `DoApi` — Dio-based HTTP client with `DoResult<T>` (DoSuccess / DoError).
* `Do(state, builder)` — reactive widget, only wrapped part rebuilds.
* `Do.push` / `Do.pop` / `Do.to` / `Do.back` — navigation.
* `Do.width` / `Do.height` / `Do.widthPercent` — screen size.
