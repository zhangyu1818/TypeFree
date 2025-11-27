import KeyboardShortcuts
import SwiftData
import SwiftUI

struct KeyboardShortcutsListView: View {
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @ObservedObject private var shortcutSettings = EnhancementShortcutSettings.shared
    @State private var customCancelShortcut: KeyboardShortcuts.Shortcut?
    @State private var pasteOriginalShortcut: KeyboardShortcuts.Shortcut?
    @State private var pasteEnhancedShortcut: KeyboardShortcuts.Shortcut?
    @State private var retryShortcut: KeyboardShortcuts.Shortcut?
    @State private var toggleHotkey1: KeyboardShortcuts.Shortcut?
    @State private var toggleHotkey2: KeyboardShortcuts.Shortcut?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 6) {
                Text("Keyboard Shortcuts")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                Text("Quick reference for all TypeFree shortcuts")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
            .background(
                Rectangle()
                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
            )

            Divider()
                .overlay(Color(NSColor.separatorColor).opacity(0.5))

            // Content
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 14),
                    GridItem(.flexible(), spacing: 14),
                ], spacing: 14) {
                    // Recording Hotkeys
                    if hotkeyManager.selectedHotkey1 != .none {
                        ShortcutCard(
                            icon: "mic.fill",
                            iconColor: .blue,
                            title: "Toggle Recording",
                            subtitle: "Hotkey 1"
                        ) {
                            if hotkeyManager.selectedHotkey1 == .custom, let shortcut = toggleHotkey1 {
                                KeyboardShortcutBadge(shortcut: shortcut)
                            } else {
                                HotkeyBadge(text: hotkeyManager.selectedHotkey1.displayName)
                            }
                        }
                    }

                    if hotkeyManager.selectedHotkey2 != .none {
                        ShortcutCard(
                            icon: "mic.fill",
                            iconColor: .purple,
                            title: "Toggle Recording",
                            subtitle: "Hotkey 2"
                        ) {
                            if hotkeyManager.selectedHotkey2 == .custom, let shortcut = toggleHotkey2 {
                                KeyboardShortcutBadge(shortcut: shortcut)
                            } else {
                                HotkeyBadge(text: hotkeyManager.selectedHotkey2.displayName)
                            }
                        }
                    }



                    // Transcription Actions
                    ShortcutCard(
                        icon: "doc.text.fill",
                        iconColor: .orange,
                        title: "Paste Last Transcription (Orig.)",
                        subtitle: "Paste most recent original transcription"
                    ) {
                        if let shortcut = pasteOriginalShortcut {
                            KeyboardShortcutBadge(shortcut: shortcut)
                        } else {
                            NotSetBadge()
                        }
                    }

                    ShortcutCard(
                        icon: "wand.and.stars",
                        iconColor: .pink,
                        title: "Paste Last Transcription (Enh.)",
                        subtitle: "Paste enhanced or original if unavailable"
                    ) {
                        if let shortcut = pasteEnhancedShortcut {
                            KeyboardShortcutBadge(shortcut: shortcut)
                        } else {
                            NotSetBadge()
                        }
                    }

                    ShortcutCard(
                        icon: "arrow.clockwise",
                        iconColor: .blue,
                        title: "Retry Last Transcription",
                        subtitle: "Redo the last transcription"
                    ) {
                        if let shortcut = retryShortcut {
                            KeyboardShortcutBadge(shortcut: shortcut)
                        } else {
                            NotSetBadge()
                        }
                    }

                    // Recording Session Shortcuts
                    ShortcutCard(
                        icon: "escape",
                        iconColor: .red,
                        title: "Dismiss Recorder",
                        subtitle: customCancelShortcut != nil ? "Custom shortcut or default: Double ESC" : "Default: Double ESC"
                    ) {
                        if let cancelShortcut = customCancelShortcut {
                            KeyboardShortcutBadge(shortcut: cancelShortcut)
                        } else {
                            StaticKeysBadge(keys: ["⎋", "⎋"])
                        }
                    }

                    ShortcutCard(
                        icon: "wand.and.stars",
                        iconColor: .purple,
                        title: "Toggle Enhancement",
                        subtitle: shortcutSettings.isToggleEnhancementShortcutEnabled ? "Enable/disable AI enhancement" : "Disabled in settings"
                    ) {
                        StaticKeysBadge(keys: ["⌘", "E"], isEnabled: shortcutSettings.isToggleEnhancementShortcutEnabled)
                    }

                    ShortcutCard(
                        icon: "wand.and.stars",
                        iconColor: .orange,
                        title: "Switch Enhancement Prompt",
                        subtitle: "Use ⌘1–⌘0 (Command)"
                    ) {
                        StaticKeysBadge(keys: ["⌘", "1–0"])
                    }

                    ShortcutCard(
                        icon: "sparkles.square.fill.on.square",
                        iconColor: Color(red: 1.0, green: 0.8, blue: 0.0),
                        title: "Switch Power Mode",
                        subtitle: "Use ⌥1–⌥0 (Option)"
                    ) {
                        StaticKeysBadge(keys: ["⌥", "1–0"])
                    }
                }
                .padding(.horizontal, 26)
                .padding(.vertical, 26)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(NSColor.windowBackgroundColor),
                        Color(NSColor.controlBackgroundColor).opacity(0.3),
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(width: 820, height: 600)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onAppear {
            loadShortcuts()
        }
        .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
            // Poll for shortcut changes every 0.5 seconds
            loadShortcuts()
        }
    }

    private func loadShortcuts() {
        customCancelShortcut = KeyboardShortcuts.getShortcut(for: .cancelRecorder)
        pasteOriginalShortcut = KeyboardShortcuts.getShortcut(for: .pasteLastTranscription)
        pasteEnhancedShortcut = KeyboardShortcuts.getShortcut(for: .pasteLastEnhancement)
        retryShortcut = KeyboardShortcuts.getShortcut(for: .retryLastTranscription)
        toggleHotkey1 = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder)
        toggleHotkey2 = KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder2)
    }
}

// MARK: - Shortcut Card

private struct ShortcutCard<Content: View>: View {
    let title: String
    let subtitle: String
    let shortcutView: Content

    init(icon _: String = "", iconColor _: Color = .clear, title: String, subtitle: String, @ViewBuilder shortcutView: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.shortcutView = shortcutView()
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary.opacity(0.8))
                    .lineLimit(1)
            }

            Spacer(minLength: 12)

            shortcutView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(NSColor.controlBackgroundColor).opacity(0.7),
                            Color(NSColor.controlBackgroundColor).opacity(0.5),
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(NSColor.separatorColor).opacity(0.5),
                            Color(NSColor.separatorColor).opacity(0.3),
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color(NSColor.shadowColor).opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Badge Components

private struct KeyboardShortcutBadge: View {
    let shortcut: KeyboardShortcuts.Shortcut

    var body: some View {
        HStack(spacing: 4) {
            ForEach(shortcutComponents, id: \.self) { component in
                KeyBadge(text: component)
            }
        }
    }

    private var shortcutComponents: [String] {
        var components: [String] = []
        if shortcut.modifiers.contains(.command) { components.append("⌘") }
        if shortcut.modifiers.contains(.option) { components.append("⌥") }
        if shortcut.modifiers.contains(.shift) { components.append("⇧") }
        if shortcut.modifiers.contains(.control) { components.append("⌃") }
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
        default: String(key.rawValue).uppercased()
        }
    }
}

private struct StaticKeysBadge: View {
    let keys: [String]
    var isEnabled: Bool = true

    var body: some View {
        HStack(spacing: 4) {
            ForEach(keys, id: \.self) { key in
                KeyBadge(text: key, isEnabled: isEnabled)
            }
        }
    }
}

private struct KeyBadge: View {
    let text: String
    var isEnabled: Bool = true

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundColor(isEnabled ? .primary : .secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(NSColor.controlBackgroundColor).opacity(isEnabled ? 0.9 : 0.6),
                                Color(NSColor.controlBackgroundColor).opacity(isEnabled ? 0.7 : 0.5),
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(
                        Color(NSColor.separatorColor).opacity(isEnabled ? 0.4 : 0.2),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color(NSColor.shadowColor).opacity(isEnabled ? 0.15 : 0.05), radius: 2, x: 0, y: 1)
            .opacity(isEnabled ? 1.0 : 0.6)
    }
}

private struct HotkeyBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(NSColor.controlBackgroundColor).opacity(0.9),
                                Color(NSColor.controlBackgroundColor).opacity(0.7),
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(Color(NSColor.separatorColor).opacity(0.4), lineWidth: 1)
            )
            .shadow(color: Color(NSColor.shadowColor).opacity(0.15), radius: 2, x: 0, y: 1)
    }
}



private struct NotSetBadge: View {
    var body: some View {
        Text("Not Set")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(Color(NSColor.separatorColor).opacity(0.25), lineWidth: 1)
            )
    }
}

#Preview {
    KeyboardShortcutsListView()
        .environmentObject(HotkeyManager(whisperState: WhisperState(modelContext: try! ModelContext(ModelContainer(for: Transcription.self)))))
}
