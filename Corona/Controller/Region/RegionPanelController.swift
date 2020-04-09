//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/5/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class RegionPanelController: UIViewController {
	private lazy var buttonDone: UIButton = {
		let button = UIButton(type: .system)
		button.titleLabel?.font = .boldSystemFont(ofSize: 17)
		button.setTitle(L10n.Message.done, for: .normal)
		button.addTarget(self, action: #selector(buttonDoneTapped(_:)), for: .touchUpInside)
		viewHeader.addSubview(button)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.trailingAnchor.constraint(equalTo: viewHeader.trailingAnchor, constant: -18).isActive = true
		button.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor).isActive = true
		return button
	}()

	var regionListController: RegionListController!
	var regionDataController: RegionDataController!
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
				self.regionDataController.view.isHidden = self.isSearching

				if self.isSearching {
					self.regionListController.regions = DataManager.instance.allRegions().sorted().reversed()
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

	@IBOutlet private var effectViewBackground: UIVisualEffectView!
	@IBOutlet private var effectViewHeader: UIVisualEffectView!
	@IBOutlet private var viewHeader: UIView!
	@IBOutlet private var labelTitle: UILabel!
	@IBOutlet private var labelUpdated: UILabel!
	@IBOutlet private var buttonMenu: UIButton!
	@IBOutlet private var buttonSearch: UIButton!
	@IBOutlet private var searchBar: UISearchBar!

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
		if segue.destination is RegionDataController {
			regionDataController = segue.destination as? RegionDataController
		} else if segue.destination is RegionListController {
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
			self.labelTitle.text = region?.localizedLongName ?? Region.world.localizedName
		}

		updateTime()
	}

	func updateTime() {
		if isUpdating {
			self.labelUpdated.text = L10n.Data.updating
			return
		}

		self.labelUpdated.text = self.regionDataController.region?.report?.lastUpdate.relativeTimeString
	}

	func snapshotHeader(hideTitle: Bool = false) -> UIImage {
		if hideTitle {
			labelTitle.isHidden = true
		}
		buttonDone.isHidden = true
		buttonSearch.isHidden = true
		buttonMenu.isHidden = true
		let image = viewHeader.snapshot()
		buttonSearch.isHidden = false
		buttonMenu.isHidden = false
		labelTitle.isHidden = false

		return image
	}
}

extension RegionPanelController {

	// MARK: - Actions

	@IBAction private func buttonSearchTapped(_ sender: Any) {
		isSearching = true
	}

	@IBAction private func buttonMenuTapped(_ sender: Any) {
		Menu.show(above: self, sourceView: buttonMenu, items: [
			.regular(title: L10n.Menu.update, image: Asset.reload.image) {
				MapController.instance.downloadIfNeeded()
			},
			.regular(title: L10n.Menu.share, image: Asset.share.image) {
				MapController.instance.showShareButtons()
			}
		])
	}

	@objc
	func buttonDoneTapped(_ sender: Any) {
		setEditing(false, animated: true)
		regionDataController.setEditing(false, animated: true)
	}
}

extension RegionPanelController: UISearchBarDelegate, UITableViewDelegate {
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		isSearching = false
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		var regions: [Region] = DataManager.instance.allRegions().sorted().reversed()

		let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		if !query.isEmpty {
			regions = regions.filter({ region in
				region.localizedLongName.range(of: query, options: [.diacriticInsensitive, .caseInsensitive]) != nil
			})
		}

		regionListController.regions = regions
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let region = regionListController.regions[indexPath.row]

		regionDataController.region = region
		regionDataController.update()

		isSearching = false

		MapController.instance.showRegionOnMap(region: region)
	}
}
