//
//  Corona Tracker
//  Created by Mhd Hejazi on 4/8/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import SafariServices

class AuthorInfoCell: RegionDataCell {
	override func awakeFromNib() {
		super.awakeFromNib()
	}

	// MARK: - Actions

	@IBAction private func buttonInfoTapped(_ sender: Any) {
		let url = URL(string: "https://coronatracker.samabox.com")!
		let safariController = SFSafariViewController(url: url)
		safariController.modalPresentationStyle = .pageSheet
		App.topViewController.present(safariController, animated: true)
	}

	@IBAction private func buttonTwitterTapped(_ sender: Any) {
		let twitterAppURL = URL(string: "twitter://user?screen_name=Hejazi")!
		let twitterWebURL = URL(string: "https://twitter.com/Hejazi")!

		if UIApplication.shared.canOpenURL(twitterAppURL) {
			UIApplication.shared.open(twitterAppURL)
		} else {
			UIApplication.shared.open(twitterWebURL)
		}
	}
}
