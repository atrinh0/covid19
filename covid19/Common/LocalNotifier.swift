//
//  LocalNotifier.swift
//  covid19
//
//  Created by An Trinh on 31/10/2021.
//

import UIKit

enum LocalNotifier {
    private static var defaults = UserDefaults.standard

    static func scheduleLocalNotification(response: ResponseData) {
        let data = response.data
        guard let latestRecord = data.first else { return }

        var contentTitle = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: latestRecord.date) {
            dateFormatter.dateFormat = "EEEE d MMMM"
            contentTitle = "Latest update for \(dateFormatter.string(from: date))"
        }

        let contentBody = getContentBody(data: data)

        let notification = contentTitle + contentBody
        let lastNotification = defaults.value(forKey: Constants.lastNotificationKey) as? String ?? ""

        // prevent multiple duplicate notifications
        if notification == lastNotification {
            return
        }
        defaults.setValue(notification, forKey: Constants.lastNotificationKey)

        let content = UNMutableNotificationContent()
        content.title = contentTitle
        content.body = contentBody

        addNotification(content: content)
    }

    private static func getContentBody(data: [Info]) -> String {
        guard let latestRecord = data.first else { return "" }

        var latestCases = "0"
        var latestDeaths = "0"
        if let cases = latestRecord.cases, cases > 0 {
            latestCases = cases.formattedWithSeparator
        }
        if let deaths = latestRecord.deaths, deaths > 0 {
            latestDeaths = deaths.formattedWithSeparator
        }

        let totalCases = latestRecord.cumCases?.formattedWithSeparator ?? "0"
        let totalDeaths = latestRecord.cumDeaths?.formattedWithSeparator ?? "0"

        var casesChange = ""
        var deathsChange = ""
        if data.count > 1 {
            let secondRecord = data[1]
            if let cases = latestRecord.cases, let dayBeforeCases = secondRecord.cases {
                let difference = cases - dayBeforeCases
                let minusOrPlus = difference < 0 ? "-" : "+"
                casesChange = " (\(minusOrPlus)\(abs(difference).formattedWithSeparator))"
            }
            if let deaths = latestRecord.deaths, let dayBeforeDeaths = secondRecord.deaths {
                let difference = deaths - dayBeforeDeaths
                let minusOrPlus = difference < 0 ? "-" : "+"
                deathsChange = " (\(minusOrPlus)\(abs(difference).formattedWithSeparator))"
            }
        }

        return """
            😷 \(latestCases)\(casesChange) cases, \(totalCases) total
            💀 \(latestDeaths)\(deathsChange) deaths, \(totalDeaths) total
            """
    }

    private static func addNotification(content: UNMutableNotificationContent) {
        let currentNotificationCenter = UNUserNotificationCenter.current()
        currentNotificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        currentNotificationCenter.add(request)
    }
}
