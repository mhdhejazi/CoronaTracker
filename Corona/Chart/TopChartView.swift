//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/7/20.
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
		[.confirmed, .active, .recovered, .deaths]
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
		chartView.xAxis.valueFormatter = DefaultAxisValueFormatter(block: { value, _ in
			guard let entry = self.chartView.barData?.dataSets.first?.entryForIndex(Int(value)) as? BarChartDataEntry,
				let region = entry.data as? Region else { return value.description }

			return region.localizedName.replacingOccurrences(of: " ", with: "\n")
		})

		chartView.xAxis.labelRotationAngle = 35

		chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter { value, _ in
			self.isLogarithmic ? pow(10, value).kmFormatted : value.kmFormatted
		}

		let simpleMarker = SimpleMarkerView(chartView: chartView) { entry, _ in
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

	override func updateOptions(from chartView: RegionChartView) {
		super.updateOptions(from: chartView)

		guard let chartView = chartView as? TopChartView else { return }
		self.isLogarithmic = chartView.isLogarithmic
	}

	override func update(region: Region?, animated: Bool) {
		super.update(region: region, animated: animated)

		var regions: [Region] = []
		var title: String = ""
		var colors: [UIColor] = []

		if region?.isWorld != true, let subRegions = region?.subRegions {
			regions = [Region](subRegions.lazy.sorted().reversed().prefix(6))
			title = L10n.Chart.topRegions
			colors = self.colors.reversed()
		}

		if regions.count < 2 {
			regions = DataManager.shared.topCountries
			title = L10n.Chart.topCountries
			colors = self.colors
		}

		self.title = title + (mode == .confirmed ? "" : " (\(mode))")

		var entries = [BarChartDataEntry]()
		for index in regions.indices {
			let region = regions[index]
			let value = Double(region.report?.stat.number(for: mode) ?? 0)
			let scaledValue = isLogarithmic ? log10(value) : value
			let entry = BarChartDataEntry(x: Double(index), y: scaledValue)
			entry.data = region
			entries.append(entry)
		}

		let dataSet = BarChartDataSet(entries: entries)
		dataSet.colors = colors

//		dataSet.drawValuesEnabled = false
		dataSet.valueTextColor = SystemColor.secondaryLabel
		dataSet.valueFont = .systemFont(ofSize: 12 * fontScale, weight: .regular)
		dataSet.valueFormatter = DefaultValueFormatter(block: { value, entry, _, _ in
			guard let region = entry.data as? Region else { return value.kmFormatted }
			return region.report?.stat.number(for: self.mode).kmFormatted ?? value.kmFormatted
		})

		if isLogarithmic {
			chartView.leftAxis.axisMinimum = 2
			chartView.leftAxis.axisMaximum = 6
			chartView.leftAxis.labelCount = 4
		} else {
			chartView.leftAxis.axisMinimum = 0
			chartView.leftAxis.resetCustomAxisMax()
		}

		chartView.xAxis.setLabelCount(entries.count, force: false)

		chartView.data = BarChartData(dataSet: dataSet)

		if animated {
			chartView.animate(yAxisDuration: 0.5, easingOption: .easeOutQuad)
		}
	}
}
