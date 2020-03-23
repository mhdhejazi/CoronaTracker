//
//  CurrentStateChart.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/7/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

class HistoryChartView: LineChartView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		xAxis.gridColor = .lightGray
		xAxis.gridLineDashLengths = [3, 3]
		xAxis.labelPosition = .bottom
		xAxis.labelTextColor = SystemColor.secondaryLabel
		xAxis.valueFormatter = DayAxisValueFormatter(chartView: self)

//		leftAxis.drawGridLinesEnabled = false
		leftAxis.gridColor = .lightGray
		leftAxis.gridLineDashLengths = [3, 3]
		leftAxis.labelTextColor = SystemColor.secondaryLabel
		leftAxis.valueFormatter = DefaultAxisValueFormatter { value, _ in
			value.kmFormatted
		}

		rightAxis.enabled = false

		dragEnabled = false
		scaleXEnabled = false
		scaleYEnabled = false

		noDataTextColor = .systemGray
		noDataFont = .systemFont(ofSize: 15)

		marker = SimpleMarkerView(chartView: self)

		initializeLegend(legend)
	}

	private func initializeLegend(_ legend: Legend) {
		legend.textColor = SystemColor.secondaryLabel
		legend.font = .systemFont(ofSize: 12, weight: .regular)
		legend.form = .circle
		legend.formSize = 12
		legend.horizontalAlignment = .center
		legend.xEntrySpace = 10
	}

	func update(series: TimeSeries?) {
		guard let series = series else {
			data = nil
			return
		}

		let dates = series.series.keys.sorted()
		let confirmedEntries = dates.map {
			ChartDataEntry(x: Double($0.referenceDays), y: Double(series.series[$0]?.confirmedCount ?? 0))
		}
		let recoveredEntries = dates.map {
			ChartDataEntry(x: Double($0.referenceDays), y: Double(series.series[$0]?.recoveredCount ?? 0))
		}
		let deathsEntries = dates.map {
			ChartDataEntry(x: Double($0.referenceDays), y: Double(series.series[$0]?.deathCount ?? 0))
		}

		let entries = [confirmedEntries, deathsEntries, recoveredEntries]
		let labels = [L10n.Case.confirmed, L10n.Case.deaths, L10n.Case.recovered]
		let colors = [UIColor.systemOrange, .systemRed, .systemGreen]

		var dataSets = [LineChartDataSet]()
		for index in entries.indices {
			let dataSet = LineChartDataSet(entries: entries[index], label: labels[index])
			dataSet.mode = .cubicBezier
			dataSet.drawValuesEnabled = false
			dataSet.colors = [colors[index]]

//			dataSet.drawCirclesEnabled = false
			dataSet.circleRadius = 2.5
			dataSet.circleColors = [colors[index].withAlphaComponent(0.75)]

			dataSet.drawCircleHoleEnabled = false
			dataSet.circleHoleRadius = 1

			dataSet.lineWidth = 1
			dataSet.highlightLineWidth = 0

			dataSets.append(dataSet)
		}

		data = LineChartData(dataSets: dataSets)

		animate(xAxisDuration: 2)
	}
}
