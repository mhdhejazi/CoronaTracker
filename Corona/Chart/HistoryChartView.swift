//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/7/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

class HistoryChartView: BaseLineChartView {
	override var shareableText: String? { L10n.Share.chartHistory }

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

		chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter { value, _ in
			self.isLogarithmic ? pow(10, value).kmFormatted : value.kmFormatted
		}

		chartView.xAxis.valueFormatter = DayAxisValueFormatter(chartView: chartView)

		let marker = SimpleMarkerView(chartView: chartView)
		marker.font = .systemFont(ofSize: 13 * fontScale)
		chartView.marker = marker
	}

	override func updateOptions(from chartView: RegionChartView) {
		super.updateOptions(from: chartView)

		guard let chartView = chartView as? HistoryChartView else { return }
		self.isLogarithmic = chartView.isLogarithmic
	}

	override func update(region: Region?, animated: Bool) {
		super.update(region: region, animated: animated)

		guard let series = region?.timeSeries else {
			chartView.data = nil
			return
		}

		title = L10n.Chart.history

		let dates = series.series.keys.sorted().drop { series.series[$0]?.isZero == true }
		let confirmedEntries = dates.map { date -> ChartDataEntry in
			var value = Double(series.series[date]?.confirmedCount ?? 0)
			if isLogarithmic {
				value = log10(value)
			}
			return ChartDataEntry(x: Double(date.referenceDays), y: value)
		}
		let recoveredEntries = dates.map { date -> ChartDataEntry in
			var value = Double(series.series[date]?.recoveredCount ?? 0)
			if isLogarithmic {
				value = log10(value)
			}
			return ChartDataEntry(x: Double(date.referenceDays), y: value)
		}
		let deathsEntries = dates.map { date -> ChartDataEntry in
			var value = Double(series.series[date]?.deathCount ?? 0)
			if isLogarithmic {
				value = log10(value)
			}
			return ChartDataEntry(x: Double(date.referenceDays), y: value)
		}

		let entries = [confirmedEntries, deathsEntries, recoveredEntries]
		let labels = [L10n.Case.confirmed, L10n.Case.deaths, L10n.Case.recovered]
		let colors = [UIColor.systemOrange, .systemRed, .systemGreen]

		var dataSets = [LineChartDataSet]()
		for index in entries.indices {
			let dataSet = LineChartDataSet(entries: entries[index], label: labels[index])
			dataSet.mode = .cubicBezier
			dataSet.drawValuesEnabled = false
			dataSet.colors = [colors[index].withAlphaComponent(0.75)]

//			dataSet.drawCirclesEnabled = false
			dataSet.circleRadius = (confirmedEntries.count < 60 ? 2 : 1.8) * fontScale
			dataSet.circleColors = [colors[index]]

			dataSet.drawCircleHoleEnabled = false
			dataSet.circleHoleRadius = 1 * fontScale

			dataSet.lineWidth = 1 * fontScale
			dataSet.highlightLineWidth = 1 * fontScale
			dataSet.highlightColor = UIColor.lightGray.withAlphaComponent(0.5)
			dataSet.drawHorizontalHighlightIndicatorEnabled = false

			dataSets.append(dataSet)
		}

		if isLogarithmic {
			chartView.leftAxis.axisMinimum = 1
			chartView.leftAxis.axisMaximum = 7
			chartView.leftAxis.labelCount = 6
		} else {
			chartView.leftAxis.resetCustomAxisMin()
			chartView.leftAxis.resetCustomAxisMax()
		}

		chartView.data = LineChartData(dataSets: dataSets)

		if animated {
			chartView.animate(xAxisDuration: 2)
		}
	}
}
