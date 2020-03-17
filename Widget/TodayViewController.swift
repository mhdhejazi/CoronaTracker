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

    private var favoriteRegion: Region? {
        return try? Disk.retrieve(Region.favoriteRegionFileName, from: .sharedContainer(appGroupName: Region.favoriteGroupContainerName), as: Region.self)
    }

    private var favoriteReport: Report? {
        return DataManager.instance.regions(of: .country).first(where: {$0 == favoriteRegion})?.report
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = favoriteRegion != nil ? .expanded : .compact

		DataManager.instance.load { [weak self] success in
            self?.worldwideStatView.update(report: DataManager.instance.world.report)

            if let favorite = self?.favoriteRegion, let favoriteReport = DataManager.instance.regions(of: .country).first(where: {$0 == favorite})?.report {
                self?.favoriteStatView.update(report: favoriteReport)
            }
		}
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {

        if activeDisplayMode == NCWidgetDisplayMode.compact {
            //compact
            self.preferredContentSize = CGSize(width: maxSize.width, height: 110)
        } else {
            //extended
            self.preferredContentSize = CGSize(width: maxSize.width, height: 220)
        }
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        self.worldwideStatView.isUpdatingData = true
        self.favoriteStatView.isUpdatingData = true
        DataManager.instance.download { [weak self] success in
            completionHandler(success ? NCUpdateResult.newData : NCUpdateResult.failed)
            DataManager.instance.load { [weak self] success in
                self?.worldwideStatView.isUpdatingData = false
                self?.favoriteStatView.isUpdatingData = false
                self?.worldwideStatView.update(report: DataManager.instance.world.report)
                self?.favoriteStatView.update(report: self?.favoriteReport)
            }
        }
    }
}
