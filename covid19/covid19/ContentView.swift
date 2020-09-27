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
    
    var body: some View {
        List {
            Section(footer: Text("Last updated on Saturday 26 September 2020\nLast checked 0 minutes ago")) {
                HStack() {
                    Text(locationSelection.rawValue)
                        .lineLimit(0)
                        .font(Font.title2.bold())
                    Spacer()
                    Picker(selection: $locationSelection, label:
                            Image(systemName: "chevron.down.circle.fill")
                            .imageScale(.large)
                    ) {
                        ForEach(Location.allCases) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding([.vertical])
            }
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Cases")
                        .font(Font.title.bold())
                    Image(systemName: "paperplane")
                    VStack(alignment: .leading) {
                        Text("+6,042")
                            .font(Font.title2.bold()) +
                            Text(" (-832)")
                            .font(Font.title2.bold())
                            .foregroundColor(.gray)
                        Text("new cases on Saturday 26 September")
                            .foregroundColor(.gray)
                    }
                    VStack(alignment: .leading) {
                        Text("429,277")
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
                        .font(Font.title.bold())
                    Image(systemName: "paperplane")
                    VStack(alignment: .leading) {
                        Text("+34")
                            .font(Font.title2.bold()) +
                            Text(" (+2)")
                            .font(Font.title2.bold())
                            .foregroundColor(.gray)
                        Text("new cases on Saturday 26 September")
                            .foregroundColor(.gray)
                    }
                    VStack(alignment: .leading) {
                        Text("41,971")
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
                Button(action: {
                    openURL(URL(string: "https://www.gov.uk/guidance/the-r-number-in-the-uk")!)
                }) {
                    Label("R-number and Growth Rate", systemImage: "number")
                        .padding(.vertical)
                }
                Button(action: {
                    openURL(URL(string: "https://coronavirus.data.gov.uk")!)
                }) {
                    Label("Source: coronavirus.data.gov.uk", systemImage: "link")
                        .padding(.vertical)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
