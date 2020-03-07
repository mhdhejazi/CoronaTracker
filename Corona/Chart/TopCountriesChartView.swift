//
//  CurrentStateChart.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/7/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

class TopCountriesChartView: BarChartView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

//		xAxis.drawGridLinesEnabled = false
		xAxis.drawGridLinesEnabled = false
		xAxis.labelPosition = .bottom
		xAxis.labelTextColor = SystemColor.secondaryLabel
		xAxis.valueFormatter = DefaultAxisValueFormatter(block: { value, axis in
			guard let entry = self.barData?.dataSets.first?.entryForIndex(Int(value)) as? BarChartDataEntry,
				let report = entry.data as? Report else { return value.description }

			return report.region.name.replacingOccurrences(of: " ", with: "\n")
		})

//		leftAxis.drawGridLinesEnabled = false
		leftAxis.gridColor = .lightGray
		leftAxis.gridLineDashLengths = [3, 3]
		leftAxis.labelTextColor = SystemColor.secondaryLabel
		leftAxis.valueFormatter = DefaultAxisValueFormatter() { value, axis in
			value.kmFormatted
		}

		rightAxis.enabled = false

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
		legend.form = .circle
		legend.formSize = 12
		legend.horizontalAlignment = .center
		legend.xEntrySpace = 10
	}

	func update(reports: [Report]) {
		let reports = DataManager.instance.topReports

		var entries = [BarChartDataEntry]()
		for i in reports.indices {
			let report = reports[i]
//			let entry = BarChartDataEntry(x: Double(i), yValues: [
//				Double(report.data.deathCount), Double(report.data.existingCount), Double(report.data.recoveredCount)
//			])
			let entry = BarChartDataEntry(x: Double(i), y: Double(report.stat.confirmedCount))
			entry.data = report
			entries.append(entry)
		}

		let dataSet = BarChartDataSet(entries: entries, label: "Most affected countries")
		dataSet.colors = ChartColorTemplates.pastel()
		dataSet.stackLabels = ["Deaths", "Existing", "Recovered"]

//		dataSet.drawValuesEnabled = false
		dataSet.valueTextColor = SystemColor.secondaryLabel
		dataSet.valueFont = .systemFont(ofSize: 12, weight: .regular)
		dataSet.valueFormatter = DefaultValueFormatter(block: { value, entry, dataSetIndex, viewPortHandler in
			value.kmFormatted
		})

		data = BarChartData(dataSet: dataSet)

		animate(yAxisDuration: 2)
	}
}
