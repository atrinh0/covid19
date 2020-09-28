//
//  ViewModel.swift
//  covid19
//
//  Created by An Trinh on 27/9/20.
//

import Foundation
import Combine

struct Info: Codable {
    let date: String
    let cases: Int?
    let cumCases: Int?
    let deaths: Int?
    let cumDeaths: Int?
}

struct ResponseData: Codable {
    let data: [Info]
}

class ViewModel: ObservableObject {
    @Published var data: [Info] = []
    @Published var lastUpdated: Date = Date.distantPast
    @Published var lastChecked: Date = Date.distantPast
    @Published var footerText = "Loading...\n"
    
    @Published var latestCases = "-"
    @Published var totalCases = "-"
    @Published var casesChange = ""
    @Published var latestDeaths = "-"
    @Published var totalDeaths = "-"
    @Published var deathsChange = ""
    @Published var latestDate = "-"
    
    @Published var casesData: [Double] = []
    @Published var deathsData: [Double] = []
    
    var url = "https://api.coronavirus.data.gov.uk/v1/data?filters=[FILTER]&structure=%7B%22date%22%3A%22date%22%2C%22cases%22%3A%22newCasesByPublishDate%22%2C%22cumCases%22%3A%22cumCasesByPublishDate%22%2C%22deaths%22%3A%22newDeaths28DaysByPublishDate%22%2C%22cumDeaths%22%3A%22cumDeaths28DaysByPublishDate%22%7D"
    var cancellable: Set<AnyCancellable> = Set()
    var timer: Timer?
    
    init() {
    }
    
    func fetchData(_ location: Location, clearData: Bool) {
        DispatchQueue.main.async {
            self.lastChecked = .distantPast
            
            if clearData {
                self.lastUpdated = .distantPast
                self.latestCases = "-"
                self.totalCases = "-"
                self.casesChange = ""
                self.latestDeaths = "-"
                self.totalDeaths = "-"
                self.deathsChange = ""
                self.latestDate = "-"
            }

            self.updateData()
        }
        
        URLSession.shared.dataTaskPublisher(for: URL(string: urlForLocation(location: location))!)
            .map { output in
                if let urlReponse = output.response as? HTTPURLResponse, let lastModified = urlReponse.allHeaderFields["Last-Modified"] as? String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EEEE, dd LLL yyyy HH:mm:ss zzz"
                    if let serverDate = dateFormatter.date(from: lastModified) {
                        DispatchQueue.main.async {
                            self.lastUpdated = serverDate
                        }
                    }
                }
                return output.data
            }
            .decode(type: ResponseData.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                print("\(completion)")
            }, receiveValue: { value in
                DispatchQueue.main.async {
                    self.data = value.data
                    self.lastChecked = Date()
                    self.updateData()
                }
            })
            .store(in: &cancellable)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateFooterText), userInfo: nil, repeats: true)
    }
    
    var isLoading: Bool {
        abs(lastUpdated.timeIntervalSinceNow) > 60*60*24*120
    }
    
    var isReloading: Bool {
        abs(lastChecked.timeIntervalSinceNow) > 60*60*24*120
    }
    
    // MARK: - Helpers
    
    private func urlForLocation(location: Location) -> String {
        var filter = "areaType=overview"
        switch location {
        case .uk:
            filter = "areaType=overview"
        case .england:
            filter = "areaType=nation;areaName=england"
        case .northernIreland:
            filter = "areaType=nation;areaName=northern%20ireland"
        case .scotland:
            filter = "areaType=nation;areaName=scotland"
        case .wales:
            filter = "areaType=nation;areaName=wales"
        }
        return url.replacingOccurrences(of: "[FILTER]", with: filter)
    }
    
    private func timeAgo(date: Date) -> String {
        let interval = abs(date.timeIntervalSinceNow)
        
        if interval < 60 {
            let seconds = Int(interval)
            return seconds == 1 ? "1 second ago" : "\(seconds) seconds ago"
        }
        let minutes = Int(interval/60)
        return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
    }
    
    private func updateData() {
        updateFooterText()
        if let latestRecord = data.first {
            if let cases = latestRecord.cases, cases > 0 {
                latestCases = "+\(cases.formattedWithSeparator)"
            } else {
                latestCases = "0"
            }
            if let deaths = latestRecord.deaths, deaths > 0 {
                latestDeaths = "+\(deaths.formattedWithSeparator)"
            } else {
                latestDeaths = "0"
            }
            totalCases = latestRecord.cumCases?.formattedWithSeparator ?? "0"
            totalDeaths = latestRecord.cumDeaths?.formattedWithSeparator ?? "0"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: latestRecord.date) {
                dateFormatter.dateFormat = "EEEE dd MMMM"
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
        
        let casesArray = data.map { Double($0.cases ?? 0) }
        let deathsArray = data.map { Double($0.deaths ?? 0) }
        let maxCases = casesArray.max() ?? 1.0
        let maxDeaths = deathsArray.max() ?? 1.0
        casesData = casesArray.map { $0/maxCases }.reversed()
        deathsData = deathsArray.map { $0/maxDeaths }.reversed()
    }
    
    @objc func updateFooterText() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE dd MMMM yyyy 'at' h:mm a"
        let modified = dateFormatter.string(from: lastUpdated)
            .replacingOccurrences(of: " AM", with: "am")
            .replacingOccurrences(of: " PM", with: "pm")
        let lastUpdatedString = "Last updated on \(modified)"
        let lastCheckedString = isReloading ? "Reloading..." : "Last checked \(timeAgo(date: lastChecked))"
        
        footerText = isLoading ? "Loading...\n" : "\(lastUpdatedString)\n\(lastCheckedString)"
    }
}

extension Int {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(for:  NSNumber(value: self)) ?? ""
    }
}
