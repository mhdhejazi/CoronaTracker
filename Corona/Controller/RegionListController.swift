//
//  RegionListController.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/14/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import CoronaTrackerData

class RegionListController: UITableViewController {
	var reports: [Report] = [] {
		didSet {
			tableView.reloadData()
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		tableView.rowHeight = 55
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return reports.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let identifier = String(describing: RegionCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RegionCell

		let report = reports[indexPath.row]
		cell.report = report

        return cell
    }
}

class RegionCell: UITableViewCell {
	var report: Report? {
		didSet {
			labelName.text = report?.region.name
			labelStats.text = report?.stat.confirmedCountString
		}
	}

	@IBOutlet var labelName: UILabel!
	@IBOutlet var labelStats: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()

		backgroundColor = .clear
	}
}
