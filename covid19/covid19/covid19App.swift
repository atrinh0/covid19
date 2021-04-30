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
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Constants.backgroundFetchId, using: nil) { task in
            self.handleAppRefreshTask(task: task as! BGAppRefreshTask)
        }
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleBackgroundFetch()
    }
    
    func handleAppRefreshTask(task: BGAppRefreshTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        URLSession.shared.dataTask(with: URL(string: Constants.url())!) { data, response, _ in
            guard let data = data else {
                task.setTaskCompleted(success: false)
                return
            }
            let responseData = try! JSONDecoder().decode(ResponseData.self, from: data)
            let previousLastModified = UserDefaults.standard.value(forKey: Constants.lastModifiedKey) as? String ?? ""
            if let urlReponse = response as? HTTPURLResponse, let lastModified = urlReponse.allHeaderFields["Last-Modified"] as? String {
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
        var latestCases = ""
        var latestDeaths = ""
        var totalCases = ""
        var totalDeaths = ""
        var casesChange = ""
        var deathsChange = ""
        var latestDate = ""
        
        if let latestRecord = data.first {
            if let cases = latestRecord.cases, cases > 0 {
                latestCases = cases.formattedWithSeparator
            } else {
                latestCases = "0"
            }
            if let deaths = latestRecord.deaths, deaths > 0 {
                latestDeaths = deaths.formattedWithSeparator
            } else {
                latestDeaths = "0"
            }
            totalCases = latestRecord.cumCases?.formattedWithSeparator ?? "0"
            totalDeaths = latestRecord.cumDeaths?.formattedWithSeparator ?? "0"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: latestRecord.date) {
                dateFormatter.dateFormat = "EEEE d MMMM"
                latestDate = dateFormatter.string(from: date)
            }
            
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
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { _, _ in })
        
        let content = UNMutableNotificationContent()
        
        content.title = "Latest update for \(latestDate)"
        content.body = "😷 \(latestCases)\(casesChange) cases, \(totalCases) total\n💀 \(latestDeaths)\(deathsChange) deaths, \(totalDeaths) total"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

@main
struct covid19App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("Graphs", systemImage: "chart.bar.xaxis")
                    }
                RNumberView()
                    .tabItem {
                        Label(Constants.rNumberUKTitle, systemImage: "r.circle.fill")
                    }
                SourceView()
                    .tabItem {
                        Label(Constants.sourceGovUKTitle, systemImage: "crown.fill")
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
