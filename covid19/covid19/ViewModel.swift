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
    @Published var footerText = "Loading..."
    
    var url = "https://api.coronavirus.data.gov.uk/v1/data?filters=areaType=overview&structure=%7B%22date%22%3A%22date%22%2C%22cases%22%3A%22newCasesByPublishDate%22%2C%22cumCases%22%3A%22cumCasesByPublishDate%22%2C%22deaths%22%3A%22newDeaths28DaysByPublishDate%22%2C%22cumDeaths%22%3A%22cumDeaths28DaysByPublishDate%22%7D"
    var cancellable: Set<AnyCancellable> = Set()
    var timer: Timer?
    
    init() {
    }
    
    func fetchData(_ location: Location) {
        lastUpdated = .distantPast
        lastChecked = .distantPast
        
        URLSession.shared.dataTaskPublisher(for: URL(string: url)!)
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
                    self.updateFooterText()
                }
            })
            .store(in: &cancellable)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateFooterText), userInfo: nil, repeats: true)
    }

    @objc func updateFooterText() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE dd MMMM yyyy 'at' h:mm a"
        let modified = dateFormatter.string(from: lastUpdated)
            .replacingOccurrences(of: " AM", with: "am")
            .replacingOccurrences(of: " PM", with: "pm")
        let lastUpdatedString = "Last updated on \(modified)"
        let lastCheckedString = "Last checked \(timeAgo(date: lastChecked))"
        
        footerText = "\(lastUpdatedString)\n\(lastCheckedString)"
    }
    
    func isLoading() -> Bool {
        if abs(lastUpdated.timeIntervalSinceNow) > 60*60*24*120 || abs(lastChecked.timeIntervalSinceNow) > 60*60*24*120 {
            return true
        }
        return false
    }
    
    // MARK: - Helpers
    
    private func timeAgo(date: Date) -> String {
        let interval = abs(date.timeIntervalSinceNow)
        
        if interval < 60 {
            let seconds = Int(interval)
            return seconds == 1 ? "1 second ago" : "\(seconds) seconds ago"
        }
        let minutes = Int(interval/60)
        return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
    }
}
