//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/10/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

import CSV

public class JHURepoDataService: DataService {
	enum FetchError: Error {
		case tooOldData
		case noNewData
		case invalidData
		case downloadError
	}

	static let shared = JHURepoDataService()

	private static let maxOldDataAge = 10 // Days
	private static let baseURL = URL(string: "https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/")!
	private static let dailyReportURLString = "csse_covid_19_daily_reports/%@.csv"
	private static let confirmedTimeSeriesURL = URL(
		string: "csse_covid_19_time_series/time_series_covid19_confirmed_global.csv",
		relativeTo: baseURL)!
	private static let recoveredTimeSeriesURL = URL(
		string: "csse_covid_19_time_series/time_series_covid19_recovered_global.csv",
		relativeTo: baseURL)!
	private static let deathsTimeSeriesURL = URL(
		string: "csse_covid_19_time_series/time_series_covid19_deaths_global.csv",
		relativeTo: baseURL)!

	private var lastReportsDataHash: String?

	public func fetchReports(completion: @escaping FetchResultBlock) {
		let today = Date()
		downloadDailyReport(date: today, completion: completion)
	}

	private func downloadDailyReport(date: Date, completion: @escaping FetchResultBlock) {
		if date.ageDays > Self.maxOldDataAge {
			completion(nil, FetchError.tooOldData)
			return
		}

		let formatter = DateFormatter()
		formatter.locale = .posix
		formatter.dateFormat = "MM-dd-YYYY"
		let fileName = formatter.string(from: date)

		print("Downloading", fileName)
		let url = URL(string: String(format: Self.dailyReportURLString, fileName), relativeTo: Self.baseURL)!

		URLSession.shared.dataTask(with: url) { data, response, _ in

			guard let response = response as? HTTPURLResponse,
				response.statusCode == 200,
				let data = data else {

					print("Failed downloading", fileName)
					self.downloadDailyReport(date: date.yesterday, completion: completion)
					return
			}

			DispatchQueue.global(qos: .default).async {
				let dataHash = data.sha1Hash()
				if dataHash == self.lastReportsDataHash {
					print("Nothing new")
					completion(nil, FetchError.noNewData)
					return
				}

				print("Download success", fileName)
				self.lastReportsDataHash = dataHash

				self.parseReports(data: data, completion: completion)
			}
		}.resume()
	}

	private func parseReports(data: Data, completion: @escaping FetchResultBlock) {
		do {
			let reader = try CSVReader(string: String(data: data, encoding: .utf8)!, hasHeaderRow: true)
			let regions = reader.map(Region.createFromReportData)
			completion(regions, nil)
		} catch {
			debugPrint("Unexpected error:", error)
			completion(nil, error)
		}
	}

	public func fetchTimeSerieses(completion: @escaping FetchResultBlock) {
		let dispatchGroup = DispatchGroup()
		var result = [Data?](repeating: nil, count: 3)

		dispatchGroup.enter()
		downloadFile(url: Self.confirmedTimeSeriesURL) { data in
			result[0] = data
			dispatchGroup.leave()
		}

		dispatchGroup.enter()
		downloadFile(url: Self.recoveredTimeSeriesURL) { data in
			result[1] = data
			dispatchGroup.leave()
		}

		dispatchGroup.enter()
		downloadFile(url: Self.deathsTimeSeriesURL) { data in
			result[2] = data
			dispatchGroup.leave()
		}

		dispatchGroup.notify(queue: .main) {
			let result = result.compactMap { $0 }
			if result.count != 3 {
				completion(nil, FetchError.downloadError)
				return
			}

			DispatchQueue.global(qos: .default).async {
				self.parseTimeSerieses(data: result, completion: completion)
			}
		}
	}

	private func parseTimeSerieses(data: [Data], completion: @escaping FetchResultBlock) {
		assert(data.count == 3)

		/// All time serieses
		guard let (confirmed, headers) = parseTimeSeries(data: data[0]) else {
			completion(nil, FetchError.invalidData)
			return
		}

		guard let (recovered, _) = parseTimeSeries(data: data[1]) else {
			completion(nil, FetchError.invalidData)
			return
		}

		guard let (deaths, _) = parseTimeSeries(data: data[2]) else {
			completion(nil, FetchError.invalidData)
			return
		}

		let dateFormatter = DateFormatter()
		dateFormatter.locale = .posix
		dateFormatter.timeZone = .utc
		dateFormatter.dateFormat = "M/d/yy"

		let dateStrings = headers.dropFirst(4)
		let dateValues = dateStrings.map { dateFormatter.date(from: $0) }

		var regions: [Region] = []
		for confirmedTimeSeries in confirmed {
			let recoveredTimeSeries = recovered.first { $0.region == confirmedTimeSeries.region }
			let deathsTimeSeries = deaths.first { $0.region == confirmedTimeSeries.region }

			var series: [Date: Statistic] = [:]
			for column in confirmedTimeSeries.values.indices {
				if let date = dateValues[dateValues.startIndex + column] {
					var recoveredCount = 0
					if let recoveredTimeSeries = recoveredTimeSeries {
						recoveredCount = recoveredTimeSeries.values[min(column, recoveredTimeSeries.values.count - 1)]
					}
					var deathCount = 0
					if let deathsTimeSeries = deathsTimeSeries {
						deathCount = deathsTimeSeries.values[min(column, deathsTimeSeries.values.count - 1)]
					}
					let stat = Statistic(
						confirmedCount: confirmedTimeSeries.values[column],
						recoveredCount: recoveredCount,
						deathCount: deathCount
					)
					series[date] = stat
				}
			}
			let timeSeries = TimeSeries(series: series)

			let region = confirmedTimeSeries.region
			region.timeSeries = timeSeries

			regions.append(region)
		}
		completion(regions, nil)
	}

	private func parseTimeSeries(data: Data) -> (rows: [CounterTimeSeries], headers: [String])? {
		do {
			let reader = try CSVReader(string: String(data: data, encoding: .utf8)!, hasHeaderRow: true)
			let headers = reader.headerRow
			let result = reader.map(CounterTimeSeries.init)

			return (result, headers ?? [])
		} catch {
			debugPrint("Unexpected error:", error)
			return nil
		}
	}

	private func downloadFile(url: URL, completion: @escaping (Data?) -> Void) {
		let fileName = url.lastPathComponent
		print("Downloading", fileName)
		URLSession.shared.dataTask(with: url) { (data, response, _) in
			guard let response = response as? HTTPURLResponse,
				response.statusCode == 200,
				let data = data else {

					print("Failed downloading", fileName)
					completion(nil)
					return
			}

			DispatchQueue.global().async {
				print("Download success", fileName)

				completion(data)
			}
		}.resume()
	}
}

extension Region {
	private enum DataFieldOrder: Int {
		case province = 0
		case country
		case lastUpdate
		case confirmed
		case deaths
		case recovered
		case latitude
		case longitude
	}

	fileprivate static func createFromReportData(dataRow: [String]) -> Region {
		let province = dataRow[DataFieldOrder.province.rawValue]
		let country = dataRow[DataFieldOrder.country.rawValue]
		let latitude = Double(dataRow[DataFieldOrder.latitude.rawValue]) ?? 0
		let longitude = Double(dataRow[DataFieldOrder.longitude.rawValue]) ?? 0
		let location = Coordinate(latitude: latitude, longitude: longitude)

		let timeString = dataRow[DataFieldOrder.lastUpdate.rawValue]
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
		let lastUpdate = formatter.date(from: timeString) ?? Date()

		let confirmed = Int(dataRow[DataFieldOrder.confirmed.rawValue]) ?? 0
		let deaths = Int(dataRow[DataFieldOrder.deaths.rawValue]) ?? 0
		let recovered = Int(dataRow[DataFieldOrder.recovered.rawValue]) ?? 0
		let stat = Statistic(confirmedCount: confirmed, recoveredCount: recovered, deathCount: deaths)

		let report = Report(lastUpdate: lastUpdate, stat: stat)

		var region: Region
		if province.isEmpty {
			region = Region(level: .country, name: country, parentName: nil, location: location)
		} else {
			region = Region(level: .province, name: province, parentName: country, location: location)
		}
		region.report = report

		return region
	}
}

private class CounterTimeSeries {
	private enum DataFieldOrder: Int {
		case province = 0
		case country
		case latitude
		case longitude
	}

	let region: Region
	let values: [Int]

	init(dataRow: [String]) {
		let province = dataRow[DataFieldOrder.province.rawValue]
		let country = dataRow[DataFieldOrder.country.rawValue]
		let latitude = Double(dataRow[DataFieldOrder.latitude.rawValue]) ?? 0
		let longitude = Double(dataRow[DataFieldOrder.longitude.rawValue]) ?? 0
		let location = Coordinate(latitude: latitude, longitude: longitude)

		var region: Region
		if province.isEmpty {
			region = Region(level: .country, name: country, parentName: nil, location: location)
		} else {
			region = Region(level: .province, name: province, parentName: country, location: location)
		}
		self.region = region

		self.values = dataRow.dropFirst(DataFieldOrder.longitude.rawValue + 1).map { Int($0) ?? 0 }
	}
}
