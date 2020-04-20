//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/2/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	private var appMenu: AppMenu?

	var window: UIWindow?

	func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		App.upgrade()
		return true
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		if !DataManager.shared.world.subRegions.isEmpty {
			MapController.shared.downloadIfNeeded()
		}
	}

	// MARK: UISceneSession Lifecycle

	@available(iOS 13.0, *)
	func application(_ application: UIApplication,
					 configurationForConnecting connectingSceneSession: UISceneSession,
					 options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	@available(iOS 13.0, *)
	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
	}
}

// MARK: - Main Menu

#if targetEnvironment(macCatalyst)
extension AppDelegate {
	override func buildMenu(with builder: UIMenuBuilder) {
		appMenu = AppMenu(builder: builder)
	}

	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		if appMenu?.canPerformAction(action) == true {
			return true
		}

		return super.canPerformAction(action, withSender: sender)
	}

	override func forwardingTarget(for aSelector: Selector!) -> Any? {
		if appMenu?.canPerformAction(aSelector) == true {
			return appMenu
		}

		return super.forwardingTarget(for: aSelector)
	}
}
#endif
