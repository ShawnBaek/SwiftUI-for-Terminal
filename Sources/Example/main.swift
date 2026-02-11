import TerminalUI

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

// Entry point
let app = Application()
do {
    try app.run(ContentView())
} catch {
    print("Error: \(error)")
}
