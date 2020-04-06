//
//  TopChartView.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/7/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

class TopChartView: BaseBarChartView {
	private var colors: [UIColor] {
		switch mode {
		case .confirmed: return defaultColors
		case .active: return [.systemYellow]
		case .recovered: return [.systemGreen]
		case .deaths: return [.systemRed]
		}
	}

	override var shareableText: String? { L10n.Chart.topCountries }

	override var supportedModes: [Statistic.Kind] {
		[.confirmed, .recovered, .deaths]
	}


	var isLogarithmic = false {
		didSet {
			self.chartView.clear()
			self.update(region: nil, animated: true)
		}
	}

	override func initializeView() {
		super.initializeView()

		chartView.xAxis.drawGridLinesEnabled = false
		chartView.xAxis.valueFormatter = DefaultAxisValueFormatter(block: { value, axis in
			guard let entry = self.chartView.barData?.dataSets.first?.entryForIndex(Int(value)) as? BarChartDataEntry,
				let region = entry.data as? Region else { return value.description }

			return region.localizedName.replacingOccurrences(of: " ", with: "\n")
		})

		/// Rotate labels in other languages
		if !Locale.current.isEnglish {
			chartView.xAxis.labelRotationAngle = 45
		}

		chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter() { value, axis in
			self.isLogarithmic ? Int(pow(10, value)).kmFormatted : Int(value).kmFormatted
		}

		let simpleMarker = SimpleMarkerView(chartView: chartView) { (entry, highlight) in
			guard let region = entry.data as? Region,
				let report = region.report else { return entry.y.kmFormatted }

			return """
			\(L10n.Case.confirmed): \(report.stat.confirmedCountString)
			\(L10n.Case.recovered): \(report.stat.recoveredCountString) (\(report.stat.recoveredPercent.percentFormatted))
			\(L10n.Case.deaths): \(report.stat.deathCountString) (\(report.stat.deathPercent.percentFormatted))
			"""
		}
		simpleMarker.timeout = 5
		simpleMarker.font = .systemFont(ofSize: 13 * fontScale)
		chartView.marker = simpleMarker

		chartView.legend.enabled = false
	}

	override func update(region: Region?, animated: Bool) {
		super.update(region: region, animated: animated)

		let regions = DataManager.instance.topCountries

		title = L10n.Chart.topCountries + (mode == .confirmed ? "" : " (\(mode))")

		var entries = [BarChartDataEntry]()
		for i in regions.indices {
			let region = regions[i]
			var value = Double(region.report?.stat.number(for: mode) ?? 0)
			if isLogarithmic {
				value = log10(value)
			}
			let entry = BarChartDataEntry(x: Double(i), y: value)
			entry.data = region
			entries.append(entry)
		}

		let label = isLogarithmic ? L10n.Chart.logarithmic : L10n.Chart.topCountries
		let dataSet = BarChartDataSet(entries: entries, label: label)
		dataSet.colors = colors

//		dataSet.drawValuesEnabled = false
		dataSet.valueTextColor = SystemColor.secondaryLabel
		dataSet.valueFont = .systemFont(ofSize: 12 * fontScale, weight: .regular)
		dataSet.valueFormatter = DefaultValueFormatter(block: { value, entry, dataSetIndex, viewPortHandler in
			guard let region = entry.data as? Region else { return Int(value).kmFormatted }
			return region.report?.stat.number(for: self.mode).kmFormatted ?? Int(value).kmFormatted
		})

		if isLogarithmic {
			chartView.leftAxis.axisMinimum = 2
			chartView.leftAxis.axisMaximum = 6
			chartView.leftAxis.labelCount = 4
		}
		else {
			chartView.leftAxis.resetCustomAxisMin()
			chartView.leftAxis.resetCustomAxisMax()
		}

		chartView.data = BarChartData(dataSet: dataSet)

		if animated {
			chartView.animate(yAxisDuration: 2, easingOption: .easeOutCubic)
		}
	}
}
