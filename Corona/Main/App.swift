//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/13/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import SafariServices

import Disk

class App {
	static var topViewController: UIViewController {
		MapController.instance.presentedViewController ?? MapController.instance
	}

	#if targetEnvironment(macCatalyst)
	static let updateURL = URL(string: "https://coronatracker.samabox.com/")!
	#else
	static let updateURL = URL(string: "https://github.com/mhdhejazi/CoronaTracker")!
	#endif

	static let version = Bundle.main.version

	public static func checkForAppUpdate(completion: @escaping (_ updateAvailable: Bool) -> Void) {
		let checkForUpdateURL = URL(string: "https://api.github.com/repos/mhdhejazi/CoronaTracker/releases/latest")!
		_ = URLSession.shared.dataTask(with: checkForUpdateURL) { data, response, _ in
			guard let response = response as? HTTPURLResponse,
				response.statusCode == 200,
				let data = data,
				let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
				let tagName = result["tag_name"] as? String else {
					print("Failed update call")
					completion(false)
					return
			}

			guard let currentVersion = Self.version, tagName != "v\(currentVersion)" else {
				completion(false)
				return
			}

			completion(true)
		}.resume()
	}

	public static func openUpdatePage(viewController: UIViewController) {
		let safariController = SFSafariViewController(url: updateURL)
		safariController.modalPresentationStyle = .pageSheet
		viewController.present(safariController, animated: true)
	}

	public static func upgrade() {
		let appVersionKey = "appVersion"
		let oldAppVersion = UserDefaults.standard.string(forKey: appVersionKey)
		let newAppVersion = Self.version
		guard oldAppVersion != newAppVersion else { return }

		/// Clear cache on app update
		try? Disk.clear(.caches)

		UserDefaults.standard.set(newAppVersion, forKey: appVersionKey)
	}
}
