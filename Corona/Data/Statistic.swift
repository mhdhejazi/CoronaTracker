//
//  Statistic.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

struct Statistic: CustomStringConvertible, Codable {
	let confirmedCount: Int
	let recoveredCount: Int
	let deathCount: Int
	var existingCount: Int { confirmedCount - recoveredCount - deathCount }

	var recoveredPercent: Double { 100.0 * Double(recoveredCount) / Double(confirmedCount) }
	var deathPercent: Double { 100.0 * Double(deathCount) / Double(confirmedCount) }
	var existingPercent: Double { 100.0 * Double(existingCount) / Double(confirmedCount) }

	var confirmedCountString: String { NumberFormatter.groupingFormatter.string(from: NSNumber(value: confirmedCount))! }
	var recoveredCountString: String { NumberFormatter.groupingFormatter.string(from: NSNumber(value: recoveredCount))! }
	var deathCountString: String { NumberFormatter.groupingFormatter.string(from: NSNumber(value: deathCount))! }

	var description: String {
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
