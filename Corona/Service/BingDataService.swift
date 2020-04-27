//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/10/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

public class BingDataService: BaseDataService, DataService {
	private static let reportsURL = URL(string: "https://bing.com/covid/")!

	static let shared = BingDataService()

	public func fetchReports(completion: @escaping FetchResultBlock) {
		fetchData(from: Self.reportsURL) { data, error in
			guard let data = data else {
				completion(nil, error)
				return
			}

			self.parseReports(data: data, completion: completion)
		}
	}

	private func parseReports(data: Data, completion: @escaping FetchResultBlock) {
		do {
			guard let string = String(data: data, encoding: .utf8),
				let pattern = try? NSRegularExpression(pattern: #"var data=(\{.+\});"#, options: []),
				let match = pattern.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count)),
				let jsonData = (string as NSString).substring(with: match.range(at: 1)).data(using: .utf8) else {
				return
			}

			let decoder = JSONDecoder()
			let result = try decoder.decode(ReportData.self, from: jsonData)

			let regions = result.areas?.map { reportData -> Region in
				let country = reportData.createRegion(level: .country, parentName: Region.world.name)

				if let provinces = reportData.areas?.map({ subReportData in
					subReportData.createRegion(level: .province, parentName: reportData.displayName)
				}) {
					country.subRegions = provinces
				}

				return country
			}

			completion(regions, nil)
		} catch {
			debugPrint("Unexpected error:", error)
			completion(nil, error)
		}
	}

	public func fetchTimeSerieses(completion: @escaping FetchResultBlock) {
		fatalError("Not implemented")
	}
}

// MARK: - Report API

private struct ReportData: Decodable {
	let id: String
	let displayName: String
	let lastUpdated: String
	let totalConfirmed: Int?
	let totalConfirmedDelta: Int?
	let totalDeaths: Int?
	let totalDeathsDelta: Int?
	let totalRecovered: Int?
	let totalRecoveredDelta: Int?
	let lat: Double?
	let long: Double?
	let areas: [ReportData]?

	func createRegion(level: Region.Level, parentName: String) -> Region {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
		let lastUpdate = formatter.date(from: lastUpdated) ?? Date()

		let stat = Statistic(confirmedCount: totalConfirmed ?? 0,
							 recoveredCount: totalRecovered ?? 0,
							 deathCount: totalDeaths ?? 0)
		let report = Report(lastUpdate: lastUpdate, stat: stat)

		let location = Coordinate(latitude: lat ?? 0, longitude: long ?? 0)
		let region = Region(level: level, name: displayName, parentName: parentName, location: location)
		region.report = report

		return region
	}
}
