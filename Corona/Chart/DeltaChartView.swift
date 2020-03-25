//
//  DeltaChartView.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/23/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

class DeltaChartView: BarChartView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

//		xAxis.drawGridLinesEnabled = false
		xAxis.drawGridLinesEnabled = false
		xAxis.labelPosition = .bottom
		xAxis.labelTextColor = SystemColor.secondaryLabel
		xAxis.valueFormatter = DayAxisValueFormatter(chartView: self)

//		leftAxis.drawGridLinesEnabled = false
		leftAxis.gridColor = .lightGray
		leftAxis.gridLineDashLengths = [3, 3]
		leftAxis.labelTextColor = SystemColor.secondaryLabel
		leftAxis.valueFormatter = DefaultAxisValueFormatter() { value, axis in
			value.kmFormatted
		}

		rightAxis.enabled = false

		dragEnabled = false
		scaleXEnabled = false
		scaleYEnabled = false

		fitBars = true

		noDataTextColor = .systemGray
		noDataFont = .systemFont(ofSize: 15)

		marker = SimpleMarkerView(chartView: self)

		initializeLegend(legend)
	}

	private func initializeLegend(_ legend: Legend) {
		legend.textColor = SystemColor.secondaryLabel
		legend.font = .systemFont(ofSize: 12, weight: .regular)
		legend.form = .none
		legend.formSize = 0
		legend.horizontalAlignment = .center
		legend.xEntrySpace = 0
		legend.formToTextSpace = 0
		legend.stackSpace = 0
	}

	func update(series: TimeSeries?, animated: Bool) {
		guard let series = series else {
			data = nil
			return
		}

		let changes = series.changes()
		let dates = changes.keys.sorted().drop { changes[$0]?.isZero == true }

		var entries = [BarChartDataEntry]()
		for date in dates {
			let value = Double(changes[date]!.newConfirmed)
			let entry = BarChartDataEntry(x: Double(date.referenceDays), y: value)
			entries.append(entry)
		}

		let label = L10n.Chart.delta
		let dataSet = BarChartDataSet(entries: entries, label: label)
		dataSet.colors = [.systemOrange]

		dataSet.drawValuesEnabled = false

		data = BarChartData(dataSet: dataSet)

		if animated {
			animate(yAxisDuration: 2)
		}
	}
}
