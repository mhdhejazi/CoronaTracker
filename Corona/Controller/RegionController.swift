//
//  RegionController.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import SafariServices

import Charts

class RegionController: UITableViewController {
	private typealias Cell = (type: RegionInfoCell.Type, height: CGFloat)
	private let cells: [Cell] = [
		(type: StatsCell.self, height: 150),
		(type: CurrentChartCell.self, height: 250),
		(type: DeltaChartCell.self, height: 250),
		(type: HistoryChartCell.self, height: 300),
		(type: TopChartCell.self, height: 350),
		(type: UpdateTimeCell.self, height: 40),
		(type: DataSourceCell.self, height: 50)
	]

	var region: Region? {
		didSet {
			if region == nil {
				region = DataManager.instance.world
			}
		}
	}
	private var container: RegionContainerController? { parent as? RegionContainerController }

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .clear
		tableView.tableFooterView = UIView()
	}

	override func didMove(toParent parent: UIViewController?) {
		super.didMove(toParent: parent)

		updateParent()
	}

	func update() {
		if region == nil {
			region = DataManager.instance.world
		}

		for cell in tableView.visibleCells {
			(cell as? RegionInfoCell)?.region = region
		}

		updateParent()
	}

	func updateParent() {
		container?.update(region: region)
	}

	private func shareImage(for cell: RegionInfoCell?) {
		guard let cell = cell, let shareable = cell.shareable else { return }

		let cellImage = cell.snapshot()
		let headerImage = container!.snapshotHeader(hideTitle: shareable == .chartTop)
		var logoImage = Asset.iconSmall.image
		if #available(iOS 13.0, *) {
			logoImage = logoImage.withTintColor(SystemColor.secondaryLabel)
		}

		let newSize = CGSize(width: cellImage.size.width, height: cellImage.size.height + headerImage.size.height)
		let newBounds = CGRect(origin: .zero, size: newSize)
		let image = UIGraphicsImageRenderer(bounds: newBounds).image { rendererContext in
			SystemColor.secondarySystemBackground.setFill()
			rendererContext.fill(newBounds)

			headerImage.draw(at: .zero)
			logoImage.draw(at: .init(x: headerImage.size.width - 60, y: 22))
			cellImage.draw(at: .init(x: 0, y: headerImage.size.height))
		}

		var items: [Any] = [ImageItemSource(image: image, imageName: "Corona Tracker")]
		items.append(TextItemSource(text: shareable.title))

		let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)

		if UIDevice.current.userInterfaceIdiom == .pad {
			activityController.modalPresentationStyle = .popover
			activityController.popoverPresentationController?.sourceView = cell
			activityController.popoverPresentationController?.sourceRect = cell.bounds
		}
		present(activityController, animated: true, completion: nil)
	}
}

extension RegionController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		cells.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellType = cells[indexPath.row].type
		let cell = tableView.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath)
		if let cell = cell as? RegionInfoCell {
			cell.region = region
			cell.shareAction = {
				self.setEditing(false, animated: true)
				self.shareImage(for: cell)
			}
		}
		return cell
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		cells[indexPath.row].height
	}

	override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		false
	}

	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		.none
	}

	@available(iOS 11.0, *)
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let cell = tableView.cellForRow(at: indexPath) as? RegionInfoCell
		let action = UIContextualAction(style: .normal, title: nil) { action, sourceView, completion in
			completion(true)
			self.shareImage(for: cell)
		}
		action.image = Asset.shareCircle.image
		action.backgroundColor = UIColor.black.withAlphaComponent(0.001)

		let config = UISwipeActionsConfiguration(actions: [action])
		return config
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		container?.setEditing(editing, animated: animated)
	}
}

class RegionInfoCell: UITableViewCell {
	class var reuseIdentifier: String { String(describing: Self.self) }

	enum Shareable {
		case stats
		case chartCurrent
		case chartDelta
		case chartHistory
		case chartTop

		var title: String {
			switch self {
			case .stats: return L10n.Share.current
			case .chartCurrent: return L10n.Chart.delta
			case .chartDelta: return L10n.Share.current
			case .chartHistory: return L10n.Share.chartHistory
			case .chartTop: return L10n.Chart.topCountries
			}
		}
	}

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
	var shareAction: (() -> Void)? = nil

	var shareable: Shareable? { nil }
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
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		guard shareable != nil, superview is UITableView else { return }

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

class StatsCell: RegionInfoCell {
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

	override var shareable: Shareable? { .stats }

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
				report.stat.recoveredPercent.percentFormatted :
				report.stat.recoveredCountString
		}
		labelDeaths.transition {
			self.labelDeaths.text = self.showPercents ?
				report.stat.deathPercent.percentFormatted :
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

class CurrentChartCell: RegionInfoCell {
	@IBOutlet var chartViewCurrent: CurrentStateChartView!

	override var shareable: Shareable? { .chartCurrent }

	override func update(animated: Bool) {
		chartViewCurrent.update(report: region?.report, animated: animated)
	}
}

class DeltaChartCell: RegionInfoCell {
	@IBOutlet var chartViewDelta: DeltaChartView!

	override var shareable: Shareable? { .chartDelta }

	override func update(animated: Bool) {
		chartViewDelta.update(series: region?.timeSeries, animated: animated)
	}
}

class HistoryChartCell: RegionInfoCell {
	@IBOutlet var chartViewHistory: HistoryChartView!

	override var shareable: Shareable? { .chartHistory }

	override func update(animated: Bool) {
		chartViewHistory.update(series: region?.timeSeries, animated: animated)
	}
}

class TopChartCell: RegionInfoCell {
	@IBOutlet var chartViewTopCountries: TopCountriesChartView!

	override var shareable: Shareable? { .chartTop }

	override func update(animated: Bool) {
		chartViewTopCountries.update(animated: animated)
	}

	@IBAction func buttonLogarithmicTapped(_ sender: Any) {
		UIView.transition(with: chartViewTopCountries, duration: 0.25, options: [.transitionCrossDissolve], animations: {
			self.chartViewTopCountries.isLogarithmic = !self.chartViewTopCountries.isLogarithmic
		}, completion: nil)
	}
}

class UpdateTimeCell: RegionInfoCell {
	@IBOutlet var labelUpdated: UILabel!

	override func update(animated: Bool) {
		self.labelUpdated.text = "\(L10n.Data.updateDate) \(self.region?.report?.lastUpdate.relativeDateString ?? "-")"
	}
}

class DataSourceCell: RegionInfoCell {
	@IBAction func buttonInfoTapped(_ sender: Any) {
		let url = URL(string: "https://arcgis.com/apps/opsdashboard/index.html#/85320e2ea5424dfaaa75ae62e5c06e61")!
		let safariController = SFSafariViewController(url: url)
		safariController.modalPresentationStyle = .pageSheet
		MapController.instance.present(safariController, animated: true)
	}
}
