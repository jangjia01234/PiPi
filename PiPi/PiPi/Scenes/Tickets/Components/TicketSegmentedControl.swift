//
//  TicketSegmentedControl.swift
//  PiPi
//
//  Created by Jia Jang on 7/31/24.
//

import SwiftUI

struct TicketSegmentedControl: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedItem: TicketType
    
    var body: some View {
        ZStack {
            HStack {
                ForEach(TicketType.allCases, id: \.self) { item in
                    VStack {
                        Text(item.rawValue)
                            .frame(maxWidth: .infinity/4, minHeight: 25)
                            .foregroundColor(selectedItem == item ? .black : .gray)
                            .fontWeight(selectedItem == item ? .semibold : .regular)
                        
                        if selectedItem == item {
                            Rectangle()
                                .foregroundColor(.black)
                                .frame(width: 84, height: 3)
                        }
                    }
                    .onTapGesture {
                        self.selectedItem = item
                    }
                }
            }
            
            Divider()
                .padding(.top, 35)
        }
        .navigationTitle("내 티켓")
        .navigationBarTitleDisplayMode(.large)
        .padding(.top, 25)
        .padding(.bottom, 20)
    }
}

#Preview {
    TicketSegmentedControl(selectedItem: .constant(.participant))
}
