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
	static let numberPercentSwitchInterval: TimeInterval = 3 /// Seconds

	private var report: Report?
    private var favoriteReport: Report?
	private var showPercents = false
	private var switchPercentsTask: DispatchWorkItem?

	@IBOutlet var worldwideTitleLabel: UILabel!
    @IBOutlet var confirmedCountLabel: UILabel!
    @IBOutlet var recoveredCountLabel: UILabel!
    @IBOutlet var deathsCountLabel: UILabel!
	@IBOutlet var dataViews: [UIView]!
	@IBOutlet var dataLabels: [UILabel]!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
	@IBOutlet var updateTimeLabel: UILabel!

    @IBOutlet var favoriteContainerView: UIView!
    @IBOutlet var favoriteTitleLabel: UILabel!
    @IBOutlet var favoriteConfirmedCountLabel: UILabel!
    @IBOutlet var favoriteRecoveredCountLabel: UILabel!
    @IBOutlet var favoriteDeathsCountLabel: UILabel!
    @IBOutlet var favoriteDataViews: [UIView]!
    @IBOutlet var favoriteDataLabels: [UILabel]!
    @IBOutlet var favoriteActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var favoriteUpdateTimeLabel: UILabel!

    private var favoriteRegion: Region? {
        return try? Disk.retrieve(Region.favoriteRegionFileName, from: .sharedContainer(appGroupName: Region.favoriteGroupContainerName), as: Region.self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = favoriteRegion != nil ? .expanded : .compact
        initializeView()

		DataManager.instance.load { [weak self] success in
			self?.report = DataManager.instance.world.report
            if let favorite = self?.favoriteRegion {
                self?.favoriteReport = DataManager.instance.regions(of: .country).first(where: {$0 == favorite})?.report
            }
			self?.update()
            self?.updateFavorite()
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
        activityIndicatorView.startAnimating()
		updateTimeLabel.isHidden = true
        DataManager.instance.download { [weak self] success in
            completionHandler(success ? NCUpdateResult.newData : NCUpdateResult.failed)
            DataManager.instance.load { [weak self] success in
				self?.report = DataManager.instance.world.report
                self?.activityIndicatorView.stopAnimating()
				self?.updateTimeLabel.isHidden = false
                self?.update()

                if let favorite = self?.favoriteRegion {
                    self?.favoriteReport = DataManager.instance.regions(of: .country).first(where: {$0 == favorite})?.report
                }
                self?.favoriteActivityIndicatorView.stopAnimating()
                self?.favoriteUpdateTimeLabel.isHidden = false
                self?.updateFavoriteStats()
            }
        }
    }

	private func initializeView() {
        favoriteContainerView.isHidden = favoriteRegion == nil
		dataViews.forEach { view in
			view.layer.cornerRadius = 8
		}
		dataLabels.forEach { label in
			label.textColor = .white
		}
		updateTimeLabel.textColor = SystemColor.secondaryLabel
		if #available(iOSApplicationExtension 13.0, *) {
			activityIndicatorView.style = .medium
		}
	}

    // Worldwide
    private func update() {
        guard let report = report else {
            return
        }

		view.transition { [weak self] in
			self?.confirmedCountLabel.text = report.stat.confirmedCountString
			self?.recoveredCountLabel.text = report.stat.recoveredCountString
			self?.deathsCountLabel.text = report.stat.deathCountString
			self?.updateTimeLabel.text = report.lastUpdate.relativeTimeString
		}

		updateStats()
    }

	private func updateStats(reset: Bool = false) {
		switchPercentsTask?.cancel()
		let task = DispatchWorkItem { [weak self] in
			self?.showPercents = !(self?.showPercents ?? false)
			self?.updateStats()
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + Self.numberPercentSwitchInterval, execute: task)
		switchPercentsTask = task

		if reset {
			showPercents = false
			return
		}

		guard let report = report else { return }
		recoveredCountLabel.transition { [weak self] in
			self?.recoveredCountLabel.text = self?.showPercents == true ?
				report.stat.recoveredPercent.percentFormatted :
				report.stat.recoveredCountString
		}
		deathsCountLabel.transition { [weak self] in
			self?.deathsCountLabel.text = self?.showPercents == true ?
				report.stat.deathPercent.percentFormatted :
				report.stat.deathCountString
		}
	}

    // Favorite

    private func updateFavorite() {
        guard let report = favoriteReport else {
            return
        }

        view.transition { [weak self] in
            self?.favoriteConfirmedCountLabel.text = report.stat.confirmedCountString
            self?.favoriteRecoveredCountLabel.text = report.stat.recoveredCountString
            self?.favoriteDeathsCountLabel.text = report.stat.deathCountString
            self?.favoriteUpdateTimeLabel.text = report.lastUpdate.relativeTimeString
        }

        updateFavoriteStats()
    }

    private func updateFavoriteStats(reset: Bool = false) {
        switchPercentsTask?.cancel()
        let task = DispatchWorkItem { [weak self] in
            self?.showPercents = !(self?.showPercents ?? false)
            self?.updateFavoriteStats()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.numberPercentSwitchInterval, execute: task)
        switchPercentsTask = task

        if reset {
            showPercents = false
            return
        }

        guard let report = favoriteReport else { return }
        favoriteRecoveredCountLabel.transition { [weak self] in
            self?.favoriteRecoveredCountLabel.text = self?.showPercents == true ?
                report.stat.recoveredPercent.percentFormatted :
                report.stat.recoveredCountString
        }
        favoriteDeathsCountLabel.transition { [weak self] in
            self?.favoriteDeathsCountLabel.text = self?.showPercents == true ?
                report.stat.deathPercent.percentFormatted :
                report.stat.deathCountString
        }
    }
}
