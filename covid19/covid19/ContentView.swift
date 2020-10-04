//
//  ContentView.swift
//  covid19
//
//  Created by An Trinh on 27/9/20.
//

import SwiftUI
import Charts
import WidgetKit

struct ContentView: View {
    @Environment(\.openURL) var openURL
    @State private var locationSelection = Location.uk
    @ObservedObject private var viewModel = ViewModel()
    @State private var casesChartCount = ChartCount.all
    @State private var deathsChartCount = ChartCount.all
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        List {
            Section {
                HStack() {
                    Text(locationSelection.rawValue)
                        .lineLimit(0)
                        .font(Font.title2.bold())
                    Spacer()
                    Picker(selection: $locationSelection, label:
                            Image(systemName: "chevron.down.circle.fill")
                            .font(Font.title2.bold())
                    ) {
                        ForEach(Location.allCases) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    .onChange(of: locationSelection) { _ in
                        reloadData()
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding([.vertical])
            }
            Section {
                Text(viewModel.footerText)
                    .padding([.vertical])
            }
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(locationSelection.flag()) Cases")
                        .font(Font.title2.bold())
                    Chart(data: viewModel.casesData.suffix(casesChartCount.numberOfDatapoints()))
                        .chartStyle(
                            LineChartStyle(.line, lineColor: .orange, lineWidth: 2)
                        )
                        .frame(height: 200)
                    Picker(selection: $casesChartCount, label:
                            Text("")
                    ) {
                        ForEach(ChartCount.allCases) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom, 5)
                    VStack(alignment: .leading) {
                        Text(viewModel.latestCases)
                            .font(Font.title2.bold())
                            .foregroundColor(.orange) +
                            Text(viewModel.casesChange)
                            .font(Font.title2.bold())
                            .foregroundColor(.gray)
                        Text("new cases on \(viewModel.latestDate)")
                            .foregroundColor(.gray)
                    }
                    VStack(alignment: .leading) {
                        Text(viewModel.totalCases)
                            .font(Font.title2.bold()) +
                        Text(" total")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 10)
            }
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(locationSelection.flag()) Deaths")
                        .font(Font.title2.bold())
                    Chart(data: viewModel.deathsData.suffix(deathsChartCount.numberOfDatapoints()))
                        .chartStyle(
                            LineChartStyle(.line, lineColor: .red, lineWidth: 2)
                        )
                        .frame(height: 200)
                    Picker(selection: $deathsChartCount, label:
                            Text("")
                    ) {
                        ForEach(ChartCount.allCases) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom, 5)
                    VStack(alignment: .leading) {
                        Text(viewModel.latestDeaths)
                            .font(Font.title2.bold())
                            .foregroundColor(.red) +
                            Text(viewModel.deathsChange)
                            .font(Font.title2.bold())
                            .foregroundColor(.gray)
                        Text("new deaths on \(viewModel.latestDate)")
                            .foregroundColor(.gray)
                    }
                    VStack(alignment: .leading) {
                        Text(viewModel.totalDeaths)
                            .font(Font.title2.bold()) +
                        Text(" total")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 10)
            }
            Section {
                Link(destination: Constants.appStoreStory) {
                    Label("Get the Contact Tracing app", systemImage: "figure.stand.line.dotted.figure.stand")
                        .padding(.vertical)
                        .font(Font.body.bold())
                }
                Link(destination: Constants.rNumberUK) {
                    Label("R-number and Growth Rate", systemImage: "number")
                        .padding(.vertical)
                        .font(Font.body.bold())
                }
                Link(destination: Constants.sourceGovUK) {
                    Label("Source: coronavirus.data.gov.uk", systemImage: "link")
                        .padding(.vertical)
                        .font(Font.body.bold())
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .onAppear {
            reloadData()
            WidgetCenter.shared.reloadTimelines(ofKind: Constants.widgetName)
        }
        .onReceive(timer) { _ in
            updateIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            reloadData()
            WidgetCenter.shared.reloadTimelines(ofKind: Constants.widgetName)
        }
    }
    
    private func reloadData() {
        viewModel.fetchData(locationSelection, clearData: true)
        updateIfNeeded()
    }
    
    private func updateIfNeeded() {
        if viewModel.isLoading || viewModel.isReloading {
            return
        }
        
        // check every 15 minutes
        let interval = abs(viewModel.lastChecked.timeIntervalSinceNow)
        let seconds = Int(interval)
        if seconds >= 15*60 {
            viewModel.fetchData(locationSelection, clearData: false)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
