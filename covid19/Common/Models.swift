//
//  Models.swift
//  covid19
//
//  Created by An Trinh on 28/9/20.
//

import Foundation

struct Info: Codable {
    let date: String
    let cases: Int?
    let cumCases: Int?
    let deaths: Int?
    let cumDeaths: Int?
}

struct ResponseData: Codable {
    let data: [Info]
}

extension Int {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(for:  NSNumber(value: self)) ?? ""
    }
}
