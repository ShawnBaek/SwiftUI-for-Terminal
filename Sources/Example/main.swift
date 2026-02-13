import TerminalUI
import NotcursesSwift
import Foundation

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

if CommandLine.arguments.contains("--preview") {
    // ASCII mockup showing what the rendered TUI looks like
    let esc = "\u{001B}"
    let reset = "\(esc)[0m"
    let bold = "\(esc)[1m"
    let italic = "\(esc)[3m"
    let cyan = "\(esc)[38;2;50;173;230m"
    let green = "\(esc)[38;2;52;199;89m"
    let gray = "\(esc)[38;2;142;142;147m"
    let border = "\(esc)[38;2;80;80;80m"
    let buttonColor = "\(esc)[38;2;50;173;230m"

    print(border + "┌──────────────────────────────────────────────┐" + reset)
    print(border + "│" + reset + "                                              " + border + "│" + reset)
    print(border + "│" + reset + "  " + cyan + bold + "SwiftUI for Terminal" + reset + "                        " + border + "│" + reset)
    print(border + "│" + reset + "                                              " + border + "│" + reset)
    print(border + "│" + reset + "  " + green + "Count: 0" + reset + "                                    " + border + "│" + reset)
    print(border + "│" + reset + "                                              " + border + "│" + reset)
    print(border + "│" + reset + "  " + buttonColor + bold + "[ Increment ]" + reset + "  " + buttonColor + bold + "[ Reset ]" + reset + "                  " + border + "│" + reset)
    print(border + "│" + reset + "                                              " + border + "│" + reset)
    print(border + "│" + reset + "                                              " + border + "│" + reset)
    print(border + "│" + reset + "                                              " + border + "│" + reset)
    print(border + "│" + reset + "                                              " + border + "│" + reset)
    print(border + "│" + reset + "                                              " + border + "│" + reset)
    print(border + "│" + reset + "  " + gray + italic + "Press q or ESC to quit" + reset + "                    " + border + "│" + reset)
    print(border + "│" + reset + "                                              " + border + "│" + reset)
    print(border + "└──────────────────────────────────────────────┘" + reset)
} else {
    let app = Application()
    do {
        try app.run(ContentView())
    } catch {
        print("Error: \(error)")
    }
}
