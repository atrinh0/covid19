//
//  Constants.swift
//  covid19
//
//  Created by An Trinh on 4/10/20.
//

import Foundation
import SwiftUI

enum Location: String, CaseIterable, Identifiable {
    case unitedKingdom = "🇬🇧 United Kingdom"
    case england = "🏴󠁧󠁢󠁥󠁮󠁧󠁿 England"
    case northernIreland = "Northern Ireland"
    case scotland = "🏴󠁧󠁢󠁳󠁣󠁴󠁿 Scotland"
    case wales = "🏴󠁧󠁢󠁷󠁬󠁳󠁿 Wales"

    // Identifiable
    // swiftlint:disable:next identifier_name
    var id: String { self.rawValue }
}

enum ChartCount: String, CaseIterable, Identifiable {
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case oneYear = "1Y"
    case all = "ALL"

    // Identifiable
    // swiftlint:disable:next identifier_name
    var id: String { self.rawValue }

    func numberOfDatapoints() -> Int {
        switch self {
        case .oneMonth:
            return 31
        case .threeMonths:
            return 91
        case .sixMonths:
            return 183
        case .oneYear:
            return 365
        case .all:
            return 1_000 // services return max of 1000 items
        }
    }
}

struct Constants {
    static func url(location: Location? = .unitedKingdom) -> String {
        // api url
        // swiftlint:disable:next line_length
        let url = "https://api.coronavirus.data.gov.uk/v1/data?filters=[FILTER]&structure=%7B%22date%22%3A%22date%22%2C%22newCasesByPublishDate%22%3A%22newCasesByPublishDate%22%2C%22cumCasesByPublishDate%22%3A%22cumCasesByPublishDate%22%2C%22newDeaths28DaysByPublishDate%22%3A%22newDeaths28DaysByPublishDate%22%2C%22cumDeaths28DaysByPublishDate%22%3A%22cumDeaths28DaysByPublishDate%22%7D"
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
        case .none, .unitedKingdom:
            filter = "areaType=overview"
        }
        return url.replacingOccurrences(of: "[FILTER]", with: filter)
    }

    static let appStoreStory = URL(string: "https://apps.apple.com/gb/story/id1532087825")!
    static let rNumberUK = URL(string: "https://www.gov.uk/guidance/the-r-number-in-the-uk")!
    static let sourceGovUK = URL(string: "https://coronavirus.data.gov.uk")!

    static let widgetName = "CasesWidget"

    static let aLongTimeAgo: TimeInterval = 60*60*24*120 // 120 days
    static let updateInterval: TimeInterval = 60*15 // 15 min

    static let lastModifiedKey = "LastModified"
    static let lastModifiedHeaderFieldKey = "Last-Modified"
    static let lastModifiedDateFormat = "EEEE, dd LLL yyyy HH:mm:ss zzz"
    static let backgroundFetchId = "com.atrinh.covid.fetch"

    static let casesColor: Color = .orange
    static let deathsColor: Color = .red

    static let rNumberUKTitle = "R Number"
    static let sourceGovUKTitle = "UK Summary"
}
