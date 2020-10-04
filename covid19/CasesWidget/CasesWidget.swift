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
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), cases: 0, deaths: 0, casesData: [], deathsData: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        URLSession.shared.dataTask(with: URL(string: Constants.url())!) { (data, _, _) in
            guard let data = data else { return }
            let response = try! JSONDecoder().decode(ResponseData.self, from: data)
            let entry = SimpleEntry(response: response)
            completion(entry)
        }.resume()
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        URLSession.shared.dataTask(with: URL(string: Constants.url())!) { (data, _, _) in
            guard let data = data else { return }
            let response = try! JSONDecoder().decode(ResponseData.self, from: data)
            let entry = SimpleEntry(response: response)
            completion(Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .minute, value: 15, to: Date())!)))
        }.resume()
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let cases: Int?
    let deaths: Int?
    let casesData: [Double]
    let deathsData: [Double]
    
    init(date: Date, cases: Int, deaths: Int, casesData: [Double], deathsData: [Double]) {
        self.date = date
        self.cases = cases
        self.deaths = deaths
        self.casesData = casesData
        self.deathsData = deathsData
    }
    
    init(date: Date? = Date(), response: ResponseData) {
        self.date = date ?? Date()
        if let firstRecord = response.data.first, let cases = firstRecord.cases, let deaths = firstRecord.deaths {
            self.cases = cases
            self.deaths = deaths
        } else {
            self.cases = 0
            self.deaths = 0
        }
        
        let casesArray = response.data.map { Double($0.cases ?? 0) }
        let deathsArray = response.data.map { Double($0.deaths ?? 0) }
        let maxCases = (casesArray.max() ?? 1.0) * 1.05
        let maxDeaths = (deathsArray.max() ?? 1.0) * 1.05
        let commonMax = max(maxCases, maxDeaths)
        self.casesData = casesArray.map { $0/commonMax }.reversed()
        self.deathsData = deathsArray.map { $0/commonMax }.reversed()
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
        VStack(alignment: .leading, spacing: isTall ? 5 : 0) {
            ZStack {
                Chart(data: entry.casesData.suffix(isWide ? 183 : 91))
                    .chartStyle(
                        LineChartStyle(.line, lineColor: .orange, lineWidth: 2)
                    )
                Chart(data: entry.deathsData.suffix(isWide ? 183 : 91))
                    .chartStyle(
                        LineChartStyle(.line, lineColor: .red, lineWidth: 2)
                    )
            }
            .padding(.horizontal, -10)
            if isWide {
                HStack(alignment: .bottom, spacing: isTall ? 5 : 0) {
                    HStack {
                        Text(formatCount(val: entry.cases))
                            .font(Font.title2.bold())
                            .foregroundColor(.orange) +
                            Text(" cases")
                            .font(.caption)
                        Spacer()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    HStack {
                        Text(formatCount(val: entry.deaths))
                            .font(Font.title2.bold())
                            .foregroundColor(.red) +
                            Text(" deaths")
                            .font(.caption)
                        Spacer()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
            } else {
                VStack(alignment: .leading, spacing: isTall ? 5 : 0) {
                    HStack {
                        Text(formatCount(val: entry.cases))
                            .font(Font.title2.bold())
                            .foregroundColor(.orange) +
                            Text(" cases")
                            .font(.caption)
                    }
                    HStack {
                        Text(formatCount(val: entry.deaths))
                            .font(Font.title2.bold())
                            .foregroundColor(.red) +
                            Text(" deaths")
                            .font(.caption)
                    }
                }
            }
        }
        .padding(10)
    }
    
    private func formatCount(val: Int?) -> String {
        if let val = val {
            return "+\(val.formattedWithSeparator)"
        }
        return " "
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
