//
//  ActivityInformationSectionView.swift
//  PiPi
//
//  Created by 정상윤 on 8/8/24.
//

import SwiftUI
import Combine

struct ActivityInformationSectionView: View {
    
    let activity: Activity
    
    var body: some View {
        Section {
            row(title: "시작 일시") {
                Text("\(activity.startDateTime.toString())")
            }
            row(title: "예상 소요시간") {
                Text((activity.estimatedTime == nil) ? "미정" : "\(activity.estimatedTime!)시간")
            }
            row(title: "인원") {
                Text("\(activity.participantID.count + 1) / \(activity.maxPeopleNumber)명")
            }
            row(title: "카테고리") {
                Text(activity.category.rawValue)
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
