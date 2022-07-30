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
    var id: String { self.rawValue }
}

enum ChartCount: String, CaseIterable, Identifiable {
    case all = "ALL"
    case twoYears = "2Y"
    case oneYear = "1Y"
    case sixMonths = "6M"
    case threeMonths = "3M"
    case oneMonth = "1M"
    var id: String { self.rawValue }

    var numberOfDatapoints: Int {
        let dataPoints: [ChartCount: Int] = [
            .oneMonth: 31,
            .threeMonths: 91,
            .sixMonths: 183,
            .oneYear: 365,
            .twoYears: 730
        ]
        // services return max of 1000 items
        return dataPoints[self] ?? 1000
    }

    var voiceoverDescription: String {
        switch self {
        case .all:
            return "All data"
        case .twoYears:
            return "Two years"
        case .oneYear:
            return "One year"
        case .sixMonths:
            return "Six months"
        case .threeMonths:
            return "Three months"
        case .oneMonth:
            return "One month"
        }
    }
}

enum Constants {
    static func url(location: Location? = .unitedKingdom) -> String {
        // api url
        // swiftlint:disable:next line_length
        let url = "https://api.coronavirus.data.gov.uk/v1/data?filters=[FILTER]&structure=%7B%22date%22:%22date%22,%22newCasesBySpecimenDate%22:%22newCasesBySpecimenDate%22,%22cumCasesBySpecimenDate%22:%22cumCasesBySpecimenDate%22,%22newDeaths28DaysByDeathDate%22:%22newDeaths28DaysByDeathDate%22,%22cumDeaths28DaysByDeathDate%22:%22cumDeaths28DaysByDeathDate%22%7D"
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

    static let rNumberUK = URL(string: "https://www.gov.uk/guidance/the-r-number-in-the-uk")
    static let sourceGovUK = URL(string: "https://coronavirus.data.gov.uk")

    static let widgetName = "CasesWidget"

    static let aLongTimeAgo: TimeInterval = 60*60*24*120 // 120 days
    static let updateInterval: TimeInterval = 60*15 // 15 min

    static let lastModifiedHeaderFieldKey = "Last-Modified"
    static let lastModifiedDateFormat = "EEEE, dd LLL yyyy HH:mm:ss zzz"
    static let lastModifiedKey = "LastModified"
    static let lastNotificationKey = "LastNotification"
    static let backgroundFetchId = "com.atrinh.covid.fetch"

    static let casesColor: Color = .orange
    static let deathsColor: Color = .red

    static let rNumberUKTitle = "R Number"
    static let sourceGovUKTitle = "UK Summary"
}
