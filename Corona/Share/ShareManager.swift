//
//  Corona Tracker
//  Created by Mhd Hejazi on 4/6/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class ShareManager {
	static let instance = ShareManager()

	func share(image: UIImage? = nil, text: String? = nil, sourceView: UIView? = nil) {
		guard image != nil || text != nil else { return }

		var items: [Any] = []
		if let image = image {
			let imageName = Bundle.main.name ?? "Image"
			items.append(ImageItemSource(image: image, imageName: imageName))
		}

		if let text = text {
			items.append(TextItemSource(text: text))
		}

		let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)

		if UIDevice.current.userInterfaceIdiom == .pad {
			activityController.modalPresentationStyle = .popover
			activityController.popoverPresentationController?.sourceView = sourceView
			activityController.popoverPresentationController?.sourceRect = sourceView?.bounds ?? .zero
		}

		App.topViewController.present(activityController, animated: true, completion: nil)
	}
}
