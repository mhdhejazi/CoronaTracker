//
//  Statistic.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

public struct Statistic: Codable {
	public let confirmedCount: Int
	public let recoveredCount: Int
	public let deathCount: Int
	public var activeCount: Int { confirmedCount - recoveredCount - deathCount }

	public var recoveredPercent: Double { confirmedCount == 0 ? 0 : 100.0 * Double(recoveredCount) / Double(confirmedCount) }
	public var deathPercent: Double { confirmedCount == 0 ? 0 :  100.0 * Double(deathCount) / Double(confirmedCount) }
	public var activePercent: Double { confirmedCount == 0 ? 0 :  100.0 * Double(activeCount) / Double(confirmedCount) }

	public var confirmedCountString: String { confirmedCount.groupingFormatted }
	public var recoveredCountString: String { recoveredCount.groupingFormatted }
	public var deathCountString: String { deathCount.groupingFormatted }
	public var activeCountString: String { activeCount.groupingFormatted }
}

extension Statistic {
	public enum Kind {
		case confirmed, active, recovered, deaths
	}

	public func number(for kind: Kind) -> Int {
		switch kind {
		case .confirmed: return confirmedCount
		case .active: return activeCount
		case .recovered: return recoveredCount
		case .deaths: return deathCount
		}
	}
}

extension Statistic: CustomStringConvertible {
	public var description: String {
		"""
		Confirmed: \(confirmedCountString)
		Recovered: \(recoveredCountString) (\(recoveredPercent.percentFormatted))
		Deaths: \(deathCountString) (\(deathPercent.percentFormatted))
		"""
	}
}

extension Statistic {
	public static func sum(subData: [Statistic]) -> Statistic {
		Statistic(confirmedCount: subData.reduce(0) { $0 + $1.confirmedCount },
				  recoveredCount: subData.reduce(0) { $0 + $1.recoveredCount },
				  deathCount: subData.reduce(0) { $0 + $1.deathCount })
	}
}
