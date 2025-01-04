//
//  TermSetEditor.swift
//  zhinese
//
//  Created by Aadish Verma on 12/26/24.
//
import Foundation
import SwiftUI
import SwiftData
//
//struct TermSetEditor: View {
//    // MARK: - Properties
//    @Query var set: TermSet
//    @Environment(\.colorScheme) var colorScheme
//    @State private var showingAlert = false
//    @FocusState private var focusedElement: Optional<Int>
//    @State private var hoveredElement: Int? = nil
//    @State private var animatedElement: Int? = nil
//    @State private var currentPinyin = ""
//    @State private var prevState: Int? = nil
//
//    // MARK: - Initialization
//    init() {
//    }
//
//    // MARK: - Helper Methods
//    private func updatePinyinIfNeeded(at index: Int, with newPinyin: Pinyin) throws {
//        let _ = try newPinyin.render()
//        set.terms[Int(Float(index - 1) / 3.0)].pinyin = newPinyin
//    }
//
//    private func changeFocused(toState: Int?) {
//        let newPinyin = Pinyin(currentPinyin)
//
//        if let to = toState, to % 3 == 1 {
//            currentPinyin = set.terms[Int(floor(Float(to) / Float(3)))].pinyin.getNumberedString()
//        }
//
//        animatedElement = nil
//
//        if let val = prevState, val % 3 == 1 {
//            do {
//                try updatePinyinIfNeeded(at: val, with: newPinyin)
//            } catch {
//                showingAlert = true
//                focusedElement = prevState
//                return
//            }
//        }
//
//        prevState = focusedElement
//    }
//
//    // MARK: - View Components
//    private func editorBackground(isFocused: Bool) -> some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 7)
//                .stroke(isFocused ? Color.blue : Color.gray, lineWidth: 2)
//                .zIndex(2.0)
//
//            RoundedRectangle(cornerRadius: 7)
//                .fill(colorScheme == .dark ? Color(hex: 0x1E1E1E) : Color.white)
//                .zIndex(0.5)
//        }
//    }
//
//    private func characterEditor(term: Int) -> some View {
//        ZStack {
//            editorBackground(isFocused: focusedElement == term * 3)
//
//            TextField("Character", text: $set.terms[term].character)
//                .padding()
//                .zIndex(1.0)
//                .frame(maxWidth: .infinity)
//        }.focused($focusedElement, equals: Int?(term * 3))
//    }
//
//    private func pinyinEditor(term: Int) -> some View {
//        let focused = focusedElement == term * 3 + 1
//        return ZStack {
//            editorBackground(isFocused: focused)
//
//            TextField(
//                "Pinyin",
//                text: focused ? $currentPinyin : .constant(try! set.terms[term].pinyin.render())
//            )
//            .padding()
//            .zIndex(1.0)
//            .frame(maxWidth: .infinity)
//        }.focused($focusedElement, equals: Int?(term * 3 + 1))
//    }
//
//    private func englishEditor(term: Int) -> some View {
//        ZStack {
//            editorBackground(isFocused: focusedElement == term * 3 + 2)
//
//            TextField("English", text: $set.terms[term].english)
//                .padding()
//                .zIndex(1.0)
//                .frame(maxWidth: .infinity)
//        }.focused($focusedElement, equals: Int?(term * 3 + 2))
//    }
//    
//    private func deletionButton(term: Int) -> some View {
//        ShortcutButton(
//            shortcut: KeyboardShortcut(.delete, modifiers: [.command]),
//            showingShortcut: false,
//            buttonColor: Colors.deletionPrimary.zhineseColor,
//            action: {
//                focusedElement = nil
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    if set.terms.count == 1 {
//                        set.terms = [Term.empty]
//                    } else {
//                        if set.terms.indices.contains(term) {
//                            set.terms.remove(at: term)
//                        }
//                    }
//                }
//            }
//        ) {
//            Image(systemName: "trash")
//                .foregroundColor(.white)
//        }
//    }
//    // MARK: - Body
//    var body: some View {
//        VStack {
//            List {
//                ForEach(set.terms.indices, id: \.self) { term in
//                    HStack {
//                        let options = [term * 3, term * 3 + 1, term * 3 + 2]
//                        characterEditor(term: term)
//                            .onTapGesture {
//                                focusedElement = term * 3
//                            }
//                        pinyinEditor(term: term)
//                            .onTapGesture {
//                                focusedElement = term * 3 + 1
//                            }
//                        englishEditor(term: term)
//                            .onTapGesture {
//                                focusedElement = term * 3 + 2
//                            }
//                        if term == animatedElement || options.contains(focusedElement ?? -1) {
//                            deletionButton(term: term)
//                        }
//                    }.onHover { h in
//                        if h {
//                            hoveredElement = term
//                        } else {
//                            if hoveredElement == term {
//                                hoveredElement = nil
//                            }
//                        }
//
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                            if hoveredElement == term {
//                                withAnimation(.easeInOut(duration: 0.2)) {
//                                    animatedElement = term
//                                }
//                            } else if animatedElement == term {
//                                withAnimation(.easeInOut(duration: 0.2)) {
//                                    animatedElement = nil
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            .alert("Parsing error: invalid pinyin", isPresented: $showingAlert) {
//                Button("Okay", role: .cancel) {}
//            }
//            .onChange(of: focusedElement, initial: true) {
//                changeFocused(toState: focusedElement)
//            }
//
//            HStack {
//                ShortcutButton("New term", shortcut: KeyboardShortcut(.return, modifiers: [])) {
//                    set.terms.append(Term.empty)
//                    focusedElement = (set.terms.count - 1) * 3
//                    changeFocused(toState: focusedElement)
//                }
//                Spacer()
//                Text("Use tab, shift+tab, up arrow, and down arrow keys to navigate")
//            }.padding()
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
