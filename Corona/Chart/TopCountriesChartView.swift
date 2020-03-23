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
	var isLogarithmic = false {
		didSet {
			self.clear()
			self.update()
		}
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

//		xAxis.drawGridLinesEnabled = false
		xAxis.drawGridLinesEnabled = false
		xAxis.labelPosition = .bottom
		xAxis.labelTextColor = SystemColor.secondaryLabel
		xAxis.valueFormatter = DefaultAxisValueFormatter(block: { value, axis in
			guard let entry = self.barData?.dataSets.first?.entryForIndex(Int(value)) as? BarChartDataEntry,
				let region = entry.data as? Region else { return value.description }

			return region.localizedName.replacingOccurrences(of: " ", with: "\n")
		})
		/// Rotate labels in other languages
		if !Locale.current.isEnglish {
			xAxis.labelRotationAngle = 45
		}

//		leftAxis.drawGridLinesEnabled = false
		leftAxis.gridColor = .lightGray
		leftAxis.gridLineDashLengths = [3, 3]
		leftAxis.labelTextColor = SystemColor.secondaryLabel
		leftAxis.valueFormatter = DefaultAxisValueFormatter() { value, axis in
			self.isLogarithmic ? pow(10, value).kmFormatted : value.kmFormatted
		}

		rightAxis.enabled = false

		dragEnabled = false
		scaleXEnabled = false
		scaleYEnabled = false

		fitBars = true

		noDataTextColor = .systemGray
		noDataFont = .systemFont(ofSize: 15)

		let simpleMarker = SimpleMarkerView(chartView: self) { (entry, highlight) in
			guard let region = entry.data as? Region else { return entry.y.kmFormatted }
			return region.report?.stat.description ?? entry.y.kmFormatted
		}
		simpleMarker.timeout = 5
		marker = simpleMarker

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

	func update() {
		let regions = DataManager.instance.topCountries

		var entries = [BarChartDataEntry]()
		for i in regions.indices {
			let region = regions[i]
			var value = Double(region.report?.stat.confirmedCount ?? 0)
			if isLogarithmic {
				value = log10(value)
			}
			let entry = BarChartDataEntry(x: Double(i), y: value)
			entry.data = region
			entries.append(entry)
		}

		let label = isLogarithmic ? L10n.Chart.logarithmic : L10n.Chart.topCountries
		let dataSet = BarChartDataSet(entries: entries, label: label)
		dataSet.colors = ChartColorTemplates.pastel()

//		dataSet.drawValuesEnabled = false
		dataSet.valueTextColor = SystemColor.secondaryLabel
		dataSet.valueFont = .systemFont(ofSize: 12, weight: .regular)
		dataSet.valueFormatter = DefaultValueFormatter(block: { value, entry, dataSetIndex, viewPortHandler in
			guard let region = entry.data as? Region else { return value.kmFormatted }
			return region.report?.stat.confirmedCount.kmFormatted ?? value.kmFormatted
		})

		if isLogarithmic {
			leftAxis.axisMinimum = 2
			leftAxis.axisMaximum = 6
			leftAxis.labelCount = 4
		}
		else {
			leftAxis.resetCustomAxisMin()
			leftAxis.resetCustomAxisMax()
		}

		data = BarChartData(dataSet: dataSet)

		animate(yAxisDuration: 2)
	}
}
