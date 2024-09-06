//
//  User.swift
//  PiPi
//
//  Created by 신혜연 on 8/3/24.
//

import Foundation

struct User: Identifiable, Equatable, FirebaseData {
    
    let id: String
    let nickname: String
    let affiliation: Affiliation
    let email: String
    
    init(
        id: String = UUID().uuidString,
        nickname: String,
        affiliation: Affiliation,
        email: String
    ) {
        self.id = id
        self.nickname = nickname
        self.affiliation = affiliation
        self.email = email
    }
    
}

enum Affiliation: String, Codable, CaseIterable {
    
    case postech = "포항공대"
    case apple = "애플 디벨로퍼 아카데미"
    
}
