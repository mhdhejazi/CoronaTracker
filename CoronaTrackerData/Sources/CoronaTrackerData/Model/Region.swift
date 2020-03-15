//
//  Region.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

public struct Region: Equatable, Codable {
	public static let worldWide = Region(countryName: "Worldwide", provinceName: "", location: .zero)

	public let countryName: String
	public let provinceName: String
	public let location: Coordinate

	public var isProvince: Bool { !provinceName.isEmpty }
	public var name: String { isProvince ? "\(provinceName), \(countryName)" : countryName }

	public static func join(subRegions: [Region]) -> Region {
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

	public func equals(other: Region) -> Bool {
		(self.countryName == other.countryName && self.provinceName == other.provinceName) ||
		self.location == other.location
	}

    public static func == (lhs: Region, rhs: Region) -> Bool {
		return lhs.equals(other: rhs)
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(countryName)
		hasher.combine(provinceName)
	}
}
