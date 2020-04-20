//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

import Disk

public class DataManager {
	private static let dataFileName = "data.json"

	public static let shared = DataManager()

	public var world: Region = .world

	public var topCountries: [Region] {
		[Region](regions(of: .country).lazy.sorted().reversed().prefix(6))
	}

	public func regions(of level: Region.Level) -> [Region] {
		switch level {
		case .world: return [world]
		case .country: return world.subRegions
		case .province:
			var regions = [Region]()
			for country in world.subRegions {
				if country.subRegions.isEmpty {
					regions.append(country)
				} else {
					regions.append(contentsOf: country.subRegions)
				}
			}
			return regions
		}
	}

	public func allRegions() -> [Region] {
		var result = regions(of: .country)
		result.append(contentsOf: regions(of: .province).filter { !result.contains($0) })
		return result
	}

	public func load(completion: @escaping (Bool) -> Void) {
		DispatchQueue.global().async {

			var result: Bool
			do {
				self.world = try Disk.retrieve(Self.dataFileName, from: .caches, as: Region.self)
				result = true
			} catch {
				debugPrint("Unexpected error:", error)
				try? Disk.clear(.caches)
				result = false
			}

			DispatchQueue.main.async {
				completion(result)
			}
		}
	}
}

extension DataManager {
	public func download(completion: @escaping (Bool) -> Void) {
		JHUWebDataService.shared.fetchReports { regions, _ in
			guard var regions = regions else {
				completion(false)
				return
			}

			/// Add Germany data
			RKIDataService.shared.fetchReports { bundeslaender, _ in
				if let bundeslaender = bundeslaender {
					regions += bundeslaender
				}

				JHURepoDataService.shared.fetchTimeSerieses { timeSeriesRegions, _ in
					self.update(regions: regions, timeSeriesRegions: timeSeriesRegions, completion: completion)
				}
			}
		}
	}

	private func update(regions: [Region], timeSeriesRegions: [Region]?, completion: @escaping (Bool) -> Void) {
		timeSeriesRegions?.forEach { timeSeriesRegion in
			regions.first { $0 == timeSeriesRegion }?.timeSeries = timeSeriesRegion.timeSeries
		}

		/// Countries
		var countries = [Region]()
		countries.append(contentsOf: regions.filter({ !$0.isProvince }))
		let provinceRegions = regions.filter({ $0.isProvince })
		Dictionary(grouping: provinceRegions, by: { $0.parentName }).values.forEach { subRegions in
			/// If there is already a region for this country, just add the sub regions
			if let existingCountry = countries.first(where: { $0.name == subRegions.first?.parentName }) {
				/// Data for Germany comes from a different source, so don't accumulate data
				let addSubData = (existingCountry.name != "Germany")
				existingCountry.add(subRegions: subRegions, addSubData: addSubData)
				return
			}

			/// Otherwise, create a new country region
			if let newCountry = Region.join(subRegions: subRegions) {
				countries.append(newCountry)
			}
		}

		/// Update US time series
		if let timeSeriesRegion = timeSeriesRegions?.first(where: { $0.name == "US" }) {
			countries.first { $0.name == "US" }?.timeSeries = timeSeriesRegion.timeSeries
		}

		/// World
		let worldRegion = Region.world
		worldRegion.subRegions = countries
		worldRegion.updateFromSubRegions()

		self.world = worldRegion

		let sortedCountries: [Region] = countries.lazy.sorted().reversed()
		for index in sortedCountries.indices {
			sortedCountries[index].order = index
		}

		try? Disk.save(self.world, to: .caches, as: Self.dataFileName)

		completion(true)
	}
}
