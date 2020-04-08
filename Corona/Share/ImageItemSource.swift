//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/19/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import MobileCoreServices

class ImageItemSource: NSObject, UIActivityItemSource {
	private let image: UIImage
	private let imageName: String
	private var imageURL: URL?

	init(image: UIImage, imageName: String) {
		self.image = image
		self.imageName = imageName

		super.init()

		imageURL = image.saveToFile(fileName: imageName, imageType: .png)
	}

	func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
		if let imageURL = imageURL {
			return imageURL
		}

		return image
	}

	func activityViewController (_ activityViewController: UIActivityViewController,
								 itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
		if activityType == .message ||
			activityType?.rawValue.starts(with: "com.skype.skype.") == true {
			return image.pngData()
		}

		if let imageURL = imageURL {
			return imageURL
		}

		return image
	}

	func activityViewController(_ activityViewController: UIActivityViewController,
								subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
		imageName
	}

	func activityViewController(_ activityViewController: UIActivityViewController,
								thumbnailImageForActivityType activityType: UIActivity.ActivityType?,
								suggestedSize size: CGSize) -> UIImage? {
		image.scaledToAspectFit(size: size)
	}

	func activityViewController(_ activityViewController: UIActivityViewController,
								dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
		String(kUTTypePNG)
	}
}
