//
//  ConvenienceGrid.swift
//  Yurtify
//
//  Created by dark type on 23.06.2025.
//

import SwiftUI

struct ConvenienceGrid: View {
    // MARK: - Properties

    let conveniences: [Convenience]
    let columns: Int = 4
    let spacing: CGFloat = 12
    let isSelectable: Bool
    
    @Binding var selectedConveniences: Set<Convenience>
    
    init(conveniences: [Convenience]) {
        self.conveniences = conveniences
        self.isSelectable = false
        self._selectedConveniences = .constant([])
    }
    
    init(conveniences: [Convenience], selectedConveniences: Binding<Set<Convenience>>) {
        self.conveniences = conveniences
        self.isSelectable = true
        self._selectedConveniences = selectedConveniences
    }
    
    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - (spacing * CGFloat(columns - 1)) - (spacing * 2)
            let itemWidth = max(availableWidth / CGFloat(columns), 0)
            let itemHeight = itemWidth * 1.3
            
            let fixedItemWidth = floor(itemWidth)
            let fixedItemHeight = floor(itemHeight)
            
            let totalContentWidth = (fixedItemWidth * CGFloat(columns)) + (spacing * CGFloat(columns - 1))
            let horizontalPadding = (geometry.size.width - totalContentWidth) / 2
            
            ScrollView {
                VStack(spacing: spacing) {
                    ForEach(0..<(conveniences.count + columns - 1) / columns, id: \.self) { rowIndex in
                        HStack(spacing: spacing) {
                            ForEach(0..<columns, id: \.self) { columnIndex in
                                let itemIndex = rowIndex * columns + columnIndex
                                if itemIndex < conveniences.count {
                                    let convenience = conveniences[itemIndex]
                                    
                                    if isSelectable {
                                        ConvenienceView(
                                            convenience: convenience,
                                            width: fixedItemWidth - 24,
                                            height: fixedItemHeight - 24,
                                            isSelected: Binding(
                                                get: { selectedConveniences.contains(convenience) },
                                                set: { isSelected in
                                                    if isSelected {
                                                        selectedConveniences.insert(convenience)
                                                    } else {
                                                        selectedConveniences.remove(convenience)
                                                    }
                                                }
                                            )
                                        )
                                    } else {
                                        ConvenienceView(
                                            convenience: convenience,
                                            width: fixedItemWidth - 24,
                                            height: fixedItemHeight - 24
                                        )
                                    }
                                } else {
                                    Color.clear
                                        .frame(width: fixedItemWidth, height: fixedItemHeight)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, spacing)
            }
        }
    }
}
#Preview {
    Group {
        VStack(spacing: 20) {
            ConvenienceView(
                convenience: .wifi,
                width: 80,
                height: 104
            )
            
            StateWrapper(initialState: false) { $isSelected in
                ConvenienceView(
                    convenience: .pool,
                    width: 80,
                    height: 104,
                    isSelected: $isSelected
                )
            }
            
            StateWrapper(initialState: true) { $isSelected in
                ConvenienceView(
                    convenience: .gym,
                    width: 80,
                    height: 104,
                    isSelected: $isSelected
                )
            }
        }
     
        .padding()
        
        StateWrapper(initialState: Set<Convenience>([.wifi, .pool])) { $selected in
            ConvenienceGrid(
                conveniences: Convenience.inGroup(.room),
                selectedConveniences: $selected
            )
            .frame(height: 400)
        }
      
        .padding()
        
     
    }
}

struct StateWrapper<Value, Content: View>: View {
    @State var value: Value
    let content: (Binding<Value>) -> Content
    
    init(initialState value: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: value)
        self.content = content
    }
    
    var body: some View {
        content($value)
    }
}
