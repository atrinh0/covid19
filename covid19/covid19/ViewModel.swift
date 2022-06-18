//
//  ViewModel.swift
//  covid19
//
//  Created by An Trinh on 27/9/20.
//

import Foundation

@MainActor
final class ViewModel: ObservableObject {
    @Published var data: [Info] = []
    @Published var lastUpdated: Date = Date.distantPast
    @Published var lastChecked: Date = Date.distantPast
    @Published var footerText = "Loading..."

    @Published var weeklyLatestCases = "-"
    @Published var weeklyCasesChange = ""
    @Published var totalCases = "-"
    @Published var weeklyLatestDeaths = "-"
    @Published var weeklyDeathsChange = ""
    @Published var totalDeaths = "-"
    @Published var latestDate = "-"

    @Published var casesData: [Double] = []
    @Published var rawDeathsData: [Double] = []
    @Published var relativeDeathsData: [Double] = []

    private var timer: Timer?
    private var error: String?

    func fetchData(_ location: Location, shouldClearData: Bool) {
        error = nil
        lastChecked = .distantPast
        if shouldClearData {
            clearData()
        }
        updateFooterText()

        let urlString = Constants.url(location: location)
        print("\(urlString)")
        guard let url = URL(string: urlString) else { return }

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
                if let urlReponse = response as? HTTPURLResponse,
                    let lastModified = urlReponse.allHeaderFields[Constants.lastModifiedHeaderFieldKey] as? String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = Constants.lastModifiedDateFormat
                    if let serverDate = dateFormatter.date(from: lastModified) {
                        lastUpdated = serverDate
                    }
                }
                let responseData = try JSONDecoder().decode(ResponseData.self, from: data)
                self.data = responseData.data.map { Info(response: $0) }
                lastChecked = Date()
            } catch {
                self.error = error.localizedDescription
            }
            updateData()
        }

        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateFooterText),
                                     userInfo: nil, repeats: true)
    }

    var isLoading: Bool {
        abs(lastUpdated.timeIntervalSinceNow) > Constants.aLongTimeAgo
    }

    var isReloading: Bool {
        abs(lastChecked.timeIntervalSinceNow) > Constants.aLongTimeAgo
    }

    // MARK: - Helpers

    private func clearData() {
        data = []
        lastUpdated = .distantPast
        weeklyLatestCases = "-"
        weeklyCasesChange = ""
        totalCases = "-"
        weeklyLatestDeaths = "-"
        weeklyDeathsChange = ""
        totalDeaths = "-"
        latestDate = "-"
    }

    private func timeAgo(date: Date) -> String {
        let interval = abs(date.timeIntervalSinceNow)

        if interval < 60 {
            return "moments ago"
        }
        let minutes = Int(interval/60)
        return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
    }

    private func updateData() {
        updateFooterText()
        if let latestRecord = data.first {
            totalCases = latestRecord.totalCases?.formattedWithSeparator ?? "0"
            totalDeaths = latestRecord.totalDeaths?.formattedWithSeparator ?? "0"

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: latestRecord.date) {
                dateFormatter.dateFormat = "EEEE dd MMMM"
                latestDate = dateFormatter.string(from: date)
            }
        }

        calculateWeeklyChange()

        let casesArray = data.map { Double($0.cases ?? 0) }
        let deathsArray = data.map { Double($0.deaths ?? 0) }
        let maxCasesScalingValue = (casesArray.max() ?? 1.0) * 1.05
        let maxDeathsScalingValue = (deathsArray.max() ?? 1.0) * 1.05
        casesData = casesArray.map { $0/maxCasesScalingValue }.reversed()
        rawDeathsData = deathsArray.map { $0/(maxDeathsScalingValue * 1.5)}.reversed()
        relativeDeathsData = deathsArray.map { $0/maxCasesScalingValue }.reversed()
    }

    private func calculateWeeklyChange() {
        if data.count <= 14 {
            return
        }

        let fortnightCases = data.prefix(14).compactMap { $0.cases }.reduce(0, +)
        let weeklyCases = data.prefix(7).compactMap { $0.cases }.reduce(0, +)
        let fortnightDeaths = data.prefix(14).compactMap { $0.deaths }.reduce(0, +)
        let weeklyDeaths = data.prefix(7).compactMap { $0.deaths }.reduce(0, +)

        let priorWeekCases = fortnightCases - weeklyCases
        let casesDifference = weeklyCases - priorWeekCases
        let casesMinusOrPlus = casesDifference < 0 ? "-" : "+"
        let casesPercentageChange: Double = Double(abs(casesDifference))/Double(priorWeekCases) * 100

        let priorWeekDeaths = fortnightDeaths - weeklyDeaths
        let deathsDifference = weeklyDeaths - priorWeekDeaths
        let deathsMinusOrPlus = deathsDifference < 0 ? "-" : "+"
        let deathsPercentageChange: Double = Double(abs(deathsDifference))/Double(priorWeekDeaths) * 100

        weeklyLatestCases = "\(weeklyCases.formattedWithSeparator)"
        weeklyCasesChange = " (\(casesMinusOrPlus)\(abs(casesDifference).formattedWithSeparator)"
        weeklyCasesChange += ", \(casesMinusOrPlus)\(casesPercentageChange.rounded(toPlaces: 1))%)"

        weeklyLatestDeaths = "\(weeklyDeaths.formattedWithSeparator)"
        weeklyDeathsChange = " (\(deathsMinusOrPlus)\(abs(deathsDifference).formattedWithSeparator)"
        weeklyDeathsChange += ", \(deathsMinusOrPlus)\(deathsPercentageChange.rounded(toPlaces: 1))%)"
    }

    @objc private func updateFooterText() {
        if let error = error {
            footerText = error
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE dd MMMM yyyy 'at' h:mm a"
        let modified = dateFormatter.string(from: lastUpdated)
            .replacingOccurrences(of: " AM", with: "am")
            .replacingOccurrences(of: " PM", with: "pm")
        let lastUpdatedString = "Last updated on \(modified)"
        let lastCheckedString = isReloading ? "Checking..." : "Last checked \(timeAgo(date: lastChecked))"

        footerText = isLoading ? "Loading..." : "\(lastUpdatedString)\n\(lastCheckedString)"
    }
}
