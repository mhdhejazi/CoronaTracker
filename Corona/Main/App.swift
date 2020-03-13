//
//  App.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/13/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import SafariServices

class App {
	static func checkForAppUpdate(viewController: UIViewController) {
		let checkForUpdateURL = URL(string: "https://api.github.com/repos/MhdHejazi/CoronaTracker/releases/latest")!
		_ = URLSession.shared.dataTask(with: checkForUpdateURL) { (data, response, error) in
			guard let response = response as? HTTPURLResponse,
				response.statusCode == 200,
				let data = data,
				let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
				let tagName = result["tag_name"] as? String else {
					print("Failed update call")
					return
			}

			guard let currentVersion = Bundle.main.infoDictionary?["CFBundleVersion"], tagName != "v\(currentVersion)" else {
				return
			}

			DispatchQueue.main.async {
				let alertController = UIAlertController.init(title: "New Version Available",
															 message: "Please update from https://github.com/MhdHejazi/CoronaTracker",
															 preferredStyle: .alert)

				#if targetEnvironment(macCatalyst)
				alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
				alertController.addAction(UIAlertAction(title: "Open", style: .default, handler: { _ in
					self.openUpdatePage(viewController: viewController)
				}))
				#else
				alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
				#endif

				viewController.present(alertController, animated: true)
			}
		}.resume()
	}

	private static func openUpdatePage(viewController: UIViewController) {
		let url = URL(string: "https://github.com/MhdHejazi/CoronaTracker/releases/latest")!
		let safariController = SFSafariViewController(url: url)
		safariController.modalPresentationStyle = .pageSheet
		viewController.present(safariController, animated: true)
	}
}
