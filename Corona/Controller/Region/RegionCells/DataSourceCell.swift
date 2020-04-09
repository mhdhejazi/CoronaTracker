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

		labelSource.text = L10n.Data.source("CSSE at Johns Hopkins University")
	}

	// MARK: - Actions

	@IBAction private func buttonInfoTapped(_ sender: Any) {
		let url = URL(string: "https://arcgis.com/apps/opsdashboard/index.html#/85320e2ea5424dfaaa75ae62e5c06e61")!
		let safariController = SFSafariViewController(url: url)
		safariController.modalPresentationStyle = .pageSheet
		App.topViewController.present(safariController, animated: true)
	}
}
