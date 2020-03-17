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
