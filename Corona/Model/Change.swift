//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/16/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

public struct Change {
	public let currentStat: Statistic
	public let lastStat: Statistic
}

extension Change {
	public var currentConfirmed: Int { currentStat.confirmedCount }
	public var currentRecovered: Int { currentStat.recoveredCount }
	public var currentDeaths: Int { currentStat.deathCount }

	public var lastConfirmed: Int { lastStat.confirmedCount }
	public var lastRecovered: Int { lastStat.recoveredCount }
	public var lastDeaths: Int { lastStat.deathCount }

	public var newConfirmed: Int { currentConfirmed - lastConfirmed }
	public var newRecovered: Int { currentRecovered - lastRecovered }
	public var newDeaths: Int { currentDeaths - lastDeaths }

	public var confirmedGrowthPercent: Double {
		lastConfirmed == 0 ? 0 :(Double(currentConfirmed) / Double(lastConfirmed) - 1) * 100
	}
	public var recoveredGrowthPercent: Double {
		lastRecovered == 0 ? 0 :(Double(currentRecovered) / Double(lastRecovered) - 1) * 100
	}
	public var deathsGrowthPercent: Double {
		lastDeaths == 0 ? 0 :(Double(currentDeaths) / Double(lastDeaths) - 1) * 100
	}

	public var newConfirmedString: String { newConfirmed > 0 ? "+\(newConfirmed.groupingFormatted)" : "-" }
	public var newRecoveredString: String { currentRecovered == 0 ? "-" : "+\(newRecovered.groupingFormatted)" }
	public var newDeathsString: String { newDeaths > 0 ? "+\(newDeaths.groupingFormatted)" : "-" }

	public var confirmedGrowthString: String { newConfirmed > 0 ? "↑\(confirmedGrowthPercent.kmFormatted)%" : "-" }
	public var recoveredGrowthString: String { currentRecovered == 0 ? "-" : "↑\(recoveredGrowthPercent.kmFormatted)%" }
	public var deathsGrowthString: String { newDeaths > 0 ? "↑\(deathsGrowthPercent.kmFormatted)%" : "-" }

	public var isZero: Bool { newConfirmed == 0 && newRecovered == 0 && newDeaths == 0 }
}

extension Change: CustomStringConvertible {
	public var description: String {
		"Change: \(newConfirmedString) | \(newRecoveredString) | \(newDeathsString)"
	}
}

extension Change {
	public static func sum(subChanges: [Change]) -> Change {
		Change(currentStat: Statistic.sum(subData: subChanges.map { $0.currentStat }),
			   lastStat: Statistic.sum(subData: subChanges.map { $0.lastStat }))
	}
}
