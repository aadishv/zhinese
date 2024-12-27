//
//  ContentView.swift
//  zhinese
//
//  Created by Aadish Verma on 12/24/24.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State var set: TermSet = [Term(english: "you", pinyin: Pinyin("ni3"), character: "你")]
    var body: some View {

        TermSetEditor(set: $set)
    }
}


