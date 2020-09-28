//
//  ContentView.swift
//  covid19
//
//  Created by An Trinh on 27/9/20.
//

import SwiftUI

enum Location: String, CaseIterable, Identifiable {
    case uk = "🇬🇧 United Kingdom"
    case england = "🏴󠁧󠁢󠁥󠁮󠁧󠁿 England"
    case northernIreland = "Northern Ireland"
    case scotland = "🏴󠁧󠁢󠁳󠁣󠁴󠁿 Scotland"
    case wales = "🏴󠁧󠁢󠁷󠁬󠁳󠁿 Wales"
    
    var id: String { self.rawValue }
}

struct ContentView: View {
    @Environment(\.openURL) var openURL
    @State private var locationSelection = Location.uk
    @ObservedObject private var viewModel = ViewModel()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        List {
            Section(footer: Text(viewModel.footerText)) {
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
                VStack(alignment: .leading, spacing: 10) {
                    Text("Cases")
                        .font(Font.title2.bold())
                    Image("cases")
                        .resizable()
                        .scaledToFit()
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
                            .font(Font.title2.bold())
                        Text("total")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 10)
            }
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Deaths")
                        .font(Font.title2.bold())
                    Image("deaths")
                        .resizable()
                        .scaledToFit()
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
                            .font(Font.title2.bold())
                        Text("total")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 10)
            }
            Section {
                Button(action: {
                    openURL(URL(string: "https://apps.apple.com/gb/story/id1532087825")!)
                }) {
                    Label("Get the Contact Tracing app", systemImage: "figure.stand.line.dotted.figure.stand")
                        .padding(.vertical)
                }
            }
            Section {
                Button(action: {
                    openURL(URL(string: "https://www.gov.uk/guidance/the-r-number-in-the-uk")!)
                }) {
                    Label("R-number and Growth Rate", systemImage: "number")
                        .padding(.vertical)
                }
            }
            Section {
                Button(action: {
                    openURL(URL(string: "https://coronavirus.data.gov.uk")!)
                }) {
                    Label("Source: coronavirus.data.gov.uk", systemImage: "link")
                        .padding(.vertical)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .onAppear {
            reloadData()
        }
        .onReceive(timer) { _ in
            updateIfNeeded()
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
        if seconds > 15*60 {
            viewModel.fetchData(locationSelection, clearData: false)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
