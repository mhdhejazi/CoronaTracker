//
//  Statistic.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

public struct Statistic: CustomStringConvertible, Codable {
	public let confirmedCount: Int
	public let recoveredCount: Int
	public let deathCount: Int
	public var existingCount: Int { confirmedCount - recoveredCount - deathCount }

	public var recoveredPercent: Double { confirmedCount == 0 ? 0 : 100.0 * Double(recoveredCount) / Double(confirmedCount) }
	public var deathPercent: Double { confirmedCount == 0 ? 0 :  100.0 * Double(deathCount) / Double(confirmedCount) }
	public var existingPercent: Double { confirmedCount == 0 ? 0 :  100.0 * Double(existingCount) / Double(confirmedCount) }

	public var confirmedCountString: String { NumberFormatter.groupingFormatter.string(from: NSNumber(value: confirmedCount))! }
	public var recoveredCountString: String { NumberFormatter.groupingFormatter.string(from: NSNumber(value: recoveredCount))! }
	public var deathCountString: String { NumberFormatter.groupingFormatter.string(from: NSNumber(value: deathCount))! }

	public var description: String {
		"""
		Confirmed: \(confirmedCountString)
		Recovered: \(recoveredCountString) (\(recoveredPercent.percentFormatted))
		Deaths: \(deathCountString) (\(deathPercent.percentFormatted))
		"""
	}

	static func join(subData: [Statistic]) -> Statistic {
		Statistic(confirmedCount: subData.reduce(0) { $0 + $1.confirmedCount },
				  recoveredCount: subData.reduce(0) { $0 + $1.recoveredCount },
				  deathCount: subData.reduce(0) { $0 + $1.deathCount })
	}
}
