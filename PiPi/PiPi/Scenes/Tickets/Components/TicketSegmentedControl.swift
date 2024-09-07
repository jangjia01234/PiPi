//
//  TicketSegmentedControl.swift
//  PiPi
//
//  Created by Jia Jang on 7/31/24.
//

import SwiftUI

struct TicketSegmentedControl: View {
    @Binding var selectedItem: TicketType
    
    var body: some View {
        VStack {
            HStack {
                ForEach(TicketType.allCases, id: \.self) { item in
                    SegmentedControlItem(
                        item: item,
                        isSelected: selectedItem == item,
                        action: { self.selectedItem = item }
                    )
                }
            }
            .padding(.top, 25)
            
            Divider()
        }
        .navigationTitle("내 예약")
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct SegmentedControlItem: View {
    let item: TicketType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack {
            Text(item.rawValue)
                .frame(maxWidth: .infinity / 4, minHeight: 25)
                .foregroundColor(isSelected ? .black : .gray)
                .fontWeight(isSelected ? .semibold : .regular)
            
            if isSelected {
                Rectangle()
                    .foregroundColor(.black)
                    .frame(width: 84, height: 3)
            }
        }
        .onTapGesture { action() }
    }
}
