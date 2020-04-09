//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

public struct Statistic: Codable {
	public let confirmedCount: Int
	public let recoveredCount: Int
	public let deathCount: Int
}

extension Statistic {
	public var activeCount: Int { confirmedCount - recoveredCount - deathCount }

	public var recoveredPercent: Double {
		confirmedCount == 0
			? 0
			: 100.0 * Double(recoveredCount) / Double(confirmedCount)
	}
	public var deathPercent: Double {
		confirmedCount == 0
			? 0
			: 100.0 * Double(deathCount) / Double(confirmedCount)
	}
	public var activePercent: Double {
		confirmedCount == 0
			? 0
			: 100.0 * Double(activeCount) / Double(confirmedCount)
	}

	public var confirmedCountString: String { confirmedCount.groupingFormatted }
	public var recoveredCountString: String { recoveredCount == 0 ? "-" : recoveredCount.groupingFormatted }
	public var deathCountString: String { deathCount.groupingFormatted }
	public var activeCountString: String { activeCount.groupingFormatted }

	public var recoveredPercentString: String { recoveredCount == 0 ? "-" : recoveredPercent.percentFormatted }
	public var deathPercentString: String { deathPercent.percentFormatted }
	public var activePercentString: String { activePercent.percentFormatted }

	public var isZero: Bool { confirmedCount == 0 && recoveredCount == 0 && deathCount == 0 }
}

extension Statistic {
	public enum Kind: Int, RawRepresentable, CustomStringConvertible {
		case confirmed, active, recovered, deaths

		public static let all: [Kind] = [.confirmed, .active, .recovered, .deaths]

		public var description: String {
			switch self {
			case .confirmed: return L10n.Case.confirmed
			case .active: return L10n.Case.active
			case .recovered: return L10n.Case.recovered
			case .deaths: return L10n.Case.deaths
			}
		}
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
		"Statistic: \(confirmedCountString) | \(recoveredCountString) | \(deathCountString)"
	}
}

extension Statistic {
	public static let zero = Statistic(confirmedCount: 0, recoveredCount: 0, deathCount: 0)

	public static func sum(subData: [Statistic]) -> Statistic {
		Statistic(confirmedCount: subData.reduce(0) { $0 + $1.confirmedCount },
				  recoveredCount: subData.reduce(0) { $0 + $1.recoveredCount },
				  deathCount: subData.reduce(0) { $0 + $1.deathCount })
	}
}
