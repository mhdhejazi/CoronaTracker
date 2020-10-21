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
		var topController: UIViewController = MapController.shared
		while let presentedController = topController.presentedViewController, !(presentedController is MenuController) {
			topController = presentedController
		}
		return topController
	}

	static let repoURL = URL(string: "https://github.com/mhdhejazi/CoronaTracker")!
	static let releaseNotesURL = URL(string: "https://github.com/mhdhejazi/CoronaTracker/releases")!
	static let newIssueURL = URL(string: "https://github.com/mhdhejazi/CoronaTracker/issues/new")!
	#if targetEnvironment(macCatalyst)
	static let updateURL = URL(string: "https://coronatracker.samabox.com/")!
	#else
	static let updateURL = repoURL
	#endif

	static let version = Bundle.main.version

	public static func checkForAppUpdate(completion: @escaping (_ updateAvailable: Bool) -> Void) {
		let checkForUpdateURL = URL(string: "https://api.github.com/repos/mhdhejazi/CoronaTracker/releases/latest")!
		URLSession.shared.dataTask(with: checkForUpdateURL) { data, response, _ in
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

	public static func openWebPage(url: URL, viewController: UIViewController) {
		let safariController = SFSafariViewController(url: url)
		safariController.modalPresentationStyle = .pageSheet
		viewController.present(safariController, animated: true)
	}

	public static func openUpdatePage(viewController: UIViewController) {
		openWebPage(url: updateURL, viewController: viewController)
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

	public static func openHelpPage() {
		openWebPage(url: repoURL, viewController: topViewController)
	}

	public static func openReleaseNotesPage() {
		openWebPage(url: releaseNotesURL, viewController: topViewController)
	}

	public static func openNewIssuePage() {
		openWebPage(url: newIssueURL, viewController: topViewController)
	}
}
