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

class CurrentChartCell: RegionDataCell {
	@IBOutlet var chartView: CurrentChartView!

	override var shareable: Shareable? { .chartCurrent }

	override func update(animated: Bool) {
		chartView.update(report: region?.report, animated: animated)
	}
}

class DeltaChartCell: RegionDataCell {
	@IBOutlet var chartView: DeltaChartView!

	override var shareable: Shareable? { .chartDelta }

	override func update(animated: Bool) {
		chartView.update(series: region?.timeSeries, animated: animated)
	}
}

class HistoryChartCell: RegionDataCell {
	@IBOutlet var chartView: HistoryChartView!

	override var shareable: Shareable? { .chartHistory }

	override func update(animated: Bool) {
		chartView.update(series: region?.timeSeries, animated: animated)
	}
}

class TopChartCell: RegionDataCell {
	@IBOutlet var chartView: TopChartView!

	override var shareable: Shareable? { .chartTop }

	override func update(animated: Bool) {
		chartView.update(animated: animated)
	}

	@IBAction func buttonLogarithmicTapped(_ sender: Any) {
		UIView.transition(with: chartView, duration: 0.25, options: [.transitionCrossDissolve], animations: {
			self.chartView.isLogarithmic = !self.chartView.isLogarithmic
		}, completion: nil)
	}
}

class UpdateTimeCell: RegionDataCell {
	@IBOutlet var labelUpdated: UILabel!

	override func update(animated: Bool) {
		self.labelUpdated.text = "\(L10n.Data.updateDate) \(self.region?.report?.lastUpdate.relativeDateString ?? "-")"
	}
}

class DataSourceCell: RegionDataCell {
	@IBAction func buttonInfoTapped(_ sender: Any) {
		let url = URL(string: "https://arcgis.com/apps/opsdashboard/index.html#/85320e2ea5424dfaaa75ae62e5c06e61")!
		let safariController = SFSafariViewController(url: url)
		safariController.modalPresentationStyle = .pageSheet
		MapController.instance.present(safariController, animated: true)
	}
}
