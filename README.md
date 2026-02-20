# SwiftUI for Terminal

Declarative terminal UI framework with **100% SwiftUI-matching API names**, powered by a vendored notcurses C library.

Write terminal interfaces using the same `View`, `@State`, `VStack`, `HStack`, `Text`, and `Button` patterns you already know from SwiftUI — no new API to learn.

```swift
struct ContentView: View {
    @State var count = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("SwiftUI for Terminal")
                .bold()
                .foregroundColor(.cyan)

            Text("Count: \(count)")
                .foregroundColor(.green)

            HStack(spacing: 2) {
                Button("Increment") { count += 1 }
                Button("Reset") { count = 0 }
            }

            Spacer(minLength: 1)

            Text("Press q or ESC to quit")
                .foregroundColor(.gray)
                .italic()
        }
        .padding(2)
    }
}
```

## Architecture

Three clean layers, zero external dependencies:

```
┌─────────────────────────────────────┐
│  TerminalUI                         │  SwiftUI-like declarative framework
│  View · @State · VStack · Text      │  37 Swift files
├─────────────────────────────────────┤
│  NotcursesSwift                     │  Safe Swift wrapper
│  Terminal · Plane · Input · Style   │  5 Swift files
├─────────────────────────────────────┤
│  Cnotcurses                         │  Vendored C terminal library
│  buffer · plane · terminal · input  │  POSIX terminal I/O
└─────────────────────────────────────┘
```

- **Cnotcurses** — Vendored C implementation for terminal rendering, UTF-8 output, keyboard input, and 24-bit RGB color
- **NotcursesSwift** — Type-safe Swift wrapper exposing `Terminal`, `Plane`, `Style`, and `InputEvent`
- **TerminalUI** — Declarative UI framework matching SwiftUI's protocols, property wrappers, and result builders

## Components

| Category | Components |
|---|---|
| **Views** | `Text`, `Button`, `Spacer`, `EmptyView` |
| **Layout** | `VStack`, `HStack`, `ZStack` with alignment and spacing |
| **State** | `@State`, `Binding`, `DynamicProperty` |
| **Modifiers** | `.foregroundColor()`, `.bold()`, `.italic()`, `.font()`, `.padding()`, `.frame()` |
| **Fonts** | `.largeTitle`, `.title`, `.headline`, `.body`, `.caption` — 11 styles matching SwiftUI |
| **Colors** | 17 named colors + RGB construction (24-bit) |
| **Composition** | `ViewBuilder`, `ViewModifier`, `AnyView`, `ConditionalContent` |

## Requirements

- Swift 5.9+
- macOS 14+
- POSIX-compatible terminal

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ShawnBaek/SwiftUI-for-Terminal.git", from: "1.0.0")
]
```

Then add `TerminalUI` to your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["TerminalUI"]
)
```

## Usage

### Basic App

```swift
import TerminalUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, Terminal!")
                .bold()
                .foregroundColor(.green)
        }
        .padding()
    }
}
```

### State Management

```swift
struct CounterView: View {
    @State var count = 0

    var body: some View {
        VStack(spacing: 1) {
            Text("Count: \(count)")
                .foregroundColor(.cyan)

            HStack(spacing: 2) {
                Button("+ Add") { count += 1 }
                Button("Reset") { count = 0 }
            }
        }
    }
}
```

State changes automatically trigger re-renders — identical to SwiftUI's behavior.

### Run the Example

```bash
swift run Example
```

Navigate with arrow keys, activate buttons with Enter, quit with `q` or `ESC`.

## Advanced Swift Features

This framework demonstrates several advanced Swift patterns:

- **Result Builders** — `@ViewBuilder` for declarative view composition
- **Property Wrappers** — `@State` with reference-boxed storage and projected `Binding` values
- **Mirror Reflection** — Dynamic view graph construction from generic view hierarchies
- **Protocol-Oriented Design** — `View`, `ViewModifier`, `DynamicProperty`, `Scene`, `App`
- **Type Erasure** — `AnyView` for heterogeneous view collections

## Testing

The framework includes comprehensive tests covering state management, layout, styling, view composition, and the rendering pipeline:

```bash
swift test
```

## License

MIT

## Author

Shawn Baek — [GitHub](https://github.com/ShawnBaek) · [LinkedIn](https://www.linkedin.com/in/sungwookbaek/) · shawn@shawnbaek.com
