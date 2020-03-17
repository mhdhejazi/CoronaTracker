//
//  Change.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/16/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

public struct Change {
	public let newConfirmed: Int
	public let newRecovered: Int
	public let newDeaths: Int

	public let confirmedGrowthPercent: Double
	public let recoveredGrowthPercent: Double
	public let deathsGrowthPercent: Double
}

extension Change {
	public var newConfirmedString: String { "+\(newConfirmed.groupingFormatted)" }
	public var newRecoveredString: String { "+\(newRecovered.groupingFormatted)" }
	public var newDeathsString: String { "+\(newDeaths.groupingFormatted)" }

	public var confirmedGrowthString: String { "↑\(confirmedGrowthPercent.kmFormatted)%" }
	public var recoveredGrowthString: String { "↑\(recoveredGrowthPercent.kmFormatted)%" }
	public var deathsGrowthString: String { "↑\(deathsGrowthPercent.kmFormatted)%" }
}

extension Change {
	public static func sum(subChanges: [Change]) -> Change {
		Change(newConfirmed: subChanges.reduce(0) { $0 + $1.newConfirmed },
			   newRecovered: subChanges.reduce(0) { $0 + $1.newRecovered },
			   newDeaths: subChanges.reduce(0) { $0 + $1.newDeaths },
			   confirmedGrowthPercent: (subChanges.reduce(0) { $0 + $1.confirmedGrowthPercent }) / Double(subChanges.count),
			   recoveredGrowthPercent: (subChanges.reduce(0) { $0 + $1.recoveredGrowthPercent }) / Double(subChanges.count),
			   deathsGrowthPercent: (subChanges.reduce(0) { $0 + $1.deathsGrowthPercent }) / Double(subChanges.count))
	}
}
