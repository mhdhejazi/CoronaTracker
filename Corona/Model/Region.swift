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
	public let isoCode: String?

	public var order: Int = Int.max
	public var report: Report?
	public var timeSeries: TimeSeries?
	public lazy var dailyChange: Change? = { generateDailyChange() }()

	public var subRegions: [Region] = []

	init(level: Level, name: String, parentName: String?, location: Coordinate, isoCode: String? = nil) {
		self.level = level
		self.name = name
		self.parentName = parentName
		self.location = location

		if let isoCode = isoCode {
			self.isoCode = isoCode
		} else {
			if level == .country {
				self.isoCode = Locale.isoCode(for: name)
			} else {
				self.isoCode = nil
			}
		}
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

		let nextToLastDate = dates.popLast()
		var nextToLastStat: Statistic?
		if let date = nextToLastDate {
			nextToLastStat = timeSeries.series[date]
		}

		let confirmedDeltaToday = todayReport.stat.confirmedCount - lastStat.confirmedCount
		let confirmedDeltaYesterday = lastStat.confirmedCount - (nextToLastStat?.confirmedCount ?? lastStat.confirmedCount)

		yesterdayStat = lastStat

		/// If the delta today is less than 5% of yesterday's, then today's data is most likely incomplete
		if Double(confirmedDeltaToday) < Double(confirmedDeltaYesterday) * 0.05 {
			guard let nextToLastStat = nextToLastStat else { return nil }

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

	public func updateFromSubRegions() {
		report = Report.join(subReports: subRegions.compactMap { $0.report })
		timeSeries = TimeSeries.join(subSerieses: subRegions.compactMap { $0.timeSeries })
	}

	public func find(subRegion: Region) -> Region? {
		if subRegion == self {
			return self
		}

		return subRegions.first { $0 == subRegion }
	}

	public func find(subRegionCode: String) -> Region? {
		if subRegionCode == self.isoCode {
			return self
		}

		return subRegions.first { $0.isoCode == subRegionCode }
	}

	public func find(subRegionName: String) -> Region? {
		subRegions.first { $0.name == subRegionName }
	}

	public func add(subRegions: [Region], addSubData: Bool) {
		let newSubRegions = subRegions.filter { self.find(subRegionName: $0.name) == nil }
		self.subRegions.append(contentsOf: newSubRegions)

		guard addSubData else { return }

		if let currentReport = report {
			self.report = Report.join(
				subReports: [currentReport] + subRegions.compactMap { $0.report })
		}
		if let currentTimeSeries = timeSeries {
			self.timeSeries = TimeSeries.join(
				subSerieses: [currentTimeSeries] + subRegions.compactMap { $0.timeSeries })
		}
	}
}

extension Region {
	public static var world: Region { Region(level: .world, name: "Worldwide", parentName: nil, location: .zero) }

	public static func join(subRegions: [Region]) -> Region? {
		guard let firstRegion = subRegions.first else { return nil }

		/// Set the location to the center point between the two most affected sub regions
		let location = Coordinate.center(of: subRegions.filter { !$0.location.isZero }
			.sorted()
			.suffix(2)
			.map { $0.location })

		let region = Region(level: firstRegion.level.parent,
							name: firstRegion.parentName ?? "N/A",
							parentName: nil,
							location: location)

		region.subRegions = subRegions
		region.updateFromSubRegions()
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
