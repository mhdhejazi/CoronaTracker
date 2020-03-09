//
//  TimeSeries.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

class TimeSeries {
	let region: Region
	let series: [Date : Statistic]

	init(region: Region, series: [Date : Statistic]) {
		self.region = region
		self.series = series
    }

	init(subSerieses: [TimeSeries]) {
		assert(!subSerieses.isEmpty)

		self.region = Region(subRegions: subSerieses.map { $0.region })

		var series: [Date : Statistic] = [:]
		let subSeries = subSerieses.first!
		subSeries.series.keys.forEach { key in
			let subData = subSerieses.compactMap { $0.series[key] }
			let superData = Statistic(subData: subData)
			series[key] = superData
		}
		self.series = series
	}
}

class CounterTimeSeries: Decodable {
	enum CodingKeys: Int, CodingKey {
		case province = 0
		case country
		case latitude
		case longitude
	}

	let region: Region
	let values: [Int]

	required init(from decoder: Decoder) throws {
        var row = try decoder.unkeyedContainer()
        let province = try row.decode(String.self)
		let country = try row.decode(String.self)
		let latitude = try row.decode(Double.self)
		let longitude = try row.decode(Double.self)
		let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		self.region = Region(country: country, province: province, location: location)

		var values = [Int]()
		while !row.isAtEnd {
			let numberString = try row.decode(String.self).trimmingCharacters(in: .newlines)
			values.append(Int(numberString) ?? 0)
		}
		self.values = values
    }

	init(dataRow: [String]) {
		let province = dataRow[CodingKeys.province.rawValue]
		let country = dataRow[CodingKeys.country.rawValue]
		let latitude = Double(dataRow[CodingKeys.latitude.rawValue]) ?? 0
		let longitude = Double(dataRow[CodingKeys.longitude.rawValue]) ?? 0
		let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		self.region = Region(country: country, province: province, location: location)

		self.values = dataRow.dropFirst(CodingKeys.longitude.rawValue + 1).map { Int($0) ?? 0 }
	}
}
