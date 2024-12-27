//
//  ShortcutButton.swift
//  zhinese
//
//  Created by Aadish Verma on 12/24/24.
//
import SwiftUI

struct ShortcutButton: View {
    let action: () -> Void
    let shortcut: KeyboardShortcut
    let label: String
    init(_ label: String, shortcut: KeyboardShortcut, action: @escaping () -> Void) {
        self.action = action
        self.shortcut = shortcut
        self.label = label
    }
    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                Spacer()
                Shortcut(shortcut: shortcut)
            }
        }.keyboardShortcut(shortcut)
    }
}

#Preview {
    // test case: command + shift + a
    ShortcutButton("My button :queens:", shortcut: KeyboardShortcut("A", modifiers: [.command, .option, .shift])) {
        print("pressed")
    }
}
