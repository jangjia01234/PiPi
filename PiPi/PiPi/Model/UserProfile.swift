//
//  UserProfile.swift
//  PiPi
//
//  Created by 신혜연 on 8/3/24.
//

import Foundation

struct UserProfile: Identifiable, Codable {
    
    let id: String
    let nickname: String
    let affiliation: String
    let email: String
    let level: Int
    
    init(
        id: String = UUID().uuidString,
        nickname: String,
        affiliation: String,
        email: String,
        level: Int = 1
    ) {
        self.id = id
        self.nickname = nickname
        self.affiliation = affiliation
        self.email = email
        self.level = level
    }
    
}

extension UserProfile: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
}

enum Affiliation: String, Codable, CaseIterable {
    case postech = "포항공대"
    case apple = "애플 디벨로퍼 아카데미"
}
