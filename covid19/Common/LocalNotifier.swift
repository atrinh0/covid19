//
//  LocalNotifier.swift
//  covid19
//
//  Created by An Trinh on 31/10/2021.
//

import UIKit

enum LocalNotifier {
    private static var defaults = UserDefaults.standard

    static func scheduleLocalNotification(infoArray: [Info]) {
        guard let latestRecord = infoArray.first else { return }

        var contentTitle = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: latestRecord.date) {
            dateFormatter.dateFormat = "EEEE d MMMM"
            contentTitle = "Latest update for \(dateFormatter.string(from: date))"
        }

        let contentBody = getContentBody(infoArray: infoArray)

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

    private static func getContentBody(infoArray: [Info]) -> String {
        guard let latestRecord = infoArray.first else { return "" }

        var latestCases = "0"
        var latestDeaths = "0"
        if let cases = latestRecord.cases, cases > 0 {
            latestCases = cases.formattedWithSeparator
        }
        if let deaths = latestRecord.deaths, deaths > 0 {
            latestDeaths = deaths.formattedWithSeparator
        }

        let totalCases = latestRecord.totalCases?.formattedWithSeparator ?? "0"
        let totalDeaths = latestRecord.totalDeaths?.formattedWithSeparator ?? "0"

        var casesChange = ""
        var deathsChange = ""
        if infoArray.count > 1 {
            let secondRecord = infoArray[1]
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
