//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/14/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class RegionListController: UITableViewController {
	var regions: [Region] = [] {
		didSet {
			tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.rowHeight = 55

		let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(tableViewPanned(_:)))
		panRecognizer.delegate = self
		tableView.addGestureRecognizer(panRecognizer)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

	}
}

extension RegionListController: UIGestureRecognizerDelegate {
	@objc
	func tableViewPanned(_ sender: Any) {
		MapController.shared.view.endEditing(false)
	}

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
						   shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		true
	}
}

extension RegionListController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		regions.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let identifier = String(describing: RegionCell.self)
		let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? RegionCell

		let region = regions[indexPath.row]
		cell?.region = region

		return cell!
	}
}

class RegionCell: UITableViewCell {
	@IBOutlet private var labelName: UILabel!
	@IBOutlet private var labelStats: UILabel!

	var region: Region? {
		didSet {
			labelName.text = region?.localizedLongName
			labelStats.text = region?.report?.stat.confirmedCountString
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		backgroundColor = .clear
	}
}
