import KeyboardShortcuts
import SwiftUI

struct KeyboardShortcutView: View {
    let shortcut: KeyboardShortcuts.Shortcut?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if let shortcut {
            HStack(spacing: 6) {
                ForEach(shortcutComponents(from: shortcut), id: \.self) { component in
                    KeyCapView(text: component)
                }
            }
        } else {
            KeyCapView(text: "Not Set")
                .foregroundColor(.secondary)
        }
    }

    private func shortcutComponents(from shortcut: KeyboardShortcuts.Shortcut) -> [String] {
        var components: [String] = []

        // Add modifiers
        if shortcut.modifiers.contains(.command) { components.append("⌘") }
        if shortcut.modifiers.contains(.option) { components.append("⌥") }
        if shortcut.modifiers.contains(.shift) { components.append("⇧") }
        if shortcut.modifiers.contains(.control) { components.append("⌃") }

        // Add key
        if let key = shortcut.key {
            components.append(keyToString(key))
        }

        return components
    }

    private func keyToString(_ key: KeyboardShortcuts.Key) -> String {
        switch key {
        case .space: "Space"
        case .return: "↩"
        case .escape: "⎋"
        case .tab: "⇥"
        case .delete: "⌫"
        case .home: "↖"
        case .end: "↘"
        case .pageUp: "⇞"
        case .pageDown: "⇟"
        case .upArrow: "↑"
        case .downArrow: "↓"
        case .leftArrow: "←"
        case .rightArrow: "→"
        case .period: "."
        case .comma: ","
        case .semicolon: ";"
        case .quote: "'"
        case .slash: "/"
        case .backslash: "\\"
        case .minus: "-"
        case .equal: "="
        case .keypad0: "0"
        case .keypad1: "1"
        case .keypad2: "2"
        case .keypad3: "3"
        case .keypad4: "4"
        case .keypad5: "5"
        case .keypad6: "6"
        case .keypad7: "7"
        case .keypad8: "8"
        case .keypad9: "9"
        case .a: "A"
        case .b: "B"
        case .c: "C"
        case .d: "D"
        case .e: "E"
        case .f: "F"
        case .g: "G"
        case .h: "H"
        case .i: "I"
        case .j: "J"
        case .k: "K"
        case .l: "L"
        case .m: "M"
        case .n: "N"
        case .o: "O"
        case .p: "P"
        case .q: "Q"
        case .r: "R"
        case .s: "S"
        case .t: "T"
        case .u: "U"
        case .v: "V"
        case .w: "W"
        case .x: "X"
        case .y: "Y"
        case .z: "Z"
        case .zero: "0"
        case .one: "1"
        case .two: "2"
        case .three: "3"
        case .four: "4"
        case .five: "5"
        case .six: "6"
        case .seven: "7"
        case .eight: "8"
        case .nine: "9"
        default:
            String(key.rawValue).uppercased()
        }
    }
}

struct KeyCapView: View {
    let text: String
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false

    private var keyColor: Color {
        colorScheme == .dark ? Color(white: 0.2) : .white
    }

    private var surfaceGradient: LinearGradient {
        LinearGradient(
            colors: [
                keyColor,
                keyColor.opacity(0.2),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var highlightGradient: LinearGradient {
        LinearGradient(
            colors: [
                .white.opacity(colorScheme == .dark ? 0.15 : 0.5),
                .white.opacity(0.0),
            ],
            startPoint: .topLeading,
            endPoint: .center
        )
    }

    private var shadowColor: Color {
        colorScheme == .dark ? .black : .gray
    }

    var body: some View {
        Text(text)
            .font(.system(size: 25, weight: .semibold, design: .rounded))
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    // Main key surface
                    RoundedRectangle(cornerRadius: 8)
                        .fill(surfaceGradient)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(highlightGradient)
                        )

                    // Border
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(colorScheme == .dark ? 0.2 : 0.6),
                                    shadowColor.opacity(0.3),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            // Main shadow
            .shadow(
                color: shadowColor.opacity(0.3),
                radius: 3,
                x: 0,
                y: 2
            )
            // Bottom edge shadow
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                shadowColor.opacity(0.0),
                                shadowColor.opacity(0.9),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .offset(y: 1)
                    .blur(radius: 2)
                    .mask(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [.clear, .black],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .clipped()
            )
            // Inner shadow effect
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        Color.white.opacity(colorScheme == .dark ? 0.1 : 0.3),
                        lineWidth: 1
                    )
                    .blur(radius: 1)
                    .offset(x: -1, y: -1)
                    .mask(RoundedRectangle(cornerRadius: 8))
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
            .onTapGesture {
                withAnimation {
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressed = false
                    }
                }
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        KeyboardShortcutView(shortcut: KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder))
        KeyboardShortcutView(shortcut: nil)
    }
    .padding()
}
