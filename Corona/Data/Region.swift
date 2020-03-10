//
//  Region.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

struct Region: Equatable, Codable {
	var countryName: String
	let provinceName: String
	let location: Coordinate

	var isProvince: Bool { !provinceName.isEmpty }
	var name: String { isProvince ? "\(provinceName), \(countryName)" : countryName }

	static func join(subRegions: [Region]) -> Region {
		assert(!subRegions.isEmpty)

		let countryName = subRegions.first!.countryName
		let provinceName = ""

		let coordinates = subRegions.map { $0.location }
		let totals = coordinates.reduce((latitude: 0.0, longitude: 0.0)) {
			($0.latitude + $1.latitude, $0.longitude + $1.longitude)
		}
		var location = Coordinate(latitude: totals.latitude / Double(coordinates.count),
								  longitude: totals.longitude / Double(coordinates.count))

		location = subRegions.min {
			location.distance(from: $0.location) < location.distance(from: $1.location)
		}!.location

		return Region(countryName: countryName, provinceName: provinceName, location: location)
	}

	func equals(other: Region) -> Bool {
		(self.countryName == other.countryName && self.provinceName == other.provinceName) ||
		self.location == other.location
	}

	static func == (lhs: Region, rhs: Region) -> Bool {
		return lhs.equals(other: rhs)
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(countryName)
		hasher.combine(provinceName)
	}
}

struct Coordinate: Codable, Equatable {
	var latitude: Double
	var longitude: Double

	var clLocation: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }

	func distance(from other: Coordinate) -> Double {
		hypot(latitude - other.latitude, longitude - other.longitude)
	}

	func equals(other: Coordinate) -> Bool {
		Int(self.latitude * 1000) == Int(other.latitude * 1000) &&
		Int(self.longitude * 1000) == Int(other.longitude * 1000)
	}

	static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
		return lhs.equals(other: rhs)
	}

}
