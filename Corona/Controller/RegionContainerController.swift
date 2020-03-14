//
//  RegionContainerController.swift
//  Corona
//
//  Created by Mohammad on 3/5/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class RegionContainerController: UIViewController {
	var regionListController: RegionListController!
	var regionController: RegionController!
	var isUpdating: Bool = false {
		didSet {
			updateTime()
		}
	}

	var isSearching: Bool = false {
		didSet {
			view.transition(duration: 0.25) {
				self.labelTitle.isHidden = self.isSearching
				self.labelUpdated.isHidden = self.isSearching
				self.buttonSearch.isHidden = self.isSearching
				self.searchBar.isHidden = !self.isSearching
				self.regionListController.view.isHidden = !self.isSearching
				self.regionController.view.isHidden = self.isSearching

				if self.isSearching {
					self.regionListController.reports = DataManager.instance.allReports
					self.searchBar.text = ""
					self.searchBar.becomeFirstResponder()
					MapController.instance.showRegionScreen()
				} else {
					self.regionListController.reports = []
					self.searchBar.resignFirstResponder()
				}
			}
		}
	}

	@IBOutlet var effectViewBackground: UIVisualEffectView!
	@IBOutlet var effectViewHeader: UIVisualEffectView!
	@IBOutlet var labelTitle: UILabel!
	@IBOutlet var labelUpdated: UILabel!
	@IBOutlet var buttonSearch: UIButton!
	@IBOutlet var searchBar: UISearchBar!

	override func viewDidLoad() {
		super.viewDidLoad()

		if #available(iOS 13.0, *) {
			effectViewBackground.effect = UIBlurEffect(style: .systemMaterial)
			effectViewBackground.contentView.alpha = 0

			effectViewHeader.effect = UIBlurEffect(style: .systemMaterial)
		}

		if #available(iOS 11.0, *) {
			/// Do nothing
		} else {
			/// iOS 10
			labelTitle.font = .boldSystemFont(ofSize: 24)
		}

		Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { _ in
			self.updateTime()
		}

		regionListController.tableView.isHidden = true
		regionListController.tableView.delegate = self
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is RegionController {
			regionController = segue.destination as? RegionController
		}
		else if segue.destination is RegionListController {
			regionListController = segue.destination as? RegionListController
		}
	}

	func update(report: Report?) {
		UIView.transition(with: view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
			self.labelTitle.text = report?.region.name ?? "No data"
		}, completion: nil)

		updateTime()
	}

	func updateTime() {
		if isUpdating {
			self.labelUpdated.text = "Updating..."
			return
		}

		self.labelUpdated.text = self.regionController.report?.lastUpdate.relativeTimeString
	}

	@IBAction func buttonSearchTapped(_ sender: Any) {
		isSearching = true
	}
}

extension RegionContainerController: UISearchBarDelegate, UITableViewDelegate {
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		isSearching = false
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		var reports = DataManager.instance.allReports

		let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		if !query.isEmpty {
			reports = reports.filter({ report in
				report.region.name.contains(query)
			})
		}

		regionListController.reports = reports
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let report = regionListController.reports[indexPath.row]

		regionController.report = report
		regionController.update()

		isSearching = false

		MapController.instance.hideRegionScreen()
		MapController.instance.showRegionOnMap(report: report)
	}
}
