//
//  Coordinate.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/11/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

public struct Coordinate: Codable {
	static let zero = Coordinate(latitude: 0, longitude: 0)

	let latitude: Double
	let longitude: Double

	public var clLocation: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }

	func distance(from other: Coordinate) -> Double {
		hypot(latitude - other.latitude, longitude - other.longitude)
	}
}

extension Coordinate: Equatable {
	public static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
		Int(lhs.latitude * 1000) == Int(rhs.latitude * 1000) &&
			Int(lhs.longitude * 1000) == Int(rhs.longitude * 1000)
	}
}
