//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

public class Region: Codable {
	public let level: Level
	public let name: String
	public let parentName: String? /// Country name
	public let location: Coordinate

	public var report: Report?
	public var timeSeries: TimeSeries?
	public lazy var dailyChange: Change? = { generateDailyChange() }()

	public var subRegions: [Region] = [] {
		didSet {
			report = Report.join(subReports: subRegions.compactMap { $0.report })
			timeSeries = TimeSeries.join(subSerieses: subRegions.compactMap { $0.timeSeries })
		}
	}

	init(level: Level, name: String, parentName: String?, location: Coordinate) {
		self.level = level
		self.name = name
		self.parentName = parentName
		self.location = location
	}

	private func generateDailyChange() -> Change? {
		if !isCountry, !subRegions.isEmpty {
			return Change.sum(subChanges: subRegions.compactMap { $0.dailyChange })
		}

		guard let todayReport = report,
			let timeSeries = timeSeries else { return nil }

		var yesterdayStat: Statistic
		var dates = timeSeries.series.keys.sorted()
		guard let lastDate = dates.popLast(),
			lastDate.ageDays <= 3,
			let lastStat = timeSeries.series[lastDate] else { return nil }

		yesterdayStat = lastStat

		if todayReport.stat.confirmedCount == lastStat.confirmedCount {
			guard let nextToLastDate = dates.popLast(),
				let nextToLastStat = timeSeries.series[nextToLastDate] else { return nil }

			yesterdayStat = nextToLastStat
		}

		return Change(currentStat: todayReport.stat, lastStat: yesterdayStat)
	}

	public enum Level: Int, RawRepresentable, Codable {
		case world = 1
		case country = 2
		case province = 3 /// Could be a province, a state, or a city

		var parent: Level { Level(rawValue: max(1, rawValue - 1)) ?? self }
	}
}

extension Region {
	public var isWorld: Bool { level == .world }
	public var isCountry: Bool { level == .country }
	public var isProvince: Bool { level == .province }
	public var longName: String { isProvince ? "\(name), \(parentName ?? "-")" : name }

	public var localizedName: String {
		if name == Region.world.name {
			return L10n.Region.world
		}

		return Locale.translateCountryName(name) ?? name
	}
	public var localizedLongName: String {
		guard isProvince else { return localizedName }

		let localizedParentName = Locale.translateCountryName(parentName ?? "-") ?? "-"
		return "\(name), \(localizedParentName)"
	}

	public func find(region: Region) -> Region? {
		if region == self {
			return self
		}

		return subRegions.first { $0 == region }
	}
}

extension Region {
	public static var world: Region { Region(level: .world, name: "Worldwide", parentName: nil, location: .zero) }

	public static func join(subRegions: [Region]) -> Region? {
		guard let firstRegion = subRegions.first else { return nil }

		let region = Region(level: firstRegion.level.parent,
							name: firstRegion.parentName ?? "N/A",
							parentName: nil,
							location: (subRegions.max() ?? firstRegion).location)

		region.subRegions = subRegions
		return region
	}
}

extension Region: Equatable {
	public static func == (lhs: Region, rhs: Region) -> Bool {
		(lhs.level == rhs.level && lhs.parentName == rhs.parentName && lhs.name == rhs.name) ||
			(lhs.level == rhs.level && lhs.location == rhs.location && !lhs.location.isZero)
	}
}

extension Region: Comparable {
	public static func < (lhs: Region, rhs: Region) -> Bool {
		lhs.report?.stat.confirmedCount ?? 0 < rhs.report?.stat.confirmedCount ?? 0
	}
}

extension Region: CustomStringConvertible {
	public var description: String {
		"Region: \(name) @\(parentName ?? "-") #\(report?.description ?? "-") ##\(timeSeries?.description ?? "-")"
	}
}
