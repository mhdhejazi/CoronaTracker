//
//  TodayViewController.swift
//  CoronaTrackerWidget
//
//  Created by Piotr Ożóg on 12/03/2020.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
	static let numberPercentSwitchInterval: TimeInterval = 3 /// Seconds

	private var report: Report?
	private var showPercents = false
	private var switchPercentsTask: DispatchWorkItem?

	@IBOutlet var worldwideTitleLabel: UILabel!
	@IBOutlet var confirmedLabel: UILabel!
	@IBOutlet var confirmedCountLabel: UILabel!
	@IBOutlet var recoveredLabel: UILabel!
	@IBOutlet var recoveredCountLabel: UILabel!
	@IBOutlet var deathsLabel: UILabel!
	@IBOutlet var deathsCountLabel: UILabel!
	@IBOutlet var dataViews: [UIView]!
	@IBOutlet var dataLabels: [UILabel]!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
	@IBOutlet var updateTimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeView()

		DataManager.instance.load { [weak self] success in
			self?.report = DataManager.instance.world.report
			self?.update()
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
            }
        }
    }

	private func initializeView() {
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

		worldwideTitleLabel.text = L10n.Region.world
		confirmedLabel.text = L10n.Case.confirmed
		recoveredLabel.text = L10n.Case.recovered
		deathsLabel.text = L10n.Case.deaths
	}

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
}
