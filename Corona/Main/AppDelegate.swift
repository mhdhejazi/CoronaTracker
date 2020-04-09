//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/2/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	private var mainMenu: MainMenu?

	var window: UIWindow?

	func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		App.upgrade()
		return true
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		if !DataManager.instance.world.subRegions.isEmpty {
			MapController.instance.downloadIfNeeded()
		}
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
}

// MARK: - Main Menu

#if targetEnvironment(macCatalyst)
extension AppDelegate {
	override func buildMenu(with builder: UIMenuBuilder) {
		mainMenu = MainMenu(builder: builder)
	}

	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		if mainMenu?.canPerformAction(action) == true {
			return true
		}

		return super.canPerformAction(action, withSender: sender)
	}

	override func forwardingTarget(for aSelector: Selector!) -> Any? {
		if mainMenu?.canPerformAction(aSelector) == true {
			return mainMenu
		}

		return super.forwardingTarget(for: aSelector)
	}
}
#endif
