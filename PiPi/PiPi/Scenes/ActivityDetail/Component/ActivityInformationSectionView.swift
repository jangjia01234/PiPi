//
//  ActivityInformationSectionView.swift
//  PiPi
//
//  Created by 정상윤 on 8/8/24.
//

import SwiftUI

struct ActivityInformationSectionView: View {
    
    let startDateTime: Date
    let estimatedTime: Int?
    let maxPeopleNumber: Int
    let currentPeopleNumber: Int
    let category: Activity.Category
    
    @Binding var showLocationView: Bool
    
    var body: some View {
        Section {
            informationRow(title: "시작 일시") {
                Text(startDateTime.toString())
            }
            informationRow(title: "예상 소요시간") {
                Text((estimatedTime == nil) ? "미정" : "\(estimatedTime!)시간")
            }
            informationRow(title: "인원") {
                Text("\(currentPeopleNumber) / \(maxPeopleNumber)명")
            }
            informationRow(title: "카테고리") {
                Text(category.rawValue)
            }
            informationRow(title: "위치") {
                Button("지도 보기") { showLocationView = true }
            }
        }
        .listRowBackground(Color(.secondarySystemBackground))
    }
    
    private func informationRow(title: String, @ViewBuilder content: () -> some View) -> some View {
        HStack {
            Text(title)
                .frame(width: 120, alignment: .leading)
            content()
        }
    }
    
}
