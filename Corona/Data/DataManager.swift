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
		let dispatchGroup = DispatchGroup()
		var result: (jhu: [Region]?, bing: [Region]?, rki: [Region]?, austria: [Region]?) = (nil, nil, nil, nil)

		/// Main data is from JHU
		dispatchGroup.enter()
		JHUWebDataService.shared.fetchReports { regions, _ in
			guard let regions = regions else {
				dispatchGroup.leave()
				completion(false)
				return
			}

			JHURepoDataService.shared.fetchTimeSerieses { timeSeriesRegions, _ in
				self.update(regions: regions, timeSeriesRegions: timeSeriesRegions)
				result.jhu = regions
				dispatchGroup.leave()
			}
		}

		/// Add more data from Bing
		dispatchGroup.enter()
		BingDataService.shared.fetchReports { regions, _ in
			guard let regions = regions else {
				dispatchGroup.leave()
				return
			}

			result.bing = regions
			dispatchGroup.leave()
		}

		/// Add data for Germany
		dispatchGroup.enter()
		RKIDataService.shared.fetchReports { regions, _ in
			guard let regions = regions else {
				dispatchGroup.leave()
				return
			}

			result.rki = regions
			dispatchGroup.leave()
		}

		/// Add data from Austria
		dispatchGroup.enter()
		BMSGPKDataService.shared.fetchReports { regions, _ in
			guard let regions = regions else {
				dispatchGroup.leave()
				return
			}

			result.austria = regions
			dispatchGroup.leave()
		}

		dispatchGroup.notify(queue: .global(qos: .default)) {
			if result.jhu == nil {
				return
			}

			/// Data from Bing
			if let regions = result.bing {
				for region in regions where !region.subRegions.isEmpty {
					if let regionCode = Locale.isoCode(for: region.name),
						let existingRegion = self.world.find(subRegionCode: regionCode),
						existingRegion.subRegions.count < region.subRegions.count / 2 {
						existingRegion.subRegions = region.subRegions
					}
				}
			}

			/// Data for Germany comes from a different source, so don't accumulate data
			if let subRegions = result.rki, let region = self.world.find(subRegionCode: "DEU") {
				region.subRegions = subRegions
			}

			/// Data for Austria comes from a different source, so don't accumulate data
			if let austrianSubRegions = result.austria, let region = self.world.find(subRegionCode: "AUT") {
				region.subRegions = austrianSubRegions
			}

			try? Disk.save(self.world, to: .caches, as: Self.dataFileName)

			completion(true)
		}
	}

	private func update(regions: [Region], timeSeriesRegions: [Region]?) {
		timeSeriesRegions?.forEach { timeSeriesRegion in
			regions.first { $0 == timeSeriesRegion }?.timeSeries = timeSeriesRegion.timeSeries
		}

		/// Countries
		var countries = [Region]()
		var newCountries = [Region]()
		countries += regions.filter { !$0.isProvince }
		let provinceRegions = regions.filter { $0.isProvince }
		Dictionary(grouping: provinceRegions, by: { $0.parentName }).values.forEach { subRegions in
			/// If there is already a region for this country, just add the sub regions
			if let existingCountry = countries.first(where: { $0.name == subRegions.first?.parentName }) {
				existingCountry.add(subRegions: subRegions, addSubData: true)
				return
			}

			/// Otherwise, create a new country region
			if let newCountry = Region.join(subRegions: subRegions) {
				countries.append(newCountry)
				newCountries.append(newCountry)
			}
		}

		/// Update the time series for the newly created countries
		newCountries.forEach { country in
			if let region = timeSeriesRegions?.first(where: { $0 == country }) {
				country.timeSeries = region.timeSeries
			}
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
	}

	/// Fetches data from JHU and updates internal data models (`.world`).
	/// Since widgets have a peak memory usage limitation of 30Mb, keep it as simple as possible.
	/// - Parameter completion: Called after fetching data.
	/// - Note: A future improvement would be to parse only the data the widget needs:
	/// - Data only for the selected COUNTRY/WORLDWIDE (`subRegions` can be skipped);
	/// - Statistics only for today and yesterday (to display the daily change in number of cases).
	public func fetchWidgetsData(completion: @escaping (Bool) -> Void) {
		JHUWebDataService.shared.fetchReports { regions, _ in
			guard let regions = regions else {
				completion(false)
				return
			}

			JHURepoDataService.shared.fetchTimeSerieses { timeSeriesRegions, _ in
				self.update(regions: regions, timeSeriesRegions: timeSeriesRegions)
				completion(true)
			}
		}
	}
}
