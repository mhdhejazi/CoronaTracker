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
	var report: Report? {
		didSet {
			if report == nil {
				report = DataManager.instance.worldwideReport
			}

			if let region = report?.region {
				timeSeries = DataManager.instance.timeSeries(for: region)
			}
		}
	}
	private var timeSeries: TimeSeries?

	@IBOutlet var labelTitle: UILabel!
	@IBOutlet var labelConfirmed: UILabel!
	@IBOutlet var labelRecovered: UILabel!
	@IBOutlet var labelDeaths: UILabel!
	@IBOutlet var chartViewCurrent: CurrentStateChartView!
	@IBOutlet var chartViewHistory: HistoryChartView!
	@IBOutlet var chartViewTopCountries: TopCountriesChartView!
	@IBOutlet var labelUpdated: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .clear
		tableView.tableFooterView = UIView()

		if #available(iOS 11.0, *) {
			/// Do nothing
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
		if report == nil || timeSeries == nil {
			report = DataManager.instance.worldwideReport
		}

		UIView.transition(with: view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
			self.labelTitle.text = self.report?.region.name ?? "-"
			self.labelConfirmed.text = self.report?.stat.confirmedCountString ?? "-"
			self.labelRecovered.text = self.report?.stat.recoveredCountString ?? "-"
			self.labelDeaths.text = self.report?.stat.deathCountString ?? "-"
			self.labelUpdated.text = "Last updated: \(self.report?.hourAge ?? 0) hours ago"
		}, completion: nil)

		if let report = report {
			chartViewCurrent.update(report: report)
		}

		if let series = timeSeries {
			chartViewHistory.update(series: series)
		}

		chartViewTopCountries.update(reports: DataManager.instance.topReports)

		updateParent()
	}

	func updateParent() {
		(parent as? RegionContainerController)?.update(report: report)
	}
}

extension RegionController {
	@IBAction func buttonInfoTapped(_ sender: Any) {
		let url = URL(string: "https://gisanddata.maps.arcgis.com/apps/opsdashboard/index.html#/bda7594740fd40299423467b48e9ecf6")!
		let safariController = SFSafariViewController(url: url)
		safariController.modalPresentationStyle = .pageSheet
		present(safariController, animated: true)
	}
}
