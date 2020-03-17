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
	static let numberPercentSwitchInterval: TimeInterval = 3 /// Seconds

	var region: Region? {
		didSet {
			if region == nil {
				region = DataManager.instance.world
			}
		}
	}
	private var showPercents = false
	private var switchPercentsTask: DispatchWorkItem?

	@IBOutlet var stackViewStats: UIStackView!
	@IBOutlet var labelTitle: UILabel!
	@IBOutlet var labelConfirmed: UILabel!
	@IBOutlet var labelRecovered: UILabel!
	@IBOutlet var labelDeaths: UILabel!
	@IBOutlet var labelNewConfirmed: UILabel!
	@IBOutlet var labelNewRecovered: UILabel!
	@IBOutlet var labelNewDeaths: UILabel!
	@IBOutlet var chartViewCurrent: CurrentStateChartView!
	@IBOutlet var chartViewHistory: HistoryChartView!
	@IBOutlet var chartViewTopCountries: TopCountriesChartView!
	@IBOutlet var labelUpdated: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .clear
		tableView.tableFooterView = UIView()

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

		update()
	}

	override func didMove(toParent parent: UIViewController?) {
		super.didMove(toParent: parent)

		updateParent()
	}

	func update() {
		if region == nil {
			region = DataManager.instance.world
		}

		UIView.transition(with: stackViewStats, duration: 0.25, options: [.transitionCrossDissolve], animations: {
			self.labelTitle.text = self.region?.longName ?? "-"

			self.labelConfirmed.text = self.region?.report?.stat.confirmedCountString ?? "-"
			self.labelRecovered.text = self.region?.report?.stat.recoveredCountString ?? "-"
			self.labelDeaths.text = self.region?.report?.stat.deathCountString ?? "-"

			self.labelNewConfirmed.text = self.region?.dailyChange?.newConfirmedString ?? "-"
			self.labelNewRecovered.text = self.region?.dailyChange?.newRecoveredString ?? "-"
			self.labelNewDeaths.text = self.region?.dailyChange?.newDeathsString ?? "-"

			self.labelUpdated.text = "Last updated: \(self.region?.report?.lastUpdate.relativeDateString ?? "-")"
		}, completion: nil)

		chartViewCurrent.update(report: region?.report)
		chartViewHistory.update(series: region?.timeSeries)
		chartViewTopCountries.update()

		updateParent()

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

	func updateParent() {
		(parent as? RegionContainerController)?.update(region: region)
	}
}

extension RegionController {
	@IBAction func labelStatTapped(_ sender: Any) {
		self.showPercents = !self.showPercents
		updateStats()
	}

	@IBAction func buttonLogarithmicTapped(_ sender: Any) {
		UIView.transition(with: chartViewTopCountries, duration: 0.25, options: [.transitionCrossDissolve], animations: {
			self.chartViewTopCountries.isLogarithmic = !self.chartViewTopCountries.isLogarithmic
		}, completion: nil)
	}

	@IBAction func buttonInfoTapped(_ sender: Any) {
		let url = URL(string: "https://arcgis.com/apps/opsdashboard/index.html#/85320e2ea5424dfaaa75ae62e5c06e61")!
		let safariController = SFSafariViewController(url: url)
		safariController.modalPresentationStyle = .pageSheet
		present(safariController, animated: true)
	}
}
