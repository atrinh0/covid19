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

    private func handleAppRefreshTask(task: BGTask) {
        defer {
            scheduleBackgroundFetch()
        }

        guard let url = URL(string: Constants.url()) else { return }

        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        Task {
            do {
                let request = URLRequest(url: url)
                let (data, response) = try await URLSession.shared.data(for: request)
                let prevLastModified = UserDefaults.standard.value(forKey: Constants.lastModifiedKey) as? String ?? ""
                let responseData = try JSONDecoder().decode(ResponseData.self, from: data)
                let infoArray = responseData.data.compactMap { Info(response: $0) }
                if let urlReponse = response as? HTTPURLResponse,
                   let lastModified = urlReponse.allHeaderFields[Constants.lastModifiedHeaderFieldKey] as? String {
                    LocalNotifier.scheduleLocalNotification(infoArray: infoArray)
                    if prevLastModified == lastModified {
                        task.setTaskCompleted(success: true)
                        return
                    }
                    WidgetCenter.shared.reloadTimelines(ofKind: Constants.widgetName)
                    UserDefaults.standard.setValue(lastModified, forKey: Constants.lastModifiedKey)
                    task.setTaskCompleted(success: true)
                    return
                }
            } catch { }
        }

        task.setTaskCompleted(success: false)
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
