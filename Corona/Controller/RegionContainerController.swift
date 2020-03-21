//
//  RegionContainerController.swift
//  Corona
//
//  Created by Mohammad on 3/5/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Disk

class RegionContainerController: UIViewController {
	private lazy var buttonDone: UIButton = {
		let button = UIButton(type: .system)
		button.titleLabel?.font = .boldSystemFont(ofSize: 17)
		button.setTitle("Done", for: .normal)
		button.addTarget(self, action: #selector(buttonDoneTapped(_:)), for: .touchUpInside)
		viewHeader.addSubview(button)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.trailingAnchor.constraint(equalTo: viewHeader.trailingAnchor, constant: -18).isActive = true
		button.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor).isActive = true
		return button
	}()

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
				self.buttonMenu.isHidden = self.isSearching
				self.buttonSearch.isHidden = self.isSearching
				self.searchBar.isHidden = !self.isSearching
				self.regionListController.view.superview?.isHidden = !self.isSearching
				self.regionController.view.isHidden = self.isSearching

				if self.isSearching {
					self.regionListController.regions = DataManager.instance.regions(of: .province).sorted().reversed()
					self.searchBar.text = ""
					self.searchBar.becomeFirstResponder()
					MapController.instance.showRegionScreen()
				} else {
					self.regionListController.regions = []
					self.searchBar.resignFirstResponder()
				}
			}
		}
	}

	@IBOutlet var effectViewBackground: UIVisualEffectView!
	@IBOutlet var effectViewHeader: UIVisualEffectView!
	@IBOutlet var viewHeader: UIView!
	@IBOutlet var labelTitle: UILabel!
	@IBOutlet var labelUpdated: UILabel!
	@IBOutlet var buttonMenu: UIButton!
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
			labelTitle.font = .preferredFont(forTextStyle: .largeTitle)
		} else {
			/// iOS 10
			labelTitle.font = .boldSystemFont(ofSize: 24)
		}

		Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { _ in
			self.updateTime()
		}

		regionListController.tableView.superview?.isHidden = true
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

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		viewHeader.transition(duration: 0.25) {
			self.buttonDone.isHidden = !editing
			self.buttonMenu.isHidden = editing
			self.buttonSearch.isHidden = editing
		}
	}

	func update(region: Region?) {
		viewHeader.transition(duration: 0.25) {
			self.labelTitle.text = region?.longName ?? "N/A"
		}

		updateTime()
	}

	func updateTime() {
		if isUpdating {
			self.labelUpdated.text = "Updating..."
			return
		}

		self.labelUpdated.text = self.regionController.region?.report?.lastUpdate.relativeTimeString
	}

	func snapshotHeader(hideTitle: Bool = false) -> UIImage {
		if hideTitle {
			labelTitle.isHidden = true
		}
		buttonDone.isHidden = true
		let image = viewHeader.snapshot()
		labelTitle.isHidden = false

		return image
	}
}

extension RegionContainerController {
	@IBAction func buttonSearchTapped(_ sender: Any) {
		isSearching = true
	}

	@IBAction func buttonMenuTapped(_ sender: Any) {
		var items = [
			MenuItem(title: "Update", image: UIImage(named: "Reload")!, action: {
				MapController.instance.downloadIfNeeded()
			}),
			MenuItem(title: "Share", image: UIImage(named: "Share")!, action: {
				MapController.instance.showRegionScreen()
				self.regionController.setEditing(true, animated: true)
			})
		]
		addFavoriteItem(items: &items)

		Menu.show(above: self, sourceView: buttonMenu, items: items)
	}

	func addFavoriteItem(items: inout [MenuItem]) {
		guard let region = self.regionController.region, region != .world else { return }

		let currentRegion = try? Disk.retrieve(Region.favoriteRegionFileName,
											   from: .sharedContainer(appGroupName: Region.favoriteGroupContainerName),
											   as: Region.self)

		let isAdded = (currentRegion == region)

		items.append(MenuItem(title: isAdded ? "Hide in widget" : "Show in widget",
							  image: UIImage(named: "Star")!,
							  action: {

				try? Disk.save(isAdded ? nil : region,
						   to: .sharedContainer(appGroupName: Region.favoriteGroupContainerName),
						   as: Region.favoriteRegionFileName)
		}))
	}

	@objc func buttonDoneTapped(_ sender: Any) {
		setEditing(false, animated: true)
		regionController.setEditing(false, animated: true)
	}
}

extension RegionContainerController: UISearchBarDelegate, UITableViewDelegate {
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		isSearching = false
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		var regions: [Region] = DataManager.instance.regions(of: .province).sorted().reversed()

		let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
		if !query.isEmpty {
			regions = regions.filter({ region in
				region.longName.lowercased().contains(query)
			})
		}

		regionListController.regions = regions
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let region = regionListController.regions[indexPath.row]

		regionController.region = region
		regionController.update()

		isSearching = false

		MapController.instance.hideRegionScreen()
		MapController.instance.showRegionOnMap(region: region)
	}
}
