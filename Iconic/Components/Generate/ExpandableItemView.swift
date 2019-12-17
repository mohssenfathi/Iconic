//
//  GenerateHelpView.swift
//  Iconic
//
//  Created by Mohssen Fathi on 12/14/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import SwiftUI

protocol ExpandableItem {
    associatedtype V: View
    var title: String { get }
    var view: V { get }
}

typealias ExpandableItemType = ExpandableItem & Identifiable & Hashable

//protocol ExpandableItemViewDelegate {
//    associatedtype I: ExpandableItemType
//    func numberOfSections(for view: ExpandableItemView<I>) -> Int
//    func numberOfitems(for view: ExpandableItemView<I>, in section: Int) -> Int
//    func item(view: ExpandableItemView<I>, at indexPath: IndexPath) -> I
//    func isItemExpanded(view: ExpandableItemView<I>, at indexPath: IndexPath) -> Bool
//}

struct ExpandableItemView<I: ExpandableItemType>: View {
    
    let items: OrderedDictionary<String, [I]>
    @State var expanded: Set<I> = []
    
//    init(items: [String: [I]]) {
//        self.items = OrderedDictionary<String, [I]>(items)
//    }
    
    init(items: OrderedDictionary<String, [I]>) {
        self.items = items
    }
    
    var body: some View {
        List {
            ForEach(items.orderedKeys, id: \.self) { header in
                Section(header: Text(header)) {
                    ForEach(self.items[header] ?? []) { item in
                    
                        Button(action: {
                            self.toggle(item: item)
                        }, label: {
                            HStack {
                                Text(item.title)
                                    .foregroundColor(.primary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .rotationEffect(.degrees(self.isExpanded(item) ? 90 : 0))
                                    .foregroundColor(.primary)
                                    .animation(.easeInOut(duration: 0.25))
                            }
                            .padding()
                        })

                        if self.isExpanded(item) {
                            item.view
                                .padding()
                                .background(Color(UIColor.tertiarySystemGroupedBackground).opacity(0.5))
                                .cornerRadius(8.0)
                        }
                        
//                        ExpandableItemRow(item: item)
                        
                    }
                    
                }
            }
        }
        .listStyle(GroupedListStyle())
        .onAppear {
            UITableView.appearance().separatorStyle = .singleLine
            UITableViewCell.appearance().backgroundColor = UIColor.systemBackground
            UITableViewCell.appearance().selectionStyle = .default
        }
    }
    
    private func isExpanded(_ item: I) -> Bool {
        return expanded.contains(item)
    }
    
    private func toggle(item: I) {
        if expanded.contains(item) {
            expanded.remove(item)
        } else {
            expanded.insert(item)
        }
    }
}

struct ExpandableItemRow<I: ExpandableItem>: View {
    @State var isExpanded: Bool = false
    let item: I
    
    init(item: I) {
        self.item = item
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: {
                self.isExpanded.toggle()
            }, label: {
                HStack {
                    Text(item.title)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundColor(.primary)
                }
                .animation(nil)
            })
            
            if isExpanded {
                Divider()
                item.view
            }
        }
        .padding()
    }
}

struct GenerateHelpView_Previews: PreviewProvider {
    static var previews: some View {
        return GenerateHelpView()
    }
}
