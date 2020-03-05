//
//  PlaceData.swift
//  Corona
//
//  Created by Mohammad on 3/3/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

class VirusReport: Decodable {
	enum CodingKeys: String, CodingKey {
		case province = "Province/State"
		case country = "Country/Region"
		case lastUpdate = "Last Update"
		case confirmed = "Confirmed"
		case deaths = "Deaths"
		case recovered = "Recovered"
		case latitude = "Latitude"
		case longitude = "Longitude"
	}

	let region: Region
	let lastUpdate: Date
	let data: VirusData

	var hourAge: Int {
		Calendar.current.dateComponents([.hour], from: self.lastUpdate, to: Date()).hour!
	}

	required init(from decoder: Decoder) throws {
		let row = try decoder.container(keyedBy: CodingKeys.self)
		let province = try row.decode(String.self, forKey: .province)
		let country = try row.decode(String.self, forKey: .country)
		let latitude = try row.decode(Double.self, forKey: .latitude)
		let longitude = Double(try row.decode(String.self, forKey: .longitude).trimmingCharacters(in: .newlines)) ?? 0
		let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		self.region = Region(country: country, province: province, location: location)

		let timeString = try row.decode(String.self, forKey: .lastUpdate)
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
		self.lastUpdate = formatter.date(from: timeString) ?? Date()

		let confirmed = try row.decode(Int.self, forKey: .confirmed)
		let deaths = try row.decode(Int.self, forKey: .deaths)
		let recovered = try row.decode(Int.self, forKey: .recovered)
		self.data = VirusData(confirmedCount: confirmed, recoveredCount: recovered, deathCount: deaths)
    }

	init(provinceReports: [VirusReport]) {
		assert(!provinceReports.isEmpty)

		self.region = Region(provinceRegions: provinceReports.map { $0.region })
		self.lastUpdate = provinceReports.max { $0.lastUpdate < $1.lastUpdate }!.lastUpdate
		self.data = VirusData(subData: provinceReports.map { $0.data })
	}
}
