//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/23/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

class DeltaChartView: BaseBarChartView {
	override var shareableText: String? { L10n.Chart.delta }

	override var supportedModes: [Statistic.Kind] {
		[.confirmed, .deaths]
	}

	override var extraMenuItems: [MenuItem] {
		[MenuItem.option(title: L10n.Chart.logarithmic, selected: isLogarithmic, action: {
			self.isLogarithmic.toggle()
		})]
	}

	var isLogarithmic = false {
		didSet {
			self.chartView.clear()
			self.update(region: region, animated: true)
		}
	}

	override func initializeView() {
		super.initializeView()

		chartView.xAxis.drawGridLinesEnabled = false
		chartView.xAxis.valueFormatter = DayAxisValueFormatter(chartView: chartView)

		chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter { value, _ in
			self.isLogarithmic ? pow(10, value).kmFormatted : value.kmFormatted
		}

		let marker = SimpleMarkerView(chartView: chartView) { entry, _ in
			let xValue = self.chartView.xAxis.valueFormatter?.stringForValue(entry.x, axis: nil) ?? "-"
			if let value = entry.data as? Double {
				return "\(xValue): \(value.kmFormatted)"
			} else {
				return "\(xValue): \(entry.y.kmFormatted)"
			}
		}
		marker.font = .systemFont(ofSize: 13 * fontScale)
		chartView.marker = marker
	}

	override func updateOptions(from chartView: RegionChartView) {
		super.updateOptions(from: chartView)

		guard let chartView = chartView as? DeltaChartView else { return }
		self.isLogarithmic = chartView.isLogarithmic
	}

	override func update(region: Region?, animated: Bool) {
		super.update(region: region, animated: animated)

		guard let series = region?.timeSeries else {
			chartView.data = nil
			return
		}

		let showNewDeaths = mode == .deaths

		title = showNewDeaths ? L10n.Chart.Delta.deaths : L10n.Chart.delta

		let increasingColor = showNewDeaths ? UIColor.systemRed : UIColor.systemOrange
		chartView.legend.setCustom(entries: [
			LegendEntry(label: "↑ " + L10n.Chart.Delta.increasing, form: .circle, formSize: 12,
						formLineWidth: 0, formLineDashPhase: 0, formLineDashLengths: nil, formColor: increasingColor),
			LegendEntry(label: "↓ " + L10n.Chart.Delta.decreasing, form: .circle, formSize: 12,
						formLineWidth: 0, formLineDashPhase: 0, formLineDashLengths: nil, formColor: .systemBlue)
		])

		let changes = series.changes()
		let dates = changes.keys.sorted().drop { changes[$0]?.isZero == true }

		var entries = [BarChartDataEntry]()
		for date in dates {
			let value = Double(showNewDeaths ? changes[date]!.newDeaths : changes[date]!.newConfirmed)
			let scaledValue = isLogarithmic ? log10(value) : value
			let entry = BarChartDataEntry(x: Double(date.referenceDays), y: scaledValue)
			entry.data = value
			entries.append(entry)
		}

		var colors = [UIColor]()
		for index in entries.indices.reversed() {
			var color = increasingColor
			if index > 0 {
				let currentEntry = entries[index]
				let previousEntry = entries[index - 1]
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

		if isLogarithmic {
			chartView.leftAxis.axisMinimum = 1
			chartView.leftAxis.axisMaximum = 6
			chartView.leftAxis.labelCount = 5
		} else {
			chartView.leftAxis.axisMinimum = 0
			chartView.leftAxis.resetCustomAxisMax()
		}

		chartView.data = BarChartData(dataSet: dataSet)

		if animated {
			chartView.animate(yAxisDuration: 0.6, easingOption: .easeOutQuad)
		}
	}
}
