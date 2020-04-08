//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

import Disk

public class DataManager {
	private static let dataFileName = "data.json"

	public static let instance = DataManager()

	public var world: Region = .world

	public var topCountries: [Region] {
		[Region](regions(of: .country).sorted().reversed().prefix(6))
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
				print("Unexpected error: \(error).")
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
		JHUWebDataService.instance.fetchReports { regions, _ in
			guard let regions = regions else {
				completion(false)
				return
			}

			/// Don't download the time serieses if they are not old enough.
			/// Currently, they are updated from the data source every 24 hours.
//			if self.world.timeSeries?.lastUpdate?.ageDays ?? 0 < 2 {
//				self.update(regions: regions, timeSeriesRegions: self.regions(of: .province), completion: completion)
//				return
//			}

			JHURepoDataService.instance.fetchTimeSerieses { timeSeriesRegions, _ in
				self.update(regions: regions, timeSeriesRegions: timeSeriesRegions, completion: completion)
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
		Dictionary(grouping: provinceRegions, by: { $0.parentName }).values.forEach { value in
			if let countryRegion = Region.join(subRegions: value) {
				countries.append(countryRegion)
			}
		}

		/// Update US time series
		if let timeSeriesRegion = timeSeriesRegions?.first(where: { $0.name == "US" }) {
			countries.first { $0.name == "US" }?.timeSeries = timeSeriesRegion.timeSeries
		}

		/// World
		let worldRegion = Region.world
		worldRegion.subRegions = countries

		self.world = worldRegion

		try? Disk.save(self.world, to: .caches, as: Self.dataFileName)

		completion(true)
	}
}
