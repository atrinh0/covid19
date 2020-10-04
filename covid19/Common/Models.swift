//
//  Models.swift
//  covid19
//
//  Created by An Trinh on 28/9/20.
//

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
