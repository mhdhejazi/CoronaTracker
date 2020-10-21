//
//  DeepLinkHandling.swift
//  Corona Tracker
//
//  Created by Andrei Ciobanu on 20/10/2020.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

private struct DeepLinkHandler {
	static func handleOpenUrl(_ url: URL) {
		if url.host == "ios_14_widget",
		   url.path == "/open",
		   let regionCode = url.queryParameters?["region"] {
			let worldRegion = DataManager.shared.world
			let selectedRegion = worldRegion.subRegions.first(where: { $0.isoCode == regionCode }) ?? worldRegion
			if selectedRegion.isCountry {
				MapController.shared.showRegionOnMap(region: selectedRegion)
			}
		}
	}
}

@available(iOS 13.0, *)
extension SceneDelegate {
	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		guard let deepLinkUrl = URLContexts.first?.url else { return }
		DeepLinkHandler.handleOpenUrl(deepLinkUrl)
	}
}
