//
//  SceneDelegate.swift
//  Corona
//
//  Created by Mohammad on 3/2/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func sceneWillEnterForeground(_ scene: UIScene) {
		if !DataManager.instance.world.subRegions.isEmpty {
			MapController.instance.downloadIfNeeded()
		}
	}

}
