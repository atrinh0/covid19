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
        if let date = latestRecord.date.toDate() {
            let dateFormatter = DateFormatter()
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

        let latestCases = latestRecord.cases.formattedWithSeparator
        let latestDeaths = latestRecord.deaths.formattedWithSeparator

        let totalCases = latestRecord.totalCases.formattedWithSeparator
        let totalDeaths = latestRecord.totalDeaths.formattedWithSeparator

        var casesChange = ""
        var deathsChange = ""

        if infoArray.count > 1 {
            let secondRecord = infoArray[1]
            var difference = latestRecord.cases - secondRecord.cases
            var minusOrPlus = difference < 0 ? "-" : "+"
            casesChange = " (\(minusOrPlus)\(abs(difference).formattedWithSeparator))"

            difference = latestRecord.deaths - secondRecord.deaths
            minusOrPlus = difference < 0 ? "-" : "+"
            deathsChange = " (\(minusOrPlus)\(abs(difference).formattedWithSeparator))"
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
