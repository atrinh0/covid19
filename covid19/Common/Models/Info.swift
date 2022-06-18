//
//  Info.swift
//  covid19
//
//  Created by An Trinh on 28/9/20.
//

struct Info {
    let date: String
    let cases: Int?
    let totalCases: Int?
    let deaths: Int?
    let totalDeaths: Int?

    init(response: ResponseInfo) {
        self.date = response.date
        self.cases = response.newCasesByPublishDate
        self.totalCases = response.cumCasesByPublishDate
        self.deaths = response.newDeaths28DaysByPublishDate
        self.totalDeaths = response.cumDeaths28DaysByPublishDate
    }
}

// MARK: - Response models

struct ResponseData: Decodable {
    let data: [ResponseInfo]
}

struct ResponseInfo: Decodable {
    let date: String
    let newCasesByPublishDate: Int?
    let cumCasesByPublishDate: Int?
    let newDeaths28DaysByPublishDate: Int?
    let cumDeaths28DaysByPublishDate: Int?
}
