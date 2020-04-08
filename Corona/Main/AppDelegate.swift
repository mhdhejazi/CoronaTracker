//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/2/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		App.upgrade()
		return true
	}

	// MARK: UISceneSession Lifecycle

	@available(iOS 13.0, *)
	func application(_ application: UIApplication,
					 configurationForConnecting connectingSceneSession: UISceneSession,
					 options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	@available(iOS 13.0, *)
	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		if !DataManager.instance.world.subRegions.isEmpty {
			MapController.instance.downloadIfNeeded()
		}
	}
}
