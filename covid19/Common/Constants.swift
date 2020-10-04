//
//  Constants.swift
//  covid19
//
//  Created by An Trinh on 4/10/20.
//

import Foundation

enum Location: String, CaseIterable, Identifiable {
    case uk = "🇬🇧 United Kingdom"
    case england = "🏴󠁧󠁢󠁥󠁮󠁧󠁿 England"
    case northernIreland = "Northern Ireland"
    case scotland = "🏴󠁧󠁢󠁳󠁣󠁴󠁿 Scotland"
    case wales = "🏴󠁧󠁢󠁷󠁬󠁳󠁿 Wales"
    
    var id: String { self.rawValue }
    
    func flag() -> String {
        switch self {
        case .uk:
            return "🇬🇧"
        case .england:
            return "🏴󠁧󠁢󠁥󠁮󠁧󠁿"
        case .northernIreland:
            return "NIR"
        case .scotland:
            return "🏴󠁧󠁢󠁳󠁣󠁴󠁿"
        case .wales:
            return "🏴󠁧󠁢󠁷󠁬󠁳󠁿"
        }
    }
}

enum ChartCount: String, CaseIterable, Identifiable {
    case oneWeek = "1W"
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case all = "ALL"
    
    var id: String { self.rawValue }
    
    func numberOfDatapoints() -> Int {
        switch self {
        case .threeMonths:
            return 91
        case .sixMonths:
            return 183
        case .oneMonth:
            return 31
        case .oneWeek:
            return 7
        case .all:
            return 1000 // services return max of 1000 items
        }
    }
}

struct Constants {
    static func url(location: Location? = .uk) -> String {
        let url = "https://api.coronavirus.data.gov.uk/v1/data?filters=[FILTER]&structure=%7B%22date%22%3A%22date%22%2C%22cases%22%3A%22newCasesByPublishDate%22%2C%22cumCases%22%3A%22cumCasesByPublishDate%22%2C%22deaths%22%3A%22newDeaths28DaysByPublishDate%22%2C%22cumDeaths%22%3A%22cumDeaths28DaysByPublishDate%22%7D"
        var filter = "areaType=overview"
        switch location {
        case .england:
            filter = "areaType=nation;areaName=england"
        case .northernIreland:
            filter = "areaType=nation;areaName=northern%20ireland"
        case .scotland:
            filter = "areaType=nation;areaName=scotland"
        case .wales:
            filter = "areaType=nation;areaName=wales"
        case .none, .uk:
            filter = "areaType=overview"
        }
        return url.replacingOccurrences(of: "[FILTER]", with: filter)
    }
    
    static let appStoreStory = URL(string: "https://apps.apple.com/gb/story/id1532087825")!
    static let rNumberUK = URL(string: "https://www.gov.uk/guidance/the-r-number-in-the-uk")!
    static let sourceGovUK = URL(string: "https://coronavirus.data.gov.uk")!
    
    static let widgetName = "CasesWidget"
    
    static let aLongTimeAgo: TimeInterval = 60*60*24*120 // 120 days
}
