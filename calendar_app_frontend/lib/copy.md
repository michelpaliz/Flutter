You’re hitting **“setState() called during build”** because one of your child widgets (the form/router) calls a method on your `BaseEventLogic` that internally calls `setState` **while the parent tree is still building**. In your flow this can happen in two places:

* `EventFormWorkVisit.initState` → `widget.logic.setEventType?.call('work_visit')` (the default impl in `BaseEventLogic` calls `setState` immediately)
* `EventFormRouter._setType` → `widget.logic.setEventType?.call(t)` during a build path

### Quick, safe fixes

#### 1) Make logic-side rebuilds “post-frame safe”

Add a tiny helper in `BaseEventLogic` that only calls `setState` **after** the current frame:

```dart
// in base_event_logic.dart
import 'dart:async';
import 'package:flutter/scheduler.dart';

// ...

void _safeRebuild() {
  if (!mounted) return;
  // If we're in the build/layout phase, defer to after the frame.
  final phase = SchedulerBinding.instance.schedulerPhase;
  if (phase == SchedulerPhase.idle || phase == SchedulerPhase.postFrameCallbacks) {
    setState(() {});
  } else {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }
}
```

Now update the default handlers you set up in `initState()`:

```dart
@override
void initState() {
  super.initState();
  initializeBaseDefaults();
  _attachFormListeners();

  setEventType ??= (t) {
    _eventType = (t.isEmpty ? 'work_visit' : t).toLowerCase();
    _safeRebuild();
    // If your validity depends on type, also defer validity:
    WidgetsBinding.instance.addPostFrameCallback((_) => recomputeValidity());
  };

  setClientId ??= (v) {
    _clientId = v;
    _safeRebuild();
    WidgetsBinding.instance.addPostFrameCallback((_) => recomputeValidity());
  };

  setPrimaryServiceId ??= (v) {
    _primaryServiceId = v;
    _safeRebuild();
    WidgetsBinding.instance.addPostFrameCallback((_) => recomputeValidity());
  };

  recomputeValidity();
}
```

*(This prevents `setState` from firing while the tree is building.)*

#### 2) Defer router/form-triggered logic calls to after frame

* In `EventFormWorkVisit.initState` wrap the call:

```dart
@override
void initState() {
  super.initState();
  // ... your existing init
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) widget.logic.setEventType?.call('work_visit');
  });
}
```

* In `EventFormRouter._setType`, defer the logic call too:

```dart
void _setType(String t) {
  setState(() => _type = t); // local UI can update immediately
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) widget.logic.setEventType?.call(t);
  });
}
```

This way the **UI updates** right away, but the **logic state** that triggers a rebuild happens after the current frame, avoiding the exception.

---

### Why this happens (super short)

Flutter doesn’t let you call `setState` on a widget while the framework is already in the middle of building that same subtree. Some of your form/router calls ended up triggering a `setState` on `AddEventScreen` (via logic) **during** the router’s build. Deferring those calls with `addPostFrameCallback` or making the logic’s rebuild “post-frame safe” fixes it.

---

### What to change (summary)

* Add `_safeRebuild()` to `BaseEventLogic` and use it in the default handlers (`setEventType`, `setClientId`, `setPrimaryServiceId`).
* Wrap `setEventType` calls in `EventFormWorkVisit.initState` and `EventFormRouter._setType` with `addPostFrameCallback`.

That’s it. After these changes, the error goes away and your UI still updates as expected.
