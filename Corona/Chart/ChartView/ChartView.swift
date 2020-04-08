//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/29/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

class ChartView<C: ChartViewBase>: UIView, RegionChartView {
	public let defaultColors = [
		UIColor(hue: 0.57, saturation: 0.75, brightness: 0.8, alpha: 1.0).dynamic,
		UIColor(hue: 0.8, saturation: 0.8, brightness: 0.7, alpha: 1.0).dynamic,
		UIColor(hue: 0.2, saturation: 0.8, brightness: 0.7, alpha: 1.0).dynamic,
		UIColor(hue: 0.1, saturation: 0.8, brightness: 0.7, alpha: 1.0).dynamic,
		UIColor(hue: 0.95, saturation: 0.8, brightness: 0.7, alpha: 1.0).dynamic,
		UIColor(hue: 0.4, saturation: 0.8, brightness: 0.7, alpha: 1.0).dynamic
	]

	var hasTitle: Bool { true }

	lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = SystemColor.label.withAlphaComponent(0.75)
		label.font = .systemFont(ofSize: 13 * fontScale)
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

	var extraMenuItems: [MenuItem] { [] }

	@available(iOS 13.0, *)
	var contextMenuActions: [UIMenuElement] {
		var result: [UIMenuElement] = []

		var actions = supportedModes.map { mode in
			UIAction(title: mode.description, state: self.mode == mode ? .on : .off) { _ in
				self.mode = mode
			}
		}
		if !actions.isEmpty {
			result.append(UIMenu(title: "", options: .displayInline, children: actions))
		}

		actions = extraMenuItems.compactMap { item in
			switch item {
			case .regular(let title, let image, let action):
				return UIAction(title: title ?? "", image: image) { _ in
					action()
				}

			case .option(let title, let selected, let action):
				return UIAction(title: title ?? "", state: selected ? .on : .off) { _ in
					action()
				}

			default:
				return nil
			}
		}
		if !actions.isEmpty {
			result.append(UIMenu(title: "", options: .displayInline, children: actions))
		}

		return result
	}

	var shareableText: String? { nil }

	var shareAction: (() -> Void)?

	lazy var chartView: C = {
		let chartView = C()
		chartView.translatesAutoresizingMaskIntoConstraints = false
		return chartView
	}()

	var interactive: Bool = false {
		didSet {
			chartView.isUserInteractionEnabled = interactive
		}
	}

	let fontScale: CGFloat

	var region: Region?

	convenience init() {
		self.init(fontScale: 1)
	}

	required init(fontScale: CGFloat) {
		self.fontScale = fontScale
		super.init(frame: .zero)

		initializeView()
	}

	required init?(coder: NSCoder) {
		self.fontScale = 1
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
		chartView.snapEdgesToSuperview([.top, .bottom], constant: 20)
		chartView.snapEdgesToSuperview([.left, .right], constant: 0)
		chartView.extraLeftOffset = 20
		chartView.extraRightOffset = 20

		if !(chartView is PieChartView) {
			chartView.xAxis.gridColor = UIColor.lightGray.withAlphaComponent(0.5)
			chartView.xAxis.gridLineDashLengths = [3, 3]
			chartView.xAxis.labelPosition = .bottom
			chartView.xAxis.labelTextColor = SystemColor.secondaryLabel
			chartView.xAxis.labelFont = .systemFont(ofSize: 10 * fontScale)
		}

		chartView.noDataTextColor = .systemGray
		chartView.noDataFont = .systemFont(ofSize: 15 * fontScale)

		chartView.legend.textColor = SystemColor.secondaryLabel
		chartView.legend.font = .systemFont(ofSize: 12 * fontScale, weight: .regular)
		chartView.legend.form = .circle
		chartView.legend.formSize = 12
		chartView.legend.horizontalAlignment = .center
		chartView.legend.xEntrySpace = 10
	}

	func updateOptions(from chartView: RegionChartView) {
		self.mode = chartView.mode
	}

	func update(region: Region?, animated: Bool) {
		self.region = region
	}

	func prepareForShare(shareCallback: () -> Void) {
		menuButton.isHidden = true
		shareCallback()
		menuButton.isHidden = false
	}

	@objc
	func menuButtonTapped(_ sender: Any) {
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

		menuItems.append(contentsOf: extraMenuItems)

		if !extraMenuItems.isEmpty {
			menuItems.append(.separator)
		}

		menuItems.append(.regular(title: L10n.Menu.share, image: Asset.share.image) {
			self.shareAction?()
		})

		Menu.show(above: App.topViewController, sourceView: menuButton, items: menuItems)
	}
}
