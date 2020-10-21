//
//  LocalStatsWidgetData.swift
//  Corona Tracker
//
//  Created by Andrei Ciobanu on 18/10/2020.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

struct LocalStatsWidgetData {
	// MARK: - Instance Properties -

	let region: Region
	let lastUpdate: String

	// MARK: - Initializer(s) -

	init(region: Region) {
		self.region = region
		self.lastUpdate = region.report?.lastUpdate.relativeDateString ?? "-"
	}
}
