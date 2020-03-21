//
//  TodayViewController.swift
//  CoronaTrackerWidget
//
//  Created by Piotr Ożóg on 12/03/2020.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import NotificationCenter

import Disk

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet var worldwideStatView: StatsView!
    @IBOutlet var favoriteStatView: StatsView!

    private var savedFavoriteRegion: Region? {
	return try? Disk.retrieve(Region.favoriteRegionFileName, from: .sharedContainer(appGroupName: Region.favoriteGroupContainerName), as: Region.self)
    }

    private var favorite: Region? {
	return DataManager.instance.regions(of: .country).first(where: { $0 == savedFavoriteRegion })
    }

    override func viewDidLoad() {
	super.viewDidLoad()
	let hasFavorite = savedFavoriteRegion != nil
	self.extensionContext?.widgetLargestAvailableDisplayMode = hasFavorite ? .expanded : .compact
	self.favoriteStatView.isHidden = !hasFavorite

	DataManager.instance.load { [weak self] success in
	    self?.worldwideStatView.update(region: DataManager.instance.world)

	    if let favorite = self?.favorite {
		self?.favoriteStatView.update(region: favorite)
	    }
	}
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {

	self.favoriteStatView.isHidden = activeDisplayMode == NCWidgetDisplayMode.compact
	if activeDisplayMode == NCWidgetDisplayMode.compact {
	    //compact
	    self.preferredContentSize = CGSize(width: maxSize.width, height: 110)
	} else {
	    //extended
	    self.preferredContentSize = CGSize(width: maxSize.width, height: 220)
	}
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
	self.favoriteStatView.isUpdatingData = true
	self.worldwideStatView.isUpdatingData = true
	DataManager.instance.download { [weak self] success in
	    completionHandler(success ? NCUpdateResult.newData : NCUpdateResult.failed)
	    DataManager.instance.load { [weak self] success in
		self?.worldwideStatView.isUpdatingData = false
		self?.favoriteStatView.isUpdatingData = false
		self?.worldwideStatView.update(region: DataManager.instance.world)
		if let favorite = self?.favorite {
		    self?.favoriteStatView.update(region: favorite)
		}
	    }
	}
    }
}
