//
//  Shortcut.swift
//  zhinese
//
//  Created by Aadish Verma on 12/24/24.
//
import SwiftUI

extension EventModifiers: @retroactive Hashable {
    public var id: String {
        return Shortcut.modifierMap[self] ?? ""
    }
}
struct Shortcut: View {
//    var shortcut: KeyboardSh
    static let modifierMap: [EventModifiers: String] = [
        .capsLock: "⇪",
        .command: "⌘",
        .control: "⌃",
        .numericPad: "🔢",
        .option: "⌥",
        .shift: "⇧"
    ]
    static let keyMap: [KeyEquivalent: String] = [
        .upArrow: "↑",
        .downArrow: "↓",
        .leftArrow: "←",
        .rightArrow: "→",
        .clear: "⌧",
        .delete: "⌫",
        .deleteForward: "⌦",
        .end: "↘",
        .escape: "⎋",
        .home: "↖",
        .pageDown: "⇟",
        .pageUp: "⇞",
        .return: "↩",
        .space: "␣",
        .tab: "⇥"
    ]
    let shortcut: KeyboardShortcut
    func generateLetters() -> [String] {
        let key = Self.keyMap[shortcut.key] ?? String(shortcut.key.character)
        let modifiers = Self.modifierMap.keys
            .sorted(by: { $0.rawValue > $1.rawValue }).map { $0 }
            .compactMap { key in
                shortcut.modifiers.contains(key) ? Self.modifierMap[key] ?? nil : nil
            }
        return modifiers + [key]
    }
    var body: some View {
        HStack {
            ForEach(generateLetters(), id: \.self) { letter in
                
                Text(letter).font(.headline).padding(5.0).background {
                    RoundedRectangle(cornerRadius: 5).fill(Color.accentColor)
                }
            }
        }.padding()
    }
}

#Preview {
    // test case: command + shift + a
    Shortcut(shortcut: KeyboardShortcut("A", modifiers: [.shift, .command, .option]))
}
