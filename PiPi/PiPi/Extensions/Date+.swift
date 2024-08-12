//
//  Date+.swift
//  PiPi
//
//  Created by Jia Jang on 8/5/24.
//

import Foundation

extension Date {
    func toString(format: String = "yyyy년 MM월 dd일\na HH시 mm분") -> String {
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
}
