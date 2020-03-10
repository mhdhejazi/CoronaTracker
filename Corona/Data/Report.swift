//
//  Report.swift
//  Corona
//
//  Created by Mohammad on 3/3/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

struct Report: Codable {
	private enum DataFieldOrder: Int {
		case province = 0
		case country
		case lastUpdate
		case confirmed
		case deaths
		case recovered
		case latitude
		case longitude
	}

	var region: Region
	let lastUpdate: Date
	let stat: Statistic

	var hourAge: Int {
		Calendar.current.dateComponents([.hour], from: self.lastUpdate, to: Date()).hour!
	}

	static func create(dataRow: [String]) -> Report {
		let province = dataRow[DataFieldOrder.province.rawValue]
		let country = dataRow[DataFieldOrder.country.rawValue]
		let latitude = Double(dataRow[DataFieldOrder.latitude.rawValue]) ?? 0
		let longitude = Double(dataRow[DataFieldOrder.longitude.rawValue]) ?? 0
		let location = Coordinate(latitude: latitude, longitude: longitude)
		let region = Region(countryName: country, provinceName: province, location: location)

		let timeString = dataRow[DataFieldOrder.lastUpdate.rawValue]
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
		let lastUpdate = formatter.date(from: timeString) ?? Date()

		let confirmed = Int(dataRow[DataFieldOrder.confirmed.rawValue]) ?? 0
		let deaths = Int(dataRow[DataFieldOrder.deaths.rawValue]) ?? 0
		let recovered = Int(dataRow[DataFieldOrder.recovered.rawValue]) ?? 0
		let stat = Statistic(confirmedCount: confirmed, recoveredCount: recovered, deathCount: deaths)

		return Report(region: region, lastUpdate: lastUpdate, stat: stat)
	}

	static func join(subReports: [Report]) -> Report {
		Report(region: Region.join(subRegions: subReports.map { $0.region }),
			   lastUpdate: subReports.max { $0.lastUpdate < $1.lastUpdate }!.lastUpdate,
			   stat: Statistic.join(subData: subReports.map { $0.stat }))
	}
}
