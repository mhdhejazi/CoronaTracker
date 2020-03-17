//
//  TimeSeries.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

public struct TimeSeries: Codable {
	public let series: [Date : Statistic]
}

extension TimeSeries {
	static func join(subSerieses: [TimeSeries]) -> TimeSeries? {
		guard let firstSubSeries = subSerieses.first else { return nil }

		var series: [Date : Statistic] = [:]
		firstSubSeries.series.keys.forEach { key in
			let subData = subSerieses.compactMap { $0.series[key] }
			let superData = Statistic.sum(subData: subData)
			series[key] = superData
		}

		return TimeSeries(series: series)
	}
}
