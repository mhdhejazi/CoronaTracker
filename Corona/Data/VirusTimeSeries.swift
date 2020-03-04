//
//  VirusTimeSeries.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

class VirusTimeSeries {
	let region: Region
	let series: [Date : VirusData]

	init(region: Region, series: [Date : VirusData]) {
		self.region = region
		self.series = series
    }

	init(provinceSerieses: [VirusTimeSeries]) {
		assert(!provinceSerieses.isEmpty)

		self.region = Region(provinceRegions: provinceSerieses.map { $0.region })

		var series: [Date : VirusData] = [:]
		let provinceSeries = provinceSerieses.first!
		provinceSeries.series.keys.forEach { key in
			let subData = provinceSerieses.compactMap { $0.series[key] }
			let superData = VirusData(subData: subData)
			series[key] = superData
		}
		self.series = series
	}
}

class CounterTimeSeries: Decodable {
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
}
