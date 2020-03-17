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
    private static let favoriteRegionFileName = "favorite.json"

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
                self.favoriteButton.isHidden = self.isSearching
				self.labelUpdated.isHidden = self.isSearching
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
	@IBOutlet var labelTitle: UILabel!
    @IBOutlet var favoriteButton: UIButton!
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

	func update(region: Region?) {
        updateFavoriteIcon(region: region)
		UIView.transition(with: view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
			self.labelTitle.text = region?.longName ?? "N/A"
		}, completion: nil)

		updateTime()
	}

    private func updateFavoriteIcon(region: Region?) {
        guard region != Region.world else {
            self.favoriteButton.isHidden = true
            return
        }
        self.favoriteButton.isHidden = false
        let favoriteRegion = try? Disk.retrieve(Self.favoriteRegionFileName, from: .caches, as: Region.self)
        let isFavorite = region == favoriteRegion
        self.favoriteButton.setImage(isFavorite ? UIImage(named: "favoriteFilled") : UIImage(named: "favorite"), for: .normal)
    }

	func updateTime() {
		if isUpdating {
			self.labelUpdated.text = "Updating..."
			return
		}

		self.labelUpdated.text = self.regionController.region?.report?.lastUpdate.relativeTimeString
	}

	@IBAction func buttonSearchTapped(_ sender: Any) {
		isSearching = true
	}

    @IBAction func favoriteButtonTapped(_ sender: Any) {
        guard let region = self.regionController.region else {
            return
        }
        try? Disk.save(region, to: .caches, as: Self.favoriteRegionFileName)
        self.updateFavoriteIcon(region: region)
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
