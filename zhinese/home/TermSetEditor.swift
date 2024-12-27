//
//  TermSetEditor.swift
//  zhinese
//
//  Created by Aadish Verma on 12/26/24.
//
import Foundation
import SwiftUI

struct TermSetEditor: View {
    @Binding var set: TermSet
    
    @State var showingAlert = false
    
    @FocusState var focusedElement: Optional<Int>
    init(set: Binding<TermSet>) {
        self._set = set
    }
    
    @State var currentPinyin = ""
    
    @State var prevState: Optional<Int> = nil
    func changeFocused(toState: Int?) {
        if let val = prevState { // handle updating pinyin
            let val = prevState!
            if val % 3 == 1 { // need to calc pinyin
                let newPinyin = Pinyin(currentPinyin)
                do {
                    let _ = try newPinyin.render()
                }
                catch {
                    showingAlert = true
                    focusedElement = prevState
                    return
                }
                set[Int(Float(val-1)/3.0)].pinyin = newPinyin
            }
        }
        
        if let to = toState {
            print("focused changed")
            // focusedElement is already to haha
            if to % 3 == 1 {
                currentPinyin = set[Int(floor(Float(to)/Float(3)))].pinyin.getNumberedString()
            }
        }
        prevState = focusedElement
    }
    func characterEditor(term: Int) -> some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 7)
                .stroke(
                    focusedElement == term*3 ?
                    Color.blue : Color.gray,
                lineWidth: 4)
                .zIndex(2.0)
            
            TextField("Character", text: $set[term].character)
                .padding(5)
                .zIndex(1.0)
                .frame(maxWidth: .infinity)
        }.focused($focusedElement, equals: Int?(term*3))
    }
    func pinyinEditor(term: Int) -> some View {
        ZStack {
            let focused = focusedElement == term*3 + 1
            
            RoundedRectangle(cornerRadius: 7)
                .stroke(
                    focusedElement == term*3 + 1 ?
                    Color.blue : Color.gray,
                lineWidth: 4)
                .zIndex(2.0)
            
            TextField("Pinyin", text:
                        focused ? $currentPinyin : .constant(try! set[term].pinyin.render())
            ).padding(5)
            .zIndex(1.0)
            .frame(maxWidth: .infinity)
        }.focused($focusedElement, equals: Int?(term*3 + 1))
    }
    func englishEditor(term: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .stroke(
                    focusedElement == term*3+2 ?
                    Color.blue : Color.gray,
                lineWidth: 4)
                .zIndex(2.0)
            
            TextField("English", text: $set[term].english)
                .padding(5)
                .zIndex(1.0)
                .frame(maxWidth: .infinity)
        }.focused($focusedElement, equals: Int?(term*3+2))
    }
    var body: some View {
        List {
            // guide
            // prefixing editing term
            ForEach(set.indices, id: \.self) { term in
                HStack {
                    characterEditor(term: term)
                        .focusSection()
                        .onTapGesture {
                            focusedElement = term*3
                        }
                    pinyinEditor(term: term)
                        .focusSection()
                        .onTapGesture {
                            focusedElement = term*3 + 1
                        }
                    englishEditor(term: term)
                        .focusSection()
                        .onTapGesture {
                            focusedElement = term*3 + 2
                        }

                }
            }
            HStack {
                ShortcutButton("Add term", shortcut: KeyboardShortcut(.return, modifiers: [])) {
                    set.append(Term.empty)
                    focusedElement = (set.count-1)*3
                    
                    changeFocused(toState: focusedElement)
                }
                ShortcutButton("Cycle properties", shortcut: KeyboardShortcut(.tab, modifiers: [])) {
                    if let f = focusedElement {
                        focusedElement = f + 1
                        if f > set.count*3 {
                            set.append(Term.empty)
                        }
                    }
                    
                }
            }
        }
        .alert("Parsing error: invalid pinyin", isPresented: $showingAlert) {
            Button("Okay", role: .cancel) { }
        }
        .onChange(of: focusedElement, initial: true) {
            changeFocused(toState: focusedElement)
        }
    }
}
#Preview {
    ContentView()
}
