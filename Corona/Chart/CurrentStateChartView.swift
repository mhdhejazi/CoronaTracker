//
//  CurrentStateChart.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/7/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

class CurrentStateChartView: PieChartView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		usePercentValuesEnabled = true
		holeColor = nil
		rotationAngle = 0
		drawEntryLabelsEnabled = false
		setExtraOffsets(left: 0, top: 5, right: 0, bottom: -10)

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

	func update(report: Report?) {
		guard let report = report else {
			data = nil
			return
		}

		var dataEntries: [PieChartDataEntry] = []
		dataEntries.append(PieChartDataEntry(value: Double(report.stat.existingCount), label: "Existing"))
		dataEntries.append(PieChartDataEntry(value: Double(report.stat.deathCount), label: "Deaths"))
		dataEntries.append(PieChartDataEntry(value: Double(report.stat.recoveredCount), label: "Recovered"))

		let dataSet = PieChartDataSet(entries: dataEntries, label: "")
		dataSet.colors = [.systemGray, .systemRed, .systemGreen]
		dataSet.sliceSpace = 2
		dataSet.xValuePosition = .outsideSlice
		dataSet.yValuePosition = .insideSlice
		dataSet.valueTextColor = .white
		dataSet.entryLabelColor = .black
		dataSet.valueFont = .systemFont(ofSize: 14, weight: .bold)
		dataSet.valueFormatter = PercentValueFormatter()

		data = PieChartData(dataSet: dataSet)

		animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
	}
}
