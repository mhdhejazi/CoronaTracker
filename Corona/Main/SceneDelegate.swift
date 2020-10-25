//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/2/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	private var toolbar: AppToolbar?

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
			   options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }

		toolbar = AppToolbar(windowScene: windowScene)

		if let urlContext = connectionOptions.urlContexts.first {
			handleOpenUrl(urlContext.url)
		}
	}

	func sceneDidDisconnect(_ scene: UIScene) {
	}

	func sceneDidBecomeActive(_ scene: UIScene) {
	}

	func sceneWillResignActive(_ scene: UIScene) {
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		if !DataManager.shared.world.subRegions.isEmpty {
			MapController.shared.downloadIfNeeded()
		}
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
	}

	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		guard let deepLinkUrl = URLContexts.first?.url else { return }

		handleOpenUrl(deepLinkUrl)
	}

	@discardableResult
	private func handleOpenUrl(_ url: URL) -> Bool {
		guard url.host == "ios_14_widget",
			  url.path == "/open",
			  let regionCode = url.queryParameters?["region"] else { return false }

		/// If it's a cold run we just store the target region in MapController
		if MapController.shared == nil {
			MapController.initialRegionCode = regionCode
			return true
		}

		let worldRegion = DataManager.shared.world
		let selectedRegion = worldRegion.subRegions.first(where: { $0.isoCode == regionCode }) ?? worldRegion
		if selectedRegion.isCountry {
			MapController.shared.showRegionOnMap(region: selectedRegion)
		}

		return true
	}
}
