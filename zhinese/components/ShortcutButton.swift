//
//  ShortcutButton.swift
//  zhinese
//
//  Created by Aadish Verma on 12/24/24.
//
import SwiftUI

struct ShortcutButton<T: View>: View {
    private let action: () -> Void
    private let shortcut: KeyboardShortcut
    private var label: () -> T
    private let showingShortcut: Bool
    private let buttonPrimary: Color
    
    @State private var hovering = false
    @State private var pressed = 0

    init(
        shortcut: KeyboardShortcut,
        showingShortcut: Bool = true,
        buttonColor: Color = Colors.buttonPrimary.zhineseColor,
        action: @escaping () -> Void,
        @ViewBuilder view: @escaping () -> T
    ) {
        self.action = action
        self.shortcut = shortcut
        self.label = view
        self.showingShortcut = showingShortcut
        self.buttonPrimary = buttonColor
    }

    var body: some View {
        Button(action: handleButtonPress) {
            buttonContent
        }
        .buttonStyle(.borderless)
        .keyboardShortcut(shortcut)
    }

    private var buttonContent: some View {
        HStack {
            label()
            if showingShortcut {
                Shortcut(shortcut: shortcut)
            }
        }
        .offset(y: pressed > 0 ? 5 : 0)
        .font(.headline)
        .foregroundStyle(Color.white)
        .padding()
        .background {
            buttonBackground
        }
        .onHover { hovering in
            withAnimation {
                self.hovering = hovering
            }
        }
    }

    private var buttonBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray)
                .offset(y: 3)

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 3)
                RoundedRectangle(cornerRadius: 8)
                    .fill(self.buttonPrimary.opacity(hovering ? 0.6 : 0.8))
            }
            .offset(y: pressed > 0 ? 5 : 0)
        }
    }

    private func handleButtonPress() {
        action()
        withAnimation {
            pressed += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                pressed -= 1
            }
        }
    }
}

extension ShortcutButton<Text> {
    init(
        _ label: String,
        shortcut: KeyboardShortcut,
        showingShortcut: Bool = true,
        buttonColor: Color = Colors.buttonPrimary.zhineseColor,
        action: @escaping () -> Void
    ) {
        self.action = action
        self.shortcut = shortcut
        self.label = {
            Text(label)
        }
        self.showingShortcut = showingShortcut
        self.buttonPrimary = buttonColor
    }
}

#Preview {
    // test case: command + shift + a
    ShortcutButton(
        "My button :queens:", shortcut: KeyboardShortcut("Z", modifiers: [.command, .option])
    ) {
        print("pressed")
    }.padding()
}
