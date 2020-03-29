//
//  TrenlineChartView.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/28/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

class TrendlineChartView: LineChartView {
	private static let maxItems = 6
	private static let colors = [
		UIColor(hue: 0.57, saturation: 0.75, brightness: 0.8, alpha: 1.0).dynamic,
		UIColor(hue: 0.8, saturation: 0.8, brightness: 0.7, alpha: 1.0).dynamic,
		UIColor(hue: 0.2, saturation: 0.8, brightness: 0.7, alpha: 1.0).dynamic,
		UIColor(hue: 0.1, saturation: 0.8, brightness: 0.7, alpha: 1.0).dynamic,
		UIColor(hue: 0.95, saturation: 0.8, brightness: 0.7, alpha: 1.0).dynamic,
		UIColor(hue: 0.4, saturation: 0.8, brightness: 0.7, alpha: 1.0).dynamic,
	]

	private lazy var legendStack: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: (1...Self.maxItems).map { _ in
			let colorLabel = UILabel()
			colorLabel.textAlignment = .center
			colorLabel.font = .systemFont(ofSize: 15)
			colorLabel.text = "●"
			colorLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)

			let textLabel = UILabel()
			textLabel.font = .systemFont(ofSize: 11)
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
		stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

		stackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(legendTapped(_:))))
		return stackView
	}()

	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = SystemColor.label.withAlphaComponent(0.75)
		label.font = .systemFont(ofSize: 13)
		label.numberOfLines = 0
		label.textAlignment = .center

		label.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(label)
		label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
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

	private var selectedIndex = -1 {
		didSet {
			guard selectedIndex != oldValue else { return }

			if let dataSets = self.data?.dataSets as? [LineChartDataSet] {
				for i in dataSets.indices {
					let dataSet = dataSets[i]
					var color = Self.colors[i % Self.colors.count]
					if selectedIndex > -1 && selectedIndex != i {
						color = color.withAlphaComponent(0.5)
					}
					dataSet.lineDashLengths = selectedIndex == i ? nil : [4, 2]
					dataSet.colors = [color]
					dataSet.circleColors = [color]
				}
				DispatchQueue.main.async {
					self.data?.notifyDataChanged()
					self.notifyDataSetChanged()
				}
			}
		}
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		xAxis.gridColor = UIColor.lightGray.withAlphaComponent(0.5)
		xAxis.gridLineDashLengths = [3, 3]
		xAxis.labelPosition = .bottom
		xAxis.labelTextColor = SystemColor.secondaryLabel
		xAxis.valueFormatter = DefaultAxisValueFormatter() { value, axis in
			L10n.Chart.Axis.days(Int(value))
		}

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

		let simpleMarker = SimpleMarkerView(chartView: self)
		simpleMarker.visibilityCallback = { entry, visible in
			let index = (entry.data as? Int) ?? -1
			self.selectedIndex = visible ? index : -1
			print(index)
		}
		marker = simpleMarker

		legend.enabled = false
	}

	func update(region: Region?, animated: Bool) {
		var regions = DataManager.instance.topCountries.filter { $0.timeSeries != nil }
		guard regions.count > 2 else {
			data = nil
			return
		}

		if let region = region, region.isCountry, !regions.contains(region) {
			regions.removeLast()
			regions.append(region)
		}

		title = L10n.Chart.trendline

		let history = regions.map { region in
			region.timeSeries!.series
				.lazy
				.sorted { $0.key < $1.key }
				.drop { $0.value.confirmedCount < 100 }
		}
		let count = history.map { $0.count }.sorted().dropLast().last!
		let entries = zip(history.indices, history).map { (regionIndex, series) in
			zip(series.indices.prefix(count), series).map { (index, pair) in
				ChartDataEntry(x: Double(index - series.startIndex),
							   y: Double(pair.value.confirmedCount),
							   data: regionIndex)
			}
		}
		let labels = regions.map { $0.localizedName }

		var dataSets = [LineChartDataSet]()
		for i in entries.indices {
			let dataSet = LineChartDataSet(entries: entries[i], label: labels[i])
			dataSet.mode = .cubicBezier
			dataSet.drawValuesEnabled = false

			let color = Self.colors[i % Self.colors.count]

			dataSet.colors = [color]

			dataSet.drawCirclesEnabled = false
			dataSet.circleRadius = regions[i] == region ? 3 : 2
			dataSet.circleColors = [color.withAlphaComponent(0.75)]

			dataSet.drawCircleHoleEnabled = false
			dataSet.circleHoleRadius = 1

			dataSet.lineWidth = regions[i] == region ? 2.5 : 1.5
			dataSet.lineDashLengths = regions[i] == region ? nil : [4, 2]
			dataSet.highlightLineWidth = 0

			dataSets.append(dataSet)
		}

		updateLegend(regions: regions)

		data = LineChartData(dataSets: dataSets)

		if animated {
			animate(xAxisDuration: 2, easingOption: .linear)
		}
	}

	private func updateLegend(regions: [Region]) {
		zip(regions, legendStack.arrangedSubviews).forEach { (region, view) in
			if let stack = view as? UIStackView, let colorIndex = regions.firstIndex(of: region) {
				(stack.arrangedSubviews.first as? UILabel)?.textColor = Self.colors[colorIndex % Self.colors.count]
				(stack.arrangedSubviews.last as? UILabel)?.text = region.localizedName.replacingOccurrences(of: " ", with: "\n")
			}
		}

		legendStack.layoutIfNeeded()
		legendStack.setNeedsLayout()
		extraBottomOffset = legendStack.bounds.height + 10
	}

	@objc func legendTapped(_ recognizer: UITapGestureRecognizer) {
		let point = recognizer.location(in: legendStack)
		let index = legendStack.arrangedSubviews.firstIndex { view in
			view.point(inside: view.convert(point, from: legendStack), with: nil)
		} ?? -1
		highlightValues(nil)
		selectedIndex = (selectedIndex == index) ? -1 : index
	}
}
