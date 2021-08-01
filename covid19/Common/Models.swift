//
//  Models.swift
//  covid19
//
//  Created by An Trinh on 28/9/20.
//

struct Info: Decodable {
    let date: String
    let cases: Int?
    let cumCases: Int?
    let deaths: Int?
    let cumDeaths: Int?

    enum CodingKeys: String, CodingKey {
        case date
        case cases = "newCasesByPublishDate"
        case cumCases = "cumCasesByPublishDate"
        case deaths = "newDeaths28DaysByPublishDate"
        case cumDeaths = "cumDeaths28DaysByPublishDate"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(String.self, forKey: .date)
        cases = try? container.decodeIfPresent(Int.self, forKey: .cases)
        cumCases = try? container.decodeIfPresent(Int.self, forKey: .cumCases)
        deaths = try? container.decodeIfPresent(Int.self, forKey: .deaths)
        cumDeaths = try? container.decodeIfPresent(Int.self, forKey: .cumDeaths)
    }
}

struct ResponseData: Decodable {
    let data: [Info]
}
