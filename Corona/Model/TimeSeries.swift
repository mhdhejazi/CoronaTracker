//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

public struct TimeSeries: Codable {
	public let series: [Date: Statistic]
}

extension TimeSeries {
	public var lastUpdate: Date? { series.keys.max() }
	public var lastStatistic: Statistic? {
		guard let lastUpdate = lastUpdate else { return nil }
		return series[lastUpdate]
	}

	static func join(subSerieses: [TimeSeries]) -> TimeSeries? {
		guard let firstSubSeries = subSerieses.first else { return nil }

		var series: [Date: Statistic] = [:]
		firstSubSeries.series.keys.forEach { key in
			let subData = subSerieses.compactMap { $0.series[key] }
			let superData = Statistic.sum(subData: subData)
			series[key] = superData
		}

		return TimeSeries(series: series)
	}

	public func changes() -> [Date: Change] {
		var result = [Date: Change]()
		let dates = series.keys.sorted()
		for index in dates.indices {
			let date = dates[index]
			if index == 0 {
				result[date] = Change(currentStat: series[date]!, lastStat: .zero)
				continue
			}
			let previousDate = dates[index - 1]
			result[date] = Change(currentStat: series[date]!, lastStat: series[previousDate]!)
		}

		return result
	}
}

extension TimeSeries: CustomStringConvertible {
	public var description: String {
		"TimeSeries: \(lastUpdate?.description ?? "-"): \(lastStatistic?.description ?? "-")"
	}
}
