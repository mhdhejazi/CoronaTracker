//
//  Extensions.swift
//  Corona Tracker
//
//  Created by Andrei Ciobanu on 19/10/2020.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

extension Region {
	static var mockRegion: Region {
		let region = Region(level: .country, name: "Romania", parentName: nil, location: .zero)
		let currentStat = Statistic(confirmedCount: 180_388, recoveredCount: 130_894, deathCount: 5_872)
		let lastStat = Statistic(confirmedCount: 176_468, recoveredCount: 129_556, deathCount: 5_812)
		region.report = Report(lastUpdate: Date(), stat: currentStat)
		region.timeSeries = TimeSeries(series: [
			Date().addingTimeInterval(-60 * 60 * 24): lastStat,
			Date(): currentStat
		])
		return region
	}
}
