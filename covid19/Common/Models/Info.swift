//
//  Info.swift
//  covid19
//
//  Created by An Trinh on 28/9/20.
//

struct Info: Hashable {
    let date: String
    let cases: Int
    let totalCases: Int
    let deaths: Int
    let totalDeaths: Int

    init?(response: ResponseInfo) {
        guard let cases = response.newCasesBySpecimenDate,
              let totalCases = response.cumCasesBySpecimenDate,
              let deaths = response.newDeaths28DaysByDeathDate,
              let totalDeaths = response.cumDeaths28DaysByDeathDate else { return nil }
        self.date = response.date
        self.cases = cases
        self.totalCases = totalCases
        self.deaths = deaths
        self.totalDeaths = totalDeaths
    }
}

// MARK: - Response models

struct ResponseData: Decodable {
    let data: [ResponseInfo]
}

struct ResponseInfo: Decodable {
    let date: String
    let newCasesBySpecimenDate: Int?
    let cumCasesBySpecimenDate: Int?
    let newDeaths28DaysByDeathDate: Int?
    let cumDeaths28DaysByDeathDate: Int?
}
