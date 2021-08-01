//
//  covid19App.swift
//  covid19
//
//  Created by An Trinh on 27/9/20.
//

import SwiftUI
import UIKit
import BackgroundTasks
import WidgetKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }

        BGTaskScheduler.shared.register(forTaskWithIdentifier: Constants.backgroundFetchId, using: nil) { task in
            self.handleAppRefreshTask(task: task)
        }

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleBackgroundFetch()
    }

    func handleAppRefreshTask(task: BGTask) {
        guard let url = URL(string: Constants.url()) else { return }

        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        URLSession.shared.dataTask(with: url) { data, response, _ in
            guard let data = data else {
                task.setTaskCompleted(success: false)
                return
            }
            let previousLastModified = UserDefaults.standard.value(forKey: Constants.lastModifiedKey) as? String ?? ""
            if let responseData = try? JSONDecoder().decode(ResponseData.self, from: data),
               let urlReponse = response as? HTTPURLResponse,
               let lastModified = urlReponse.allHeaderFields[Constants.lastModifiedHeaderFieldKey] as? String {
                if previousLastModified == lastModified {
                    task.setTaskCompleted(success: true)
                    return
                }
                self.scheduleLocalNotification(response: responseData)
                WidgetCenter.shared.reloadTimelines(ofKind: Constants.widgetName)
                UserDefaults.standard.setValue(lastModified, forKey: Constants.lastModifiedKey)
                task.setTaskCompleted(success: true)
            }
        }.resume()

        scheduleBackgroundFetch()
    }

    private func scheduleBackgroundFetch() {
        let fetchTask = BGAppRefreshTaskRequest(identifier: Constants.backgroundFetchId)
        fetchTask.earliestBeginDate = Date(timeIntervalSinceNow: Constants.updateInterval)
        do {
            try BGTaskScheduler.shared.submit(fetchTask)
        } catch {
            print("Unable to submit task: \(error.localizedDescription)")
        }
    }

    private func scheduleLocalNotification(response: ResponseData) {
        let data = response.data
        guard let latestRecord = data.first else { return }

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

        var contentTitle = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: latestRecord.date) {
            dateFormatter.dateFormat = "EEEE d MMMM"
            contentTitle = "Latest update for \(dateFormatter.string(from: date))"
        }

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

        let content = UNMutableNotificationContent()
        content.title = contentTitle
        content.body = """
            😷 \(latestCases)\(casesChange) cases, \(totalCases) total
            💀 \(latestDeaths)\(deathsChange) deaths, \(totalDeaths) total
            """

        addNotification(content: content)
    }

    private func addNotification(content: UNMutableNotificationContent) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

@main
struct Covid19App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("Graphs", systemImage: "chart.bar.xaxis")
                    }
                SourceView()
                    .tabItem {
                        Label(Constants.sourceGovUKTitle, systemImage: "crown.fill")
                    }
                RNumberView()
                    .tabItem {
                        Label(Constants.rNumberUKTitle, systemImage: "r.circle.fill")
                    }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                let fetchTask = BGAppRefreshTaskRequest(identifier: Constants.backgroundFetchId)
                fetchTask.earliestBeginDate = Date(timeIntervalSinceNow: Constants.updateInterval)
                do {
                    try BGTaskScheduler.shared.submit(fetchTask)
                } catch {
                    print("Unable to submit task: \(error.localizedDescription)")
                }
            }
        }
    }
}
