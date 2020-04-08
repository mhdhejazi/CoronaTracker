//
//  Corona Tracker
//  Created by Mhd Hejazi on 4/8/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class StatsCell: RegionDataCell {
	static let numberPercentSwitchInterval: TimeInterval = 3 /// Seconds

	private var showPercents = false
	private var switchPercentsTask: DispatchWorkItem?

	@IBOutlet private var labelConfirmedTitle: UILabel!
	@IBOutlet private var labelConfirmed: UILabel!
	@IBOutlet private var labelNewConfirmed: UILabel!
	@IBOutlet private var labelRecoveredTitle: UILabel!
	@IBOutlet private var labelRecovered: UILabel!
	@IBOutlet private var labelNewRecovered: UILabel!
	@IBOutlet private var labelDeathsTitle: UILabel!
	@IBOutlet private var labelDeaths: UILabel!
	@IBOutlet private var labelNewDeaths: UILabel!

	override var shareableImage: UIImage? { snapshot() }
	override var shareableText: String? { L10n.Share.current }

	override func awakeFromNib() {
		super.awakeFromNib()

		if #available(iOS 11.0, *) {
			labelConfirmed.font = .preferredFont(forTextStyle: .largeTitle)
			labelRecovered.font = .preferredFont(forTextStyle: .largeTitle)
			labelDeaths.font = .preferredFont(forTextStyle: .largeTitle)
		} else {
			labelConfirmed.font = .systemFont(ofSize: 24)
			labelRecovered.font = .systemFont(ofSize: 24)
			labelDeaths.font = .systemFont(ofSize: 24)
		}

		labelConfirmedTitle.text = L10n.Case.confirmed.uppercased()
		labelRecoveredTitle.text = L10n.Case.recovered.uppercased()
		labelDeathsTitle.text = L10n.Case.deaths.uppercased()

		contentView.alpha = 0
		contentView.transform = CGAffineTransform.init(scaleX: 0.95, y: 0.95)
		contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:))))
	}

	override func update(animated: Bool) {
		DispatchQueue.main.async {
			self.contentView.transition(duration: 0.25) {
				self.contentView.alpha = 1
				self.contentView.transform = .identity
				self.labelConfirmed.text = self.region?.report?.stat.confirmedCountString ?? "-"
				self.labelRecovered.text = self.region?.report?.stat.recoveredCountString ?? "-"
				self.labelDeaths.text = self.region?.report?.stat.deathCountString ?? "-"

				self.labelNewConfirmed.text = self.region?.dailyChange?.newConfirmedString ?? "-"
				self.labelNewRecovered.text = self.region?.dailyChange?.newRecoveredString ?? "-"
				self.labelNewDeaths.text = self.region?.dailyChange?.newDeathsString ?? "-"
			}
		}
		updateStats(reset: true)
	}

	private func updateStats(reset: Bool = false) {
		switchPercentsTask?.cancel()
		let task = DispatchWorkItem {
			self.showPercents.toggle()
			self.updateStats()
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + Self.numberPercentSwitchInterval, execute: task)
		switchPercentsTask = task

		if reset {
			showPercents = false
			return
		}

		guard let report = region?.report else { return }
		contentView.transition {
			self.labelRecovered.text = self.showPercents ?
				report.stat.recoveredPercentString :
				report.stat.recoveredCountString

			self.labelDeaths.text = self.showPercents ?
				report.stat.deathPercentString :
				report.stat.deathCountString

			self.labelNewConfirmed.text = self.showPercents ?
				self.region?.dailyChange?.confirmedGrowthString ?? "-" :
				self.region?.dailyChange?.newConfirmedString ?? "-"

			self.labelNewRecovered.text = self.showPercents ?
				self.region?.dailyChange?.recoveredGrowthString ?? "-" :
				self.region?.dailyChange?.newRecoveredString ?? "-"

			self.labelNewDeaths.text = self.showPercents ?
				self.region?.dailyChange?.deathsGrowthString ?? "-" :
				self.region?.dailyChange?.newDeathsString ?? "-"
		}
	}

	@objc
	func cellTapped(_ sender: Any) {
		self.showPercents.toggle()
		updateStats()
	}
}
