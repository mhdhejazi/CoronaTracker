//
//  CurrentStateChart.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/7/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

class HistoryChartView: LineChartView {
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = SystemColor.label.withAlphaComponent(0.75)
		label.font = .systemFont(ofSize: 13)
		label.numberOfLines = 0
		label.textAlignment = .center

		label.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(label)
		label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		label.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true

		return label
	}()

	private var title: String? = nil {
		didSet {
			titleLabel.text = title?.uppercased()
			extraTopOffset = titleLabel.sizeThatFits(.zero).height + 20
		}
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		xAxis.gridColor = UIColor.lightGray.withAlphaComponent(0.5)
		xAxis.gridLineDashLengths = [3, 3]
		xAxis.labelPosition = .bottom
		xAxis.labelTextColor = SystemColor.secondaryLabel
		xAxis.valueFormatter = DayAxisValueFormatter(chartView: self)

//		leftAxis.drawGridLinesEnabled = false
		leftAxis.gridColor = UIColor.lightGray.withAlphaComponent(0.5)
		leftAxis.gridLineDashLengths = [3, 3]
		leftAxis.labelTextColor = SystemColor.secondaryLabel
		leftAxis.valueFormatter = DefaultAxisValueFormatter() { value, axis in
			value.kmFormatted
		}

		rightAxis.enabled = false

		dragEnabled = false
		scaleXEnabled = false
		scaleYEnabled = false

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

	func update(series: TimeSeries?, animated: Bool) {
		guard let series = series else {
			data = nil
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
			dataSet.circleRadius = confirmedEntries.count < 60 ? 2 : 1.8
			dataSet.circleColors = [colors[i]]

			dataSet.drawCircleHoleEnabled = false
			dataSet.circleHoleRadius = 1

			dataSet.lineWidth = 1
			dataSet.highlightLineWidth = 0

			dataSets.append(dataSet)
		}

		data = LineChartData(dataSets: dataSets)

		if animated {
			animate(xAxisDuration: 2)
		}
	}
}
