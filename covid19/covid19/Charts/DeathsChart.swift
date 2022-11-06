//
//  DeathsChart.swift
//  covid19
//
//  Created by An Trinh on 30/07/2022.
//

import SwiftUI
import Charts

struct DeathsChart: View {
    var data: [Info]

    var body: some View {
        Chart(data, id: \.self) {
            LineMark(
                x: .value("Date", $0.day),
                y: .value("Deaths", $0.deaths)
            )
            .foregroundStyle(Constants.deathsColor)
        }
        .frame(height: Constants.chartHeight)
        .accessibilityElement()
        .accessibilityChartDescriptor(self)
    }
}

extension DeathsChart: AXChartDescriptorRepresentable {
    func makeChartDescriptor() -> AXChartDescriptor {
        let xAxis = AXNumericDataAxisDescriptor(
            title: "Date",
            range: Double(0)...Double(data.count),
            gridlinePositions: []
        ) { dateDescription(dateString: data.reversed()[Int($0)].date) }

        let min = Double(data.map(\.deaths).min() ?? 0)
        let max = Double(data.map(\.deaths).max() ?? 0)

        let yAxis = AXNumericDataAxisDescriptor(
            title: "Deaths",
            range: min...max,
            gridlinePositions: []
        ) { value in "\(Int(value)) deaths" }

        let series = AXDataSeriesDescriptor(
            name: "Deaths",
            isContinuous: true,
            dataPoints: data.reversed().enumerated().map { index, point in
                .init(x: Double(index),
                      y: Double(point.deaths))
            }
        )

        return AXChartDescriptor(
            title: "Deaths chart",
            summary: nil,
            xAxis: xAxis,
            yAxis: yAxis,
            additionalAxes: [],
            series: [series]
        )
    }

    private func dateDescription(dateString: String) -> String {
        let date = dateString.toDate() ?? Date()
        return date.formatted(date: .complete, time: .omitted)
    }
}
