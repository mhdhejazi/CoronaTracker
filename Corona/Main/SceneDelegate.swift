//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/2/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
			   options connectionOptions: UIScene.ConnectionOptions) {

	}

	func sceneDidDisconnect(_ scene: UIScene) {

	}

	func sceneDidBecomeActive(_ scene: UIScene) {

	}

	func sceneWillResignActive(_ scene: UIScene) {

	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		if !DataManager.instance.world.subRegions.isEmpty {
			MapController.instance.downloadIfNeeded()
		}
	}

	func sceneDidEnterBackground(_ scene: UIScene) {

	}
}
