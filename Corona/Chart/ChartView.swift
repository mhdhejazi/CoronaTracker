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
	@available(iOS 13.0, *)
	var contextMenuActions: [UIMenuElement] { get }

	var shareAction: (() -> Void)? { get set }

	func update(region: Region?, animated: Bool)

	func prepareForShare(shareCallback: () -> Void)
}

class ChartView<C: ChartViewBase>: UIView, RegionChartView {
	var hasTitle: Bool { true }

	lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = SystemColor.label.withAlphaComponent(0.75)
		label.font = .systemFont(ofSize: 13)
		label.numberOfLines = 0
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		label.isUserInteractionEnabled = true
		return label
	}()

	var title: String? = nil {
		didSet {
			titleLabel.text = title?.uppercased()
			chartView.extraTopOffset = titleLabel.sizeThatFits(.zero).height + 20
		}
	}

	lazy var menuButton: UIButton = {
		let button = UIButton(type: .custom)
		button.setImage(Asset.more.image, for: .normal)
		button.tintColor = SystemColor.secondaryLabel
		button.addTarget(self, action: #selector(menuButtonTapped(_:)), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	var mode: Statistic.Kind = .confirmed {
		didSet {
			update(region: region, animated: true)
		}
	}

	var supportedModes: [Statistic.Kind] { [] }

	@available(iOS 13.0, *)
	var contextMenuActions: [UIMenuElement] {
		supportedModes.map { mode in
			UIAction(title: mode.description, state: self.mode == mode ? .on : .off) { _ in
				self.mode = mode
			}
		}
	}

	var shareAction: (() -> Void)?

	lazy var chartView: C = {
		let chartView = C()
		chartView.translatesAutoresizingMaskIntoConstraints = false
		return chartView
	}()

	var region: Region?

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

			self.addSubview(menuButton)
			menuButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
			menuButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
			menuButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
			menuButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
		}

		self.addSubview(chartView)
		self.sendSubviewToBack(chartView)
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

	func update(region: Region?, animated: Bool) {
		self.region = region
	}

	func prepareForShare(shareCallback: () -> Void) {
		menuButton.isHidden = true
		shareCallback()
		menuButton.isHidden = false
	}

	@objc func menuButtonTapped(_ sender: Any) {
		var menuItems: [MenuItem] = supportedModes.map { mode in
			let title: String
			switch mode {
			case .confirmed: title = L10n.Case.confirmed
			case .active: title = L10n.Case.active
			case .recovered: title = L10n.Case.recovered
			case .deaths: title = L10n.Case.deaths
			}

			return MenuItem.option(title: title, selected: self.mode == mode) {
				self.mode = mode
			}
		}

		if !menuItems.isEmpty {
			menuItems.append(.separator)
		}

		menuItems.append(.regular(title: L10n.Menu.share, image: Asset.share.image) {
			self.shareAction?()
		})

		Menu.show(above: MapController.instance, sourceView: menuButton, width: 150, items: menuItems)
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
			Int(value).kmFormatted
		}

		chartView.rightAxis.enabled = false

		chartView.dragEnabled = false
		chartView.scaleXEnabled = false
		chartView.scaleYEnabled = false
	}
}
