//
//  DeltaChartView.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/23/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

class DeltaChartView: BaseBarChartView, RegionChartView {
	override func initializeView() {
		super.initializeView()

		chartView.xAxis.drawGridLinesEnabled = false
		chartView.xAxis.valueFormatter = DayAxisValueFormatter(chartView: chartView)

		chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter() { value, axis in
			value.kmFormatted
		}

		chartView.marker = SimpleMarkerView(chartView: chartView)

		chartView.legend.setCustom(entries: [
			LegendEntry(label: "↑ " + L10n.Chart.Delta.increasing, form: .circle, formSize: 12,
						formLineWidth: 0, formLineDashPhase: 0, formLineDashLengths: nil, formColor: .systemOrange),
			LegendEntry(label: "↓ " + L10n.Chart.Delta.decreasing, form: .circle, formSize: 12,
						formLineWidth: 0, formLineDashPhase: 0, formLineDashLengths: nil, formColor: .systemBlue),
		])
	}

	func update(region: Region?, animated: Bool) {
		guard let series = region?.timeSeries else {
			chartView.data = nil
			return
		}

		title = L10n.Chart.delta

		let changes = series.changes()
		let dates = changes.keys.sorted().drop { changes[$0]?.isZero == true }

		var entries = [BarChartDataEntry]()
		for date in dates {
			let value = Double(changes[date]!.newConfirmed)
			let entry = BarChartDataEntry(x: Double(date.referenceDays), y: value)
			entries.append(entry)
		}

		var colors = [UIColor]()
		for i in entries.indices.reversed() {
			var color = UIColor.systemOrange
			if i > 0 {
				let currentEntry = entries[i]
				let previousEntry = entries[i - 1]
				if currentEntry.y < previousEntry.y {
					color = .systemBlue
				}
			}
			colors.append(color)
		}

		let label = L10n.Chart.delta
		let dataSet = BarChartDataSet(entries: entries, label: label)
		dataSet.colors = colors.reversed()

		dataSet.drawValuesEnabled = false

		chartView.data = BarChartData(dataSet: dataSet)

		if animated {
			chartView.animate(yAxisDuration: 2)
		}
	}
}
