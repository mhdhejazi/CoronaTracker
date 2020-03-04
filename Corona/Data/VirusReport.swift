//
//  PlaceData.swift
//  Corona
//
//  Created by Mohammad on 3/3/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

class VirusReport: Decodable {
	let region: Region
	let lastUpdate: Date
	let data: VirusData

	required init(from decoder: Decoder) throws {
        var row = try decoder.unkeyedContainer()
        let province = try row.decode(String.self)
		let country = try row.decode(String.self)

		let timeString = try row.decode(String.self)
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
		self.lastUpdate = formatter.date(from: timeString) ?? Date()

		let confirmed = try row.decode(Int.self)
		let deaths = try row.decode(Int.self)
		let recovered = try row.decode(Int.self)
		self.data = VirusData(confirmedCount: confirmed, recoveredCount: recovered, deathCount: deaths)

		let latitude = try row.decode(Double.self)
		let longitude = Double(try row.decode(String.self).trimmingCharacters(in: .newlines)) ?? 0
		let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		self.region = Region(country: country, province: province, location: location)
    }

	init(provinceReports: [VirusReport]) {
		assert(!provinceReports.isEmpty)

		self.region = Region(provinceRegions: provinceReports.map { $0.region })

		self.lastUpdate = provinceReports.min { $0.lastUpdate < $1.lastUpdate }!.lastUpdate

		self.data = VirusData(subData: provinceReports.map { $0.data })
	}
}
