//
//  RegionDataCell.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/25/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import SafariServices

import Charts

class RegionDataCell: UITableViewCell {
	class var reuseIdentifier: String { String(describing: Self.self) }

	private lazy var buttonShare: UIButton = {
		let button = UIButton(type: .custom)
		button.setImage(Asset.shareCircle.image, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.widthAnchor.constraint(equalToConstant: 50).isActive = true
		button.heightAnchor.constraint(equalToConstant: 50).isActive = true
		button.transform = .init(scaleX: 0.1, y: 0.1)
		button.alpha = 0
		button.addAction {
			self.shareAction?()
		}
		return button
	}()

	@available(iOS 13.0, *)
	var contextMenuActions: [UIMenuElement] {
		var items = [UIMenuElement]()

		#if targetEnvironment(macCatalyst)
		items.append(UIMenu(title: "", options: .displayInline, children: [
			UIAction(title: L10n.Menu.copy) { _ in self.copyAction?() }
		]))
		#endif

		items.append(UIAction(title: L10n.Menu.share, image: Asset.share.image) { _ in
			self.shareAction?()
		})

		return items
	}

	var copyAction: (() -> Void)? = nil
	var shareAction: (() -> Void)? = nil
	var shareableImage: UIImage? { nil }
	var shareableText: String? { nil }

	var region: Region? {
		didSet {
			guard region !== oldValue else { return }
			update()
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		clipsToBounds = false
		contentView.clipsToBounds = false

		contentView.addSubview(buttonShare)
		buttonShare.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		buttonShare.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true

		if #available(iOS 13.0, *) {
			addInteraction(UIContextMenuInteraction(delegate: self))
		}
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		guard shareableText != nil, superview is UITableView else { return }

		UIView.animate(withDuration: editing ? 0.5 : 0.25,
					   delay: 0,
					   usingSpringWithDamping: editing ? 0.7 : 2,
					   initialSpringVelocity: 0,
					   options: [],
					   animations: {

						let scale: CGFloat = editing ? 1 : 0.1
						let alpha: CGFloat = editing ? 1 : 0
						self.buttonShare.transform = .init(scaleX: scale, y: scale)
						self.buttonShare.alpha = alpha
						self.contentView.subviews.filter({ $0 !== self.buttonShare }).forEach { subview in
							subview.transform = editing ? .init(translationX: -self.buttonShare.bounds.width - 15, y: 0) : .identity
						}
		})
	}

	func update(animated: Bool = true) {
	}
}

@available(iOS 13.0, *)
extension RegionDataCell: UIContextMenuInteractionDelegate {
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		guard shareableText != nil, !isEditing else { return nil }

		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
			UIMenu(title: "", children: self.contextMenuActions)
		})
	}

	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		let parameters = UIPreviewParameters()
		parameters.backgroundColor = .clear
		return UITargetedPreview(view: self, parameters: parameters)
	}

	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willDisplayMenuFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
		self.backgroundColor = SystemColor.secondarySystemBackground
	}

	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
		UIView.animate(withDuration: 0.25) {
			self.backgroundColor = .clear
		}
	}
}

class StatsCell: RegionDataCell {
	static let numberPercentSwitchInterval: TimeInterval = 3 /// Seconds

	private var showPercents = false
	private var switchPercentsTask: DispatchWorkItem?

	@IBOutlet var labelConfirmedTitle: UILabel!
	@IBOutlet var labelConfirmed: UILabel!
	@IBOutlet var labelNewConfirmed: UILabel!
	@IBOutlet var labelRecoveredTitle: UILabel!
	@IBOutlet var labelRecovered: UILabel!
	@IBOutlet var labelNewRecovered: UILabel!
	@IBOutlet var labelDeathsTitle: UILabel!
	@IBOutlet var labelDeaths: UILabel!
	@IBOutlet var labelNewDeaths: UILabel!

	override var shareableImage: UIImage? { snapshot() }
	override var shareableText: String? { L10n.Share.current }

	override func awakeFromNib() {
		super.awakeFromNib()

		if #available(iOS 11.0, *) {
			labelConfirmed.font = .preferredFont(forTextStyle: .largeTitle)
			labelRecovered.font = .preferredFont(forTextStyle: .largeTitle)
			labelDeaths.font = .preferredFont(forTextStyle: .largeTitle)
		} else {
			/// iOS 10
			labelConfirmed.font = .systemFont(ofSize: 24)
			labelRecovered.font = .systemFont(ofSize: 24)
			labelDeaths.font = .systemFont(ofSize: 24)
		}

		labelConfirmedTitle.text = L10n.Case.confirmed
		labelRecoveredTitle.text = L10n.Case.recovered
		labelDeathsTitle.text = L10n.Case.deaths

		contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:))))
	}

	override func update(animated: Bool) {
		UIView.transition(with: self, duration: 0.25, options: [.transitionCrossDissolve], animations: {
			self.labelConfirmed.text = self.region?.report?.stat.confirmedCountString ?? "-"
			self.labelRecovered.text = self.region?.report?.stat.recoveredCountString ?? "-"
			self.labelDeaths.text = self.region?.report?.stat.deathCountString ?? "-"

			self.labelNewConfirmed.text = self.region?.dailyChange?.newConfirmedString ?? "-"
			self.labelNewRecovered.text = self.region?.dailyChange?.newRecoveredString ?? "-"
			self.labelNewDeaths.text = self.region?.dailyChange?.newDeathsString ?? "-"
		}, completion: nil)

		updateStats(reset: true)
	}

	private func updateStats(reset: Bool = false) {
		switchPercentsTask?.cancel()
		let task = DispatchWorkItem {
			self.showPercents = !self.showPercents
			self.updateStats()
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + Self.numberPercentSwitchInterval, execute: task)
		switchPercentsTask = task

		if reset {
			showPercents = false
			return
		}

		guard let report = region?.report else { return }
		labelRecovered.transition {
			self.labelRecovered.text = self.showPercents ?
				report.stat.recoveredPercentString :
				report.stat.recoveredCountString
		}
		labelDeaths.transition {
			self.labelDeaths.text = self.showPercents ?
				report.stat.deathPercentString :
				report.stat.deathCountString
		}
		labelNewConfirmed.transition {
			self.labelNewConfirmed.text = self.showPercents ?
				self.region?.dailyChange?.confirmedGrowthString ?? "-" :
				self.region?.dailyChange?.newConfirmedString ?? "-"
		}
		labelNewRecovered.transition {
			self.labelNewRecovered.text = self.showPercents ?
				self.region?.dailyChange?.recoveredGrowthString ?? "-" :
				self.region?.dailyChange?.newRecoveredString ?? "-"
		}
		labelNewDeaths.transition {
			self.labelNewDeaths.text = self.showPercents ?
				self.region?.dailyChange?.deathsGrowthString ?? "-" :
				self.region?.dailyChange?.newDeathsString ?? "-"
		}
	}

	@objc func cellTapped(_ sender: Any) {
		self.showPercents = !self.showPercents
		updateStats()
	}
}

class ChartDataCell<C: RegionChartView>: RegionDataCell {
	lazy var chartView = C()

	@available(iOS 13.0, *)
	override var contextMenuActions: [UIMenuElement] {
		var actions = chartView.contextMenuActions
		if !actions.isEmpty {
			actions = [
				UIMenu(title: "", options: .displayInline, children: actions)
			]
		}
		actions.append(contentsOf: super.contextMenuActions)
		return actions
	}

	override var shareAction: (() -> Void)? {
		didSet {
			chartView.shareAction = shareAction
		}
	}

	override var shareableImage: UIImage? {
		var image: UIImage? = nil
		chartView.prepareForShare {
			image = self.snapshot()
		}
		return image
	}

	override var shareableText: String? {
		chartView.shareableText
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		contentView.addSubview(chartView)
		chartView.snapEdgesToSuperview()
	}

	override func update(animated: Bool) {
		chartView.update(region: region, animated: animated)
	}
}

class CurrentChartCell: ChartDataCell<CurrentChartView> {
}

class DeltaChartCell: ChartDataCell<DeltaChartView> {
}

class HistoryChartCell: ChartDataCell<HistoryChartView> {
}

class TopChartCell: ChartDataCell<TopChartView> {
}

class TrendlineChartCell: ChartDataCell<TrendlineChartView> {
}

class UpdateTimeCell: RegionDataCell {
	@IBOutlet var labelUpdated: UILabel!

	override func update(animated: Bool) {
		self.labelUpdated.text = "\(L10n.Data.updateDate) \(self.region?.report?.lastUpdate.relativeDateString ?? "-")"
	}
}

class DataSourceCell: RegionDataCell {
	@IBOutlet var labelSource: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()

		labelSource.text = L10n.Data.source("The Center for Systems Science and Engineering at Johns Hopkins")
	}

	@IBAction func buttonInfoTapped(_ sender: Any) {
		let url = URL(string: "https://arcgis.com/apps/opsdashboard/index.html#/85320e2ea5424dfaaa75ae62e5c06e61")!
		let safariController = SFSafariViewController(url: url)
		safariController.modalPresentationStyle = .pageSheet
		MapController.instance.present(safariController, animated: true)
	}
}
