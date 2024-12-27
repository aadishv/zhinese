//
//  TermSetView.swift
//  zhinese
//
//  Created by Aadish Verma on 12/26/24.
//
import Foundation
import SwiftUI

extension Term: View {
    public var body: some View {
        HStack {
            Text(character)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(try! pinyin.render())
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(english)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }.padding(4).font(.largeTitle)
    }
}
struct HomeView: View {
    @Binding var set: TermSet
    var body: some View {
        
        VStack {
            ForEach(set.indices, id: \.self) { i in
                set[i]
            }
        }
    }
}
private struct PreviewView: View {
    @State var set: TermSet = [Term(english: "you", pinyin: Pinyin("ni3"), character: "你")]
    var body: some View {
        HomeView(set: $set)
    }
}
#Preview {
    PreviewView()
}
