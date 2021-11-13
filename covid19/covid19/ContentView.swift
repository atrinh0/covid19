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
    @State private var locationSelection = Location.unitedKingdom
    @ObservedObject private var viewModel = ViewModel()
    @State private var casesChartCount = ChartCount.oneYear
    @State private var showRelativeChartData = false

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    private let chartHeight: CGFloat = 200

    var body: some View {
        NavigationView {
            List {
                VStack(alignment: .leading, spacing: 10) {
                    Text(viewModel.footerText)
                        .font(.caption)
                        .foregroundColor(.gray)
                    ZStack {
                        Color.gray.opacity(0.04)
                        Chart(data: viewModel.casesData.suffix(casesChartCount.numberOfDatapoints))
                            .chartStyle(
                                LineChartStyle(.line, lineColor: Constants.casesColor, lineWidth: 2)
                            )
                            .frame(height: chartHeight)
                        Chart(data: deathsData)
                            .chartStyle(
                                LineChartStyle(.line, lineColor: Constants.deathsColor, lineWidth: 2)
                            )
                            .frame(height: chartHeight)
                    }
                    Picker(selection: $casesChartCount) {
                        ForEach(ChartCount.allCases) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    } label: { }
                    .pickerStyle(.segmented)
                    Picker(selection: $showRelativeChartData) {
                        Text("Relative")
                            .tag(true)
                        Text("Emphasised")
                            .tag(false)
                    } label: { }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 5)
                    VStack(alignment: .leading) {
                        Text(viewModel.dailyLatestCases)
                            .font(Font.title2.bold())
                            .foregroundColor(Constants.casesColor) +
                        Text(viewModel.dailyCasesChange)
                            .font(Font.title2.bold())
                            .foregroundColor(.gray)
                        Text("new cases on \(viewModel.latestDate)")
                            .foregroundColor(.gray)
                    }
                    VStack(alignment: .leading) {
                        Text(viewModel.weeklyLatestCases)
                            .font(Font.title2.bold())
                            .foregroundColor(Constants.casesColor) +
                        Text(viewModel.weeklyCasesChange)
                            .font(Font.title2.bold())
                            .foregroundColor(.gray)
                        Text("new cases in the last 7 days")
                            .foregroundColor(.gray)
                    }
                    VStack(alignment: .leading) {
                        Text(viewModel.totalCases)
                            .font(Font.title2.bold())
                            .foregroundColor(Constants.casesColor) +
                        Text(" total cases")
                            .foregroundColor(.gray)
                    }
                    VStack(alignment: .leading) {
                        Text(viewModel.dailyLatestDeaths)
                            .font(Font.title2.bold())
                            .foregroundColor(Constants.deathsColor) +
                        Text(viewModel.dailyDeathsChange)
                            .font(Font.title2.bold())
                            .foregroundColor(.gray)
                        Text("new deaths on \(viewModel.latestDate)")
                            .foregroundColor(.gray)
                    }
                    VStack(alignment: .leading) {
                        Text(viewModel.weeklyLatestDeaths)
                            .font(Font.title2.bold())
                            .foregroundColor(Constants.deathsColor) +
                        Text(viewModel.weeklyDeathsChange)
                            .font(Font.title2.bold())
                            .foregroundColor(.gray)
                        Text("new deaths in the last 7 days")
                            .foregroundColor(.gray)
                    }
                    VStack(alignment: .leading) {
                        Text(viewModel.totalDeaths)
                            .font(Font.title2.bold())
                            .foregroundColor(Constants.deathsColor) +
                        Text(" total deaths")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(Text(locationSelection.rawValue))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: sortButton)
        }
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
        .navigationViewStyle(.stack)
    }

    private func reloadData() {
        viewModel.fetchData(locationSelection, shouldClearData: true)
        updateIfNeeded()
    }

    private func updateIfNeeded() {
        if viewModel.isLoading || viewModel.isReloading {
            return
        }

        // check every 15 minutes
        let interval = abs(viewModel.lastChecked.timeIntervalSinceNow)
        if interval >= Constants.updateInterval {
            viewModel.fetchData(locationSelection, shouldClearData: false)
        }
    }

    private var deathsData: [Double] {
        showRelativeChartData ? viewModel.relativeDeathsData.suffix(casesChartCount.numberOfDatapoints) :
        viewModel.rawDeathsData.suffix(casesChartCount.numberOfDatapoints)
    }

    private var sortButton: some View {
        Menu {
            Picker(selection: $locationSelection) {
                ForEach(Location.allCases) {
                    Text($0.rawValue)
                        .tag($0)
                }
            } label: { Text("Location") }
        } label: {
            Image(systemName: "chevron.down.circle.fill")
                .font(Font.title2.bold())
        }
        .onChange(of: locationSelection) { _ in
            reloadData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
