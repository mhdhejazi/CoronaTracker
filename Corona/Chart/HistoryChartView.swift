//
//  CurrentStateChart.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/7/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

class HistoryChartView: BaseLineChartView {
	override func initializeView() {
		super.initializeView()

		chartView.xAxis.valueFormatter = DayAxisValueFormatter(chartView: chartView)

		let marker = SimpleMarkerView(chartView: chartView)
		marker.font = .systemFont(ofSize: 13 * fontScale)
		chartView.marker = marker
	}

	override func update(region: Region?, animated: Bool) {
		super.update(region: region, animated: animated)

		guard let series = region?.timeSeries else {
			chartView.data = nil
			return
		}

		title = L10n.Chart.history

		let dates = series.series.keys.sorted().drop { series.series[$0]?.isZero == true }
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
		for i in entries.indices {
			let dataSet = LineChartDataSet(entries: entries[i], label: labels[i])
			dataSet.mode = .cubicBezier
			dataSet.drawValuesEnabled = false
			dataSet.colors = [colors[i].withAlphaComponent(0.75)]

//			dataSet.drawCirclesEnabled = false
			dataSet.circleRadius = (confirmedEntries.count < 60 ? 2 : 1.8) * fontScale
			dataSet.circleColors = [colors[i]]

			dataSet.drawCircleHoleEnabled = false
			dataSet.circleHoleRadius = 1 * fontScale

			dataSet.lineWidth = 1 * fontScale
			dataSet.highlightLineWidth = 1 * fontScale
			dataSet.highlightColor = UIColor.lightGray.withAlphaComponent(0.5)
			dataSet.drawHorizontalHighlightIndicatorEnabled = false

			dataSets.append(dataSet)
		}

		chartView.data = LineChartData(dataSets: dataSets)

		if animated {
			chartView.animate(xAxisDuration: 2)
		}
	}
}
