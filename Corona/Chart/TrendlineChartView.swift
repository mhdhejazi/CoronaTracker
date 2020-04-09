//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/28/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

class TrendlineChartView: BaseLineChartView {
	private static let maxItems = 6

	private var colors: [UIColor] { defaultColors }

	private lazy var legendStack: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: (1...Self.maxItems).map { _ in
			let colorLabel = UILabel()
			colorLabel.textAlignment = .center
			colorLabel.font = .systemFont(ofSize: 15 * fontScale)
			colorLabel.text = "●"
			colorLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)

			let textLabel = UILabel()
			textLabel.font = .systemFont(ofSize: 11 * fontScale)
			textLabel.textColor = SystemColor.secondaryLabel
			textLabel.textAlignment = .center
			textLabel.numberOfLines = 0

			let verticalStackView = UIStackView(arrangedSubviews: [colorLabel, textLabel])
			verticalStackView.axis = .vertical

			return verticalStackView
		})
		stackView.distribution = .fillProportionally
		stackView.alignment = .top
		stackView.spacing = 8
		stackView.translatesAutoresizingMaskIntoConstraints = false

		self.addSubview(stackView)
		stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
		stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40).isActive = true
		stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40).isActive = true

		stackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(legendTapped(_:))))
		return stackView
	}()

	private var selectedIndex = -1 {
		didSet {
			guard selectedIndex != oldValue else { return }

			if let dataSets = chartView.data?.dataSets as? [LineChartDataSet] {
				for index in dataSets.indices {
					let dataSet = dataSets[index]
					var color = colors[index % colors.count]
					if selectedIndex > -1 && selectedIndex != index {
						color = color.withAlphaComponent(0.5)
					}
					dataSet.lineDashLengths = selectedIndex == index ? nil : [4, 2]
					dataSet.colors = [color]
					dataSet.circleColors = [color]
				}
				DispatchQueue.main.async {
					self.chartView.data?.notifyDataChanged()
					self.chartView.notifyDataSetChanged()
				}
			}
		}
	}

	override var shareableText: String? { L10n.Chart.trendline }

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

		chartView.xAxis.valueFormatter = DefaultAxisValueFormatter { value, _ in
			L10n.Chart.Axis.days(Int(value))
		}

		chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter { value, _ in
			self.isLogarithmic ? pow(10, value).kmFormatted : value.kmFormatted
		}

		let simpleMarker = SimpleMarkerView(chartView: chartView)
		simpleMarker.visibilityCallback = { entry, visible in
			let index = (entry.data as? Int) ?? -1
			self.selectedIndex = visible ? index : -1
			print(index)
		}
		simpleMarker.font = .systemFont(ofSize: 13 * fontScale)
		chartView.marker = simpleMarker

		chartView.legend.enabled = false
	}

	override func updateOptions(from chartView: RegionChartView) {
		super.updateOptions(from: chartView)

		guard let chartView = chartView as? TrendlineChartView else { return }
		self.isLogarithmic = chartView.isLogarithmic
	}

	override func update(region: Region?, animated: Bool) {
		super.update(region: region, animated: animated)

		var regions = DataManager.instance.topCountries.filter { $0.timeSeries != nil }
		guard regions.count > 2 else {
			chartView.data = nil
			return
		}

		if let region = region, region.isCountry, !regions.contains(region) {
			regions.removeLast()
			regions.append(region)
		}

		title = (mode == .deaths) ? L10n.Chart.Trendline.deaths : L10n.Chart.trendline

		let serieses = regions.map { region in
			region.timeSeries!.series
				.lazy
				.sorted { $0.key < $1.key }
				.drop { $0.value.number(for: mode) < (mode == .deaths ? 10 : 100) }
		}
		let totalDays = serieses.map { $0.count }.sorted().dropLast().last! /// Next to the longest (to deal with China case)
		let entries = zip(serieses.indices, serieses).map { (regionIndex, series) in
			zip(series.indices.prefix(totalDays), series).map { (index, pair) -> ChartDataEntry in
				var value = Double(pair.value.number(for: mode))
				if isLogarithmic {
					value = log10(value)
				}
				return ChartDataEntry(x: Double(index - series.startIndex),
									  y: value,
									  data: regionIndex)
			}
		}
		let labels = regions.map { $0.localizedName }

		var dataSets = [LineChartDataSet]()
		for index in entries.indices {
			let dataSet = LineChartDataSet(entries: entries[index], label: labels[index])
			dataSet.mode = .cubicBezier
			dataSet.drawValuesEnabled = false

			let color = colors[index % colors.count]

			dataSet.colors = [color]

			dataSet.drawCirclesEnabled = false
			dataSet.circleRadius = (regions[index] == region ? 3 : 2) * fontScale
			dataSet.circleColors = [color.withAlphaComponent(0.75)]

			dataSet.drawCircleHoleEnabled = false
			dataSet.circleHoleRadius = 1 * fontScale

			dataSet.lineWidth = (regions[index] == region ? 2.5 : 1.5) * fontScale
			dataSet.lineDashLengths = regions[index] == region ? nil : [4, 2]
			dataSet.highlightLineWidth = 1 * fontScale
			dataSet.highlightColor = UIColor.lightGray.withAlphaComponent(0.5)
			dataSet.drawHorizontalHighlightIndicatorEnabled = false

			dataSets.append(dataSet)
		}

		updateLegend(regions: regions)

		if isLogarithmic {
			chartView.leftAxis.axisMinimum = 2
			chartView.leftAxis.axisMaximum = 6
			chartView.leftAxis.labelCount = 4
		} else {
			chartView.leftAxis.resetCustomAxisMin()
			chartView.leftAxis.resetCustomAxisMax()
		}

		chartView.data = LineChartData(dataSets: dataSets)

		if animated {
			chartView.animate(xAxisDuration: 2, easingOption: .linear)
		}
	}

	private func updateLegend(regions: [Region]) {
		zip(regions, legendStack.arrangedSubviews).forEach { (region, view) in
			if let stack = view as? UIStackView, let colorIndex = regions.firstIndex(of: region) {
				(stack.arrangedSubviews.first as? UILabel)?.textColor = colors[colorIndex % colors.count]
				(stack.arrangedSubviews.last as? UILabel)?.text = region.localizedName.replacingOccurrences(of: " ", with: "\n")
			}
		}

		legendStack.layoutIfNeeded()
		legendStack.setNeedsLayout()
		chartView.extraBottomOffset = legendStack.bounds.height + 10
	}

	@objc
	func legendTapped(_ recognizer: UITapGestureRecognizer) {
		let point = recognizer.location(in: legendStack)
		let index = legendStack.arrangedSubviews.firstIndex { view in
			view.point(inside: view.convert(point, from: legendStack), with: nil)
		} ?? -1
		chartView.highlightValues(nil)
		selectedIndex = (selectedIndex == index) ? -1 : index
	}
}
