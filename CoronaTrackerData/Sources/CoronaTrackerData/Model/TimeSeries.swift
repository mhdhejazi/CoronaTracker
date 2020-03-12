//
//  TimeSeries.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

public struct TimeSeries: Codable {
	public var region: Region
	public let series: [Date : Statistic]

	static func join(subSerieses: [TimeSeries]) -> TimeSeries {
		assert(!subSerieses.isEmpty)

		let region = Region.join(subRegions: subSerieses.map { $0.region })

		var series: [Date : Statistic] = [:]
		let subSeries = subSerieses.first!
		subSeries.series.keys.forEach { key in
			let subData = subSerieses.compactMap { $0.series[key] }
			let superData = Statistic.join(subData: subData)
			series[key] = superData
		}

		return TimeSeries(region: region, series: series)
	}
}
