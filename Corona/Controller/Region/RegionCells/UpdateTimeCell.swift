//
//  Corona Tracker
//  Created by Mhd Hejazi on 4/8/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class UpdateTimeCell: RegionDataCell {
	@IBOutlet private var labelUpdated: UILabel!

	override func update(animated: Bool) {
		self.labelUpdated.text = "\(L10n.Data.updateDate) \(self.region?.report?.lastUpdate.relativeDateString ?? "-")"
	}
}
