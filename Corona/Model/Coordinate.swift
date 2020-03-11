//
//  Coordinate.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/11/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

struct Coordinate: Codable, Equatable {
	static let zero = Coordinate(latitude: 0, longitude: 0)

	let latitude: Double
	let longitude: Double

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
