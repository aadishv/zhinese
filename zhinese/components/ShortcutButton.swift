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
        Button(action: action) {
            buttonContent
        }
        .simultaneousGesture(
            TapGesture()
                .onEnded({ _ in
                    pressed = 1
                })
        )
        .buttonStyle(.borderless)
        .keyboardShortcut(shortcut)
        .frame(height: 200)
        
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
            withAnimation(.easeInOut(duration: 0.25)) {
                self.hovering = hovering
            }
        }
    }
    private var bottomColor: Color {
        return buttonPrimary.mix(with: Color.black, by: 0.3)
    }
    private var buttonBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(bottomColor)
                .offset(y: 3)

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(bottomColor)
                RoundedRectangle(cornerRadius: 8)
                    .fill(self.buttonPrimary.opacity(hovering ? 0.5 : 0.8))
            }
            .offset(y: pressed > 0 ? 5 : 0)
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
