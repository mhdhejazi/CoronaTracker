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
		holeRadiusPercent = 0.5
		transparentCircleRadiusPercent = 0.6
		maxAngle = 180
		rotationAngle = 180
		drawEntryLabelsEnabled = false
		setExtraOffsets(left: 0, top: 100, right: 0, bottom: -300)

		rotationEnabled = false

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
		dataEntries.append(PieChartDataEntry(value: Double(report.stat.activeCount), label: L10n.Case.active))
		dataEntries.append(PieChartDataEntry(value: Double(report.stat.recoveredCount), label: L10n.Case.recovered))
		dataEntries.append(PieChartDataEntry(value: Double(report.stat.deathCount), label: L10n.Case.deaths))

		let dataSet = PieChartDataSet(entries: dataEntries, label: "")
		dataSet.colors = [.systemYellow, .systemGreen, .systemRed]
		dataSet.valueColors = [
			UIColor(hue: 0.13, saturation: 1.0, brightness: 0.4, alpha: 1.0),
			UIColor(hue: 0.3, saturation: 0.2, brightness: 1.0, alpha: 1.0),
			UIColor(hue: 0.03, saturation: 0.2, brightness: 1.0, alpha: 1.0)
		]
		dataSet.sliceSpace = 2
		dataSet.xValuePosition = .outsideSlice
		dataSet.yValuePosition = .insideSlice
		dataSet.entryLabelColor = .black
		dataSet.valueFont = .systemFont(ofSize: 14, weight: .bold)
		dataSet.valueFormatter = PercentValueFormatter()
		dataSet.selectionShift = 8

		data = PieChartData(dataSet: dataSet)

		animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
	}
}
