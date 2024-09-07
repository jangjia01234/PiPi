//
//  HostInformationSectionView.swift
//  PiPi
//
//  Created by 정상윤 on 8/8/24.
//

import SwiftUI

struct HostInformationSectionView: View {
    
    let host: User
    
    var body: some View {
        Section {
            row(title: "주최자") {
                Text(host.nickname)
            }
        }
        .listRowBackground(Color(.secondarySystemBackground))
    }
    
    private func row(title: String, content: () -> some View) -> some View {
        HStack {
            Text(title)
                .frame(width: 130, alignment: .leading)
            content()
        }
    }
    
}
