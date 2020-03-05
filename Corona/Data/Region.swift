//
//  Region.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

class Region: Equatable {
	var country: String
	let province: String
	let location: CLLocationCoordinate2D

	var name: String { province.isEmpty ? country : "\(province), \(country)" }

	init(country: String, province: String, location: CLLocationCoordinate2D) {
		self.country = country
		self.province = province
		self.location = location
	}

	init(provinceRegions: [Region]) {
		assert(!provinceRegions.isEmpty)

		self.country = provinceRegions.first!.country
		self.province = ""

//		self.location = provincePlaces.filter({
//			!$0.province.starts(with: "Unassigned Location")
//		}).max { $0.confirmedCount < $1.confirmedCount }!.location

		let coordinates = provinceRegions.map { $0.location }
		let totals = coordinates.reduce((latitude: 0.0, longitude: 0.0)) {
			($0.latitude + $1.latitude, $0.longitude + $1.longitude)
		}
		let location = CLLocationCoordinate2D(latitude: totals.latitude / Double(coordinates.count),
											  longitude: totals.longitude / Double(coordinates.count))

		self.location = provinceRegions.min {
			location.distance(from: $0.location) < location.distance(from: $1.location)
		}!.location
	}


	func equals(other: Region) -> Bool {
		self.country == other.country &&
		self.province == other.province
	}

	static func == (lhs: Region, rhs: Region) -> Bool {
		return lhs.equals(other: rhs)
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(country)
		hasher.combine(province)
	}
}
