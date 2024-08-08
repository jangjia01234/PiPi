//
//  ActivityDetailHeader.swift
//  PiPi
//
//  Created by 정상윤 on 8/8/24.
//

import SwiftUI

struct ActivityDetailHeaderView: View {
    
    @Binding var activity: Activity?
    
    var body: some View {
        if let activity {
            VStack {
                HStack {
                    Text(activity.title)
                        .font(.title)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(activity.status.rawValue)
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundColor(
                            activity.status == .open ? .accent : .red
                        )
                }
                Text(activity.description)
                    .font(.callout)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

//#Preview {
//    ActivityDetailHeaderView(
//        title: .constant("제목"),
//        description: .constant("설명"),
//        status: .constant(.open)
//    )
//}
