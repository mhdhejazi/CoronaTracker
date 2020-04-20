//
//  Corona Tracker
//  Created by Mhd Hejazi on 4/8/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import SafariServices

class DataSourceCell: RegionDataCell {
	@IBOutlet private var labelSource: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()

		labelSource.text = L10n.Data.source("")
	}

	// MARK: - Actions

	@IBAction private func buttonJHUTapped(_ sender: Any) {
		let url = URL(string: "https://arcgis.com/apps/opsdashboard/index.html#/85320e2ea5424dfaaa75ae62e5c06e61")!
		let safariController = SFSafariViewController(url: url)
		safariController.modalPresentationStyle = .pageSheet
		App.topViewController.present(safariController, animated: true)
	}

	@IBAction private func buttonBingTapped(_ sender: Any) {
		let url = URL(string: "https://bing.com/covid/")!
		let safariController = SFSafariViewController(url: url)
		safariController.modalPresentationStyle = .pageSheet
		App.topViewController.present(safariController, animated: true)
	}

	@IBAction private func buttonRKITapped(_ sender: Any) {
		let url = URL(string: "https://experience.arcgis.com/experience/478220a4c454480e823b17327b2bf1d4/")!
		let safariController = SFSafariViewController(url: url)
		safariController.modalPresentationStyle = .pageSheet
		App.topViewController.present(safariController, animated: true)
	}
}
