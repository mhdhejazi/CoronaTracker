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
}
