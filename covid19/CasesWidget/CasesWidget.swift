//
//  CasesWidget.swift
//  CasesWidget
//
//  Created by An Trinh on 28/9/20.
//

import WidgetKit
import SwiftUI
import Charts

struct Provider: TimelineProvider {
    private let session = URLSession.shared

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), cases: 0, deaths: 0, casesData: [], deathsData: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        Task {
            do {
                let entry = try await simpleEntry(in: context)
                completion(entry)
            } catch { }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Task {
            do {
                let entry = try await simpleEntry(in: context)
                let timeline = Timeline(entries: [entry],
                                        policy: .after(Date(timeIntervalSinceNow: Constants.updateInterval)))
                completion(timeline)
            } catch { }
        }
    }

    private func simpleEntry(in context: Context) async throws -> SimpleEntry {
        guard let url = URL(string: Constants.url(location: .england)) else {
            return placeholder(in: context)
        }
        let request = URLRequest(url: url)
        let (data, _) = try await session.data(for: request)
        let responseData = try JSONDecoder().decode(ResponseData.self, from: data)
        let infoArray = responseData.data.compactMap { Info(response: $0) }
        let entry = SimpleEntry(infoArray: infoArray)
        return entry
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let cases: Int?
    let deaths: Int?
    let casesData: [Double]
    let deathsData: [Double]
    let latestDataPoint: Date

    init(date: Date, cases: Int, deaths: Int, casesData: [Double], deathsData: [Double]) {
        self.date = date
        self.cases = cases
        self.deaths = deaths
        self.casesData = casesData
        self.deathsData = deathsData
        self.latestDataPoint = .distantPast
    }

    init(date: Date? = Date(), infoArray: [Info]) {
        self.date = date ?? Date()
        if let firstRecord = infoArray.first {
            self.cases = firstRecord.cases
            self.deaths = firstRecord.deaths
            self.latestDataPoint = firstRecord.date.toDate() ?? .distantPast
        } else {
            self.cases = 0
            self.deaths = 0
            self.latestDataPoint = .distantPast
        }

        let casesArray = infoArray.map { Double($0.cases) }
        let deathsArray = infoArray.map { Double($0.deaths) }
        self.casesData = casesArray.reversed()
        self.deathsData = deathsArray.reversed()
    }
}

struct CasesWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            WidgetView(entry: entry, isWide: false, isTall: false)
        case .systemMedium:
            WidgetView(entry: entry, isWide: true, isTall: false)
        default:
            WidgetView(entry: entry, isWide: true, isTall: true)
        }
    }
}

struct WidgetView: View {
    var entry: Provider.Entry
    let isWide: Bool
    let isTall: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ZStack(alignment: .topLeading) {
                Text(entry.latestDataPoint, style: .relative)
                    .font(.caption.weight(.bold))
                    .foregroundColor(.primary)
                    .opacity(0.2)
                    .padding(.horizontal, 7)
//                Chart(data: entry.deathsData.suffix(isWide ? 183 : 91))
//                    .chartStyle(
//                        LineChartStyle(.line, lineColor: Constants.deathsColor, lineWidth: 2)
//                    )
//                Chart(data: entry.casesData.suffix(isWide ? 183 : 91))
//                    .chartStyle(
//                        LineChartStyle(.line, lineColor: Constants.casesColor, lineWidth: 2)
//                    )
            }
            .padding(.horizontal, -7)
            if isWide {
                HStack(alignment: .bottom, spacing: isTall ? 5 : 0) {
                    HStack {
                        Text(formatCount(val: entry.cases))
                            .font(Font.title2.bold())
                            .foregroundColor(Constants.casesColor) +
                            Text(" cases")
                            .font(Font.caption.bold())
                        Spacer()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    HStack {
                        Text(formatCount(val: entry.deaths))
                            .font(Font.title2.bold())
                            .foregroundColor(Constants.deathsColor) +
                            Text(" deaths")
                            .font(Font.caption.bold())
                        Spacer()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
            } else {
                VStack(alignment: .leading, spacing: isTall ? 5 : 0) {
                    HStack {
                        Text(formatCount(val: entry.cases))
                            .font(Font.title2.bold())
                            .foregroundColor(Constants.casesColor) +
                            Text(" cases")
                            .font(Font.caption.bold())
                    }
                    HStack {
                        Text(formatCount(val: entry.deaths))
                            .font(Font.title2.bold())
                            .foregroundColor(Constants.deathsColor) +
                            Text(" deaths")
                            .font(Font.caption.bold())
                    }
                }
            }
        }
        .padding(10)
        .background(LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemBackground), Color.clear]),
                                   startPoint: .top,
                                   endPoint: .bottom))
    }

    private func formatCount(val: Int?) -> String {
        if let val {
            return "\(val.formattedWithSeparator)"
        }
        return " "
    }

    private func lastUpdated(val: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.lastModifiedDateFormat
        if let serverDate = dateFormatter.date(from: val) {
            return timeAgo(date: serverDate)
        }
        return ""
    }

    private func timeAgo(date: Date) -> String {
        let interval = abs(date.timeIntervalSinceNow)

        if interval < 60*15 {
            return "just now"
        }
        let minutes = Int(interval/60)
        if interval < 60*90 {
            return "\(minutes) mins ago"
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        if let hours = formatter.string(for: Double(minutes)/60) {
            return "\(hours) hrs ago"
        }
        return ""
    }
}

@main
struct CasesWidget: Widget {
    let kind: String = Constants.widgetName

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CasesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("UK COVID-19 Statistics")
        .description("View the latest daily new cases and deaths in the UK.")
    }
}

struct CasesWidget_Previews: PreviewProvider {
    static var previews: some View {
        CasesWidgetEntryView(entry: SimpleEntry(date: Date(), cases: 0, deaths: 0, casesData: [], deathsData: []))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
