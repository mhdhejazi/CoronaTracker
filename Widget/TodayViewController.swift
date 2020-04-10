//
//  Corona Tracker
//  Created by Piotr Ożóg on 12/03/2020.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
	static let numberPercentSwitchInterval: TimeInterval = 3 /// Seconds

	@IBOutlet private var worldwideTitleLabel: UILabel!
	@IBOutlet private var confirmedLabel: UILabel!
	@IBOutlet private var confirmedCountLabel: UILabel!
	@IBOutlet private var recoveredLabel: UILabel!
	@IBOutlet private var recoveredCountLabel: UILabel!
	@IBOutlet private var deathsLabel: UILabel!
	@IBOutlet private var deathsCountLabel: UILabel!
	@IBOutlet private var dataViews: [UIView]!
	@IBOutlet private var dataLabels: [UILabel]!
	@IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
	@IBOutlet private var updateTimeLabel: UILabel!

	private var report: Report?
	private var showPercents = false
	private var switchPercentsTask: DispatchWorkItem?

	override func viewDidLoad() {
		super.viewDidLoad()

		initializeView()

		DataManager.shared.load { [weak self] _ in
			self?.report = DataManager.shared.world.report
			self?.update()
		}
	}

	func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
		activityIndicatorView.startAnimating()
		updateTimeLabel.isHidden = true
		DataManager.shared.download { [weak self] success in
			completionHandler(success ? NCUpdateResult.newData : NCUpdateResult.failed)
			DataManager.shared.load { [weak self] _ in
				self?.report = DataManager.shared.world.report
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
		confirmedLabel.text = L10n.Case.confirmed.uppercased()
		recoveredLabel.text = L10n.Case.recovered.uppercased()
		deathsLabel.text = L10n.Case.deaths.uppercased()
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
				report.stat.recoveredPercentString :
				report.stat.recoveredCountString
		}
		deathsCountLabel.transition { [weak self] in
			self?.deathsCountLabel.text = self?.showPercents == true ?
				report.stat.deathPercentString :
				report.stat.deathCountString
		}
	}
}
