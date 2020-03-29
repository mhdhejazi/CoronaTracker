//
//  ChartView.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/29/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

protocol RegionChartView: UIView {
	func update(region: Region?, animated: Bool)
}

class ChartView<C: ChartViewBase>: UIView {
	var hasTitle: Bool { true }

	lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = SystemColor.label.withAlphaComponent(0.75)
		label.font = .systemFont(ofSize: 13)
		label.numberOfLines = 0
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	var title: String? = nil {
		didSet {
			titleLabel.text = title?.uppercased()
			chartView.extraTopOffset = titleLabel.sizeThatFits(.zero).height + 20
		}
	}

	lazy var chartView: C = {
		let chartView = C()
		chartView.translatesAutoresizingMaskIntoConstraints = false
		return chartView
	}()

	init() {
		super.init(frame: .zero)

		initializeView()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		initializeView()
	}

	func initializeView() {
		if hasTitle {
			self.addSubview(titleLabel)
			titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
			titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
			titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		}

		self.addSubview(chartView)
		chartView.snapEdgesToSuperview(constant: 20)

		if !(chartView is PieChartView) {
			chartView.xAxis.gridColor = UIColor.lightGray.withAlphaComponent(0.5)
			chartView.xAxis.gridLineDashLengths = [3, 3]
			chartView.xAxis.labelPosition = .bottom
			chartView.xAxis.labelTextColor = SystemColor.secondaryLabel
		}

		chartView.noDataTextColor = .systemGray
		chartView.noDataFont = .systemFont(ofSize: 15)

		chartView.legend.textColor = SystemColor.secondaryLabel
		chartView.legend.font = .systemFont(ofSize: 12, weight: .regular)
		chartView.legend.form = .circle
		chartView.legend.formSize = 12
		chartView.legend.horizontalAlignment = .center
		chartView.legend.xEntrySpace = 10
	}

	func createChartView() -> ChartViewBase {
		fatalError()
	}
}

class BaseBarChartView: ChartView<BarChartView> {
	override func initializeView() {
		super.initializeView()

		chartView.leftAxis.gridColor = UIColor.lightGray.withAlphaComponent(0.5)
		chartView.leftAxis.gridLineDashLengths = [3, 3]
		chartView.leftAxis.labelTextColor = SystemColor.secondaryLabel

		chartView.rightAxis.enabled = false

		chartView.dragEnabled = false
		chartView.scaleXEnabled = false
		chartView.scaleYEnabled = false

		chartView.fitBars = true
	}
}

class BaseLineChartView: ChartView<LineChartView> {
	override func initializeView() {
		super.initializeView()

		chartView.leftAxis.gridColor = UIColor.lightGray.withAlphaComponent(0.5)
		chartView.leftAxis.gridLineDashLengths = [3, 3]
		chartView.leftAxis.labelTextColor = SystemColor.secondaryLabel
		chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter() { value, axis in
			value.kmFormatted
		}

		chartView.rightAxis.enabled = false

		chartView.dragEnabled = false
		chartView.scaleXEnabled = false
		chartView.scaleYEnabled = false
	}
}
