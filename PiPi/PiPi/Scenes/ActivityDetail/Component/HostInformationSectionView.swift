//
//  HostInformationSectionView.swift
//  PiPi
//
//  Created by 정상윤 on 8/8/24.
//

import SwiftUI

struct HostInformationSectionView: View {
    
    let nickname: String
    let level: Int
    
    var body: some View {
        Section {
            informationRow(label: "주최자", data: nickname)
            informationRow(label: "참여도", data: "Lv.\(level)")
        }
        .listRowBackground(Color(.secondarySystemBackground))
    }
    
    private func informationRow(label: String, data: String) -> some View {
        HStack {
            Text(label)
                .frame(width: 120, alignment: .leading)
            Text(data)
        }
    }
    
}
