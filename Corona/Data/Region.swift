//
//  Region.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

class Region: Equatable {
	var countryName: String
	let provinceName: String
	let location: CLLocationCoordinate2D

	var isProvince: Bool { !provinceName.isEmpty }
	var name: String { isProvince ? "\(provinceName), \(countryName)" : countryName }

	init(country: String, province: String, location: CLLocationCoordinate2D) {
		self.countryName = country
		self.provinceName = province
		self.location = location
	}

	init(subRegions: [Region]) {
		assert(!subRegions.isEmpty)

		self.countryName = subRegions.first!.countryName
		self.provinceName = ""

		let coordinates = subRegions.map { $0.location }
		let totals = coordinates.reduce((latitude: 0.0, longitude: 0.0)) {
			($0.latitude + $1.latitude, $0.longitude + $1.longitude)
		}
		let location = CLLocationCoordinate2D(latitude: totals.latitude / Double(coordinates.count),
											  longitude: totals.longitude / Double(coordinates.count))

		self.location = subRegions.min {
			location.distance(from: $0.location) < location.distance(from: $1.location)
		}!.location
	}


	func equals(other: Region) -> Bool {
		self.countryName == other.countryName &&
		self.provinceName == other.provinceName
	}

	static func == (lhs: Region, rhs: Region) -> Bool {
		return lhs.equals(other: rhs)
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(countryName)
		hasher.combine(provinceName)
	}
}
