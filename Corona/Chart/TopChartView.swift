//
//  TopChartView.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/7/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

class TopChartView: BaseBarChartView, RegionChartView {
	private lazy var switchButton: UIButton = {
		let button = UIButton(type: .custom)
		button.setImage(Asset.switch.image, for: .normal)
		button.addTarget(self, action: #selector(switchButtonTapped(_:)), for: .touchUpInside)

		button.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(button)
		button.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
		button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
		button.widthAnchor.constraint(equalToConstant: 44).isActive = true
		button.heightAnchor.constraint(equalToConstant: 44).isActive = true

		return button
	}()

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
			self.isLogarithmic ? pow(10, value).kmFormatted : value.kmFormatted
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
		chartView.marker = simpleMarker

		chartView.legend.enabled = false
	}

	func update(region: Region?, animated: Bool) {
		let regions = DataManager.instance.topCountries

		title = isLogarithmic ? L10n.Chart.logarithmic : L10n.Chart.topCountries
		_ = switchButton

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

	@objc func switchButtonTapped(_ sender: Any) {
		UIView.transition(with: self, duration: 0.25, options: [.transitionCrossDissolve], animations: {
			self.isLogarithmic = !self.isLogarithmic
		}, completion: nil)
	}
}
