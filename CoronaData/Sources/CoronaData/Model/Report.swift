//
//  Report.swift
//  Corona
//
//  Created by Mohammad on 3/3/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

public struct Report: Codable {
	public var region: Region
	public let lastUpdate: Date
	public let stat: Statistic
}

extension Report {
	static func join(subReports: [Report]) -> Report {
		Report(region: Region.join(subRegions: subReports.map { $0.region }),
			   lastUpdate: subReports.max { $0.lastUpdate < $1.lastUpdate }!.lastUpdate,
			   stat: Statistic.join(subData: subReports.map { $0.stat }))
	}
}
