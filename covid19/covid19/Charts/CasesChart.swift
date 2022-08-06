//
//  CasesChart.swift
//  covid19
//
//  Created by An Trinh on 30/07/2022.
//

import SwiftUI
import Charts

struct CasesChart: View {
    var data: [Info]

    var body: some View {
        Chart(data, id: \.self) {
            LineMark(
                x: .value("Date", $0.date.toDate() ?? Date()),
                y: .value("Cases", $0.cases)
            )
            .foregroundStyle(Constants.casesColor)
        }
        .frame(height: Constants.chartHeight)
        .accessibilityElement()
        .accessibilityChartDescriptor(self)
    }
}

extension CasesChart: AXChartDescriptorRepresentable {
    func makeChartDescriptor() -> AXChartDescriptor {
        let xAxis = AXNumericDataAxisDescriptor(
            title: "Date",
            range: Double(0)...Double(data.count),
            gridlinePositions: []
        ) { dateDescription(dateString: data.reversed()[Int($0)].date) }

        let min = Double(data.map(\.cases).min() ?? 0)
        let max = Double(data.map(\.cases).max() ?? 0)

        let yAxis = AXNumericDataAxisDescriptor(
            title: "Cases",
            range: min...max,
            gridlinePositions: []
        ) { value in "\(Int(value)) cases" }

        let series = AXDataSeriesDescriptor(
            name: "Cases",
            isContinuous: true,
            dataPoints: data.reversed().enumerated().map { index, point in
                .init(x: Double(index),
                      y: Double(point.cases))
            }
        )

        return AXChartDescriptor(
            title: "Cases chart",
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