//
//  TermSetView.swift
//  zhinese
//
//  Created by Aadish Verma on 12/26/24.
//
import Foundation
import SwiftUI
import SwiftData

struct HomeView: View {
//    @Query var set: TermSet
    let set: TermSet = [Term(english: "you", pinyin: Pinyin("ni3"), character: "你")]
    
    @Environment(\.modelContext) private var context
    
    @State private var selected: Term? = nil
    var body: some View {
        
        VStack {
            List(set, id: \.self, selection: $selected) { i in
                HStack {
                    Text(i.character)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(try! i.pinyin.render())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(i.english)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }
                .padding(4)
                .font(.headline)
                .contextMenu {
                    Button("Edit") {
                        print("Test")
                    }.keyboardShortcut(KeyboardShortcut(.return, modifiers: [.command, .shift]))
                }
            }
        }.onAppear {
            context.insert(
                Term(
                    english: "you",
                    pinyin: Pinyin("ni3"),
                    character: "你")
            )
            
            print(set)
        }
    }
}
private struct PreviewView: View {
    @State var set: TermSet = .init([Term(english: "you", pinyin: Pinyin("ni3"), character: "你")])
    var body: some View {
        HomeView()
    }
}
#Preview {
    PreviewView()
}
