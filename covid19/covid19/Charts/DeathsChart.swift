//
//  DeathsChart.swift
//  covid19
//
//  Created by An Trinh on 30/07/2022.
//

import SwiftUI
import Charts

struct DeathsChart: View {
    @State private var selectedElement: Info?

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
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { value in
                                let element = findElement(location: value.location, proxy: proxy, geometry: geo)
                                if selectedElement?.day == element?.day {
                                    selectedElement = nil
                                } else {
                                    selectedElement = element
                                }
                            }
                            .exclusively(
                                before: DragGesture()
                                    .onChanged { value in
                                        selectedElement = findElement(location: value.location,
                                                                      proxy: proxy,
                                                                      geometry: geo)
                                    }
                            )
                    )
            }
        }
        .chartBackground { proxy in
            ZStack(alignment: .topLeading) {
                GeometryReader { geo in
                    if let selectedElement,
                       let dateInterval = Calendar.current.dateInterval(of: .day, for: selectedElement.day) {
                        let startPositionX1 = proxy.position(forX: dateInterval.start) ?? 0

                        let lineX = startPositionX1 + geo[proxy.plotAreaFrame].origin.x
                        let lineHeight = geo[proxy.plotAreaFrame].maxY
                        let boxWidth: CGFloat = 110
                        let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2))

                        Rectangle()
                            .fill(.blue)
                            .frame(width: 2, height: lineHeight)
                            .position(x: lineX, y: lineHeight / 2)

                        VStack(alignment: .center) {
                            Text("\(selectedElement.day, format: .dateTime.year().month().day())")
                                .font(.callout.bold())
                                .foregroundStyle(.primary)
                            Text("\(selectedElement.deaths, format: .number)")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        }
                        .accessibilityElement(children: .combine)
                        .frame(width: boxWidth, alignment: .center)
                        .background {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.background)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.quaternary)
                            }
                            .padding(.horizontal, -8)
                            .padding(.vertical, -4)
                        }
                        .offset(x: boxOffset)
                    }
                }
            }
        }
        .onChange(of: data) { newData in
            if let selectedElement {
                if !newData.contains(selectedElement) || newData.isEmpty {
                    self.selectedElement = nil
                }
            }
        }
    }

    private func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> Info? {
        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            var minDistance: TimeInterval = .infinity
            var index: Int?
            for salesDataIndex in data.indices {
                let nthSalesDataDistance = data[salesDataIndex].day.distance(to: date)
                if abs(nthSalesDataDistance) < minDistance {
                    minDistance = abs(nthSalesDataDistance)
                    index = salesDataIndex
                }
            }
            if let index {
                return data[index]
            }
        }
        return nil
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
