//
//  ContentView.swift
//  covid19
//
//  Created by An Trinh on 27/9/20.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @Environment(\.openURL) var openURL
    @State private var locationSelection: Location = .england
    @ObservedObject private var viewModel = ViewModel()
    @State private var casesChartCount: ChartCount = .sixMonths

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            ScrollView {
                chartAndDataView
            }
            .navigationTitle(Text(locationSelection.rawValue))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: sortButton)
            .refreshable {
                reloadDataAndWidget()
            }
        }
        .task {
            reloadDataAndWidget()
        }
        .onReceive(timer) { _ in
            updateIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            reloadDataAndWidget()
        }
        .navigationViewStyle(.stack)
    }

    private var chartAndDataView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.footerText)
                .font(.caption)
                .foregroundColor(.secondary)
            Picker(selection: $casesChartCount) {
                ForEach(ChartCount.allCases) {
                    Text($0.rawValue)
                        .tag($0)
                        .accessibilityLabel(Text($0.voiceoverDescription))
                }
            } label: { }
            .pickerStyle(.segmented)
            CasesChart(data: data)
            casesSummary
            DeathsChart(data: data)
            deathsSummary
        }
        .padding()
    }

    private var casesSummary: some View {
        Group {
            VStack(alignment: .leading) {
                Text(viewModel.weeklyLatestCases)
                    .font(Font.title2.bold())
                    .foregroundColor(Constants.casesColor) +
                Text(viewModel.weeklyCasesChange)
                    .font(Font.title2.bold())
                    .foregroundColor(.secondary)
                Group {
                    Text("new weekly cases until ") +
                    Text(viewModel.latestDataPointDate, style: .date)
                }
                .foregroundColor(.secondary)
            }
            VStack(alignment: .leading) {
                Text(viewModel.totalCases)
                    .font(Font.title2.bold())
                    .foregroundColor(Constants.casesColor) +
                Text(" total cases up to ")
                    .foregroundColor(.secondary) +
                Text(viewModel.latestDataPointDate, style: .date)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var deathsSummary: some View {
        Group {
            VStack(alignment: .leading) {
                Text(viewModel.weeklyLatestDeaths)
                    .font(Font.title2.bold())
                    .foregroundColor(Constants.deathsColor) +
                Text(viewModel.weeklyDeathsChange)
                    .font(Font.title2.bold())
                    .foregroundColor(.secondary)
                Group {
                    Text("new weekly deaths until ") +
                    Text(viewModel.latestDataPointDate, style: .date)
                }
                .foregroundColor(.secondary)
            }
            VStack(alignment: .leading) {
                Text(viewModel.totalDeaths)
                    .font(Font.title2.bold())
                    .foregroundColor(Constants.deathsColor) +
                Text(" total deaths up to ")
                    .foregroundColor(.secondary) +
                Text(viewModel.latestDataPointDate, style: .date)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func reloadDataAndWidget() {
        reloadData()
        WidgetCenter.shared.reloadTimelines(ofKind: Constants.widgetName)
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

    private var data: [Info] {
        guard viewModel.data.count > casesChartCount.numberOfDatapoints else {
            return viewModel.data
        }

        return Array(viewModel.data.prefix(upTo: casesChartCount.numberOfDatapoints))
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
                .accessibilityLabel(Text("Select nation"))
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
