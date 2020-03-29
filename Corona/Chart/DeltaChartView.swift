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

//		xAxis.drawGridLinesEnabled = false
		xAxis.drawGridLinesEnabled = false
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
		legend.setCustom(entries: [
			LegendEntry(label: "↑ " + L10n.Chart.Delta.increasing, form: .circle, formSize: 12,
						formLineWidth: 0, formLineDashPhase: 0, formLineDashLengths: nil, formColor: .systemOrange),
			LegendEntry(label: "↓ " + L10n.Chart.Delta.decreasing, form: .circle, formSize: 12,
						formLineWidth: 0, formLineDashPhase: 0, formLineDashLengths: nil, formColor: .systemBlue),
		])
	}

	func update(series: TimeSeries?, animated: Bool) {
		guard let series = series else {
			data = nil
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

		data = BarChartData(dataSet: dataSet)

		if animated {
			animate(yAxisDuration: 2)
		}
	}
}
