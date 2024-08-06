//
//  TicketProfileButtonView.swift
//  PiPi
//
//  Created by 정상윤 on 7/30/24.
//

import SwiftUI

struct TicketProfileButtonView: View {
    @State var isShowingSheet: Bool = false
    
    var body: some View {
        HStack {
            NavigationLink {
                TicketsView(isShowingSheet: $isShowingSheet)
            } label: {
                Image(systemName: "ticket.fill")
                    .setAppearance()
            }
            .setAppearance()
            
            Spacer()
            
            NavigationLink {
                ProfileView()
                // TODO: 프로필 뷰 추가
            } label: {
                Image(systemName: "person.fill")
                    .setAppearance()
            }
            .setAppearance()
        }
    }

}

fileprivate extension NavigationLink {
    
    func setAppearance() -> some View {
        self
            .frame(width: 36, height: 36)
            .background(Color(uiColor: .systemGray2))
            .foregroundStyle(.white)
            .clipShape(Circle())
            .setShadow()
    }
    
}

fileprivate extension Image {
    
    func setAppearance() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
    }
    
}

#Preview {
    TicketProfileButtonView()
}
