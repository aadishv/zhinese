//
//  playground.swift
//  zhinese
//
//  Created by Aadish Verma on 1/3/25.
//
import SwiftUI
import Foundation

struct TodoItem: Identifiable, Hashable {
    let id: UUID
    var title: String
}

//struct TodoList: View {
//    @State var items: [TodoItem] = [
//        TodoItem(id: UUID(), title: "1 item"),
//        TodoItem(id: UUID(), title: "2 item"),
//        TodoItem(id: UUID(), title: "3 item"),
//        TodoItem(id: UUID(), title: "4 item")
//    ]
//    @State private var selected: TodoItem?
//    var body: some View {
//        List($items, selection: $selected) { $item in
////            ForEach($items) { $item in
//                TextField("Title", text: $item.title)
////            }
//        }
//    }
//}

struct CView: View {
    @State private var items = ["Item 1", "Item 2", "Item 3"]
    @State private var selectedItem: String?

    var body: some View {
        NavigationView {
            List(selection: $selectedItem) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Selectable and Deletable List")
        }
    }

    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}

#Preview {
    CView()

}
