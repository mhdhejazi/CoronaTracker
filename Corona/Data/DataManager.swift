//
//  DataManager.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

import CodableCSV
import Disk

class DataManager {
	private let maxOldDataAge = 10 // Days
	private let dailyReportFileName = "daily_report.csv"
	private let confirmedTimeSeriesFileName = "time_series_confirmed.csv"
	private let recoveredTimeSeriesFileName = "time_series_recovered.csv"
	private let deathsTimeSeriesFileName = "time_series_deaths.csv"

	private let baseURL = URL(string: "https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/")!
	private lazy var dailyReportURLString = "csse_covid_19_daily_reports/%@.csv"
	private lazy var confirmedTimeSeriesURL = URL(string: "csse_covid_19_time_series/time_series_19-covid-Confirmed.csv", relativeTo: baseURL)!
	private lazy var recoveredTimeSeriesURL = URL(string: "csse_covid_19_time_series/time_series_19-covid-Recovered.csv", relativeTo: baseURL)!
	private lazy var deathsTimeSeriesURL = URL(string: "csse_covid_19_time_series/time_series_19-covid-Deaths.csv", relativeTo: baseURL)!

	static let instance = DataManager()

	var allReports: [Report] = []
	var countryReports: [Report] = []
	var worldwideReport: Report?
	var topReports: [Report] = []

	var allTimeSerieses: [TimeSeries] = []
	var countryTimeSerieses: [TimeSeries] = []
	var worldwideTimeSeries: TimeSeries?

	private init() {
//		load()
	}

	func report(for region: Region) -> Report? {
		if let report = allReports.first(where: { $0.region == region }) {
			return report
		}

		if let report = countryReports.first(where: { $0.region == region }) {
			return report
		}

		if worldwideReport?.region == region {
			return worldwideReport
		}

		return nil
	}

	func timeSeries(for region: Region) -> TimeSeries? {
		if let timeSeries = allTimeSerieses.first(where: { $0.region == region }) {
			return timeSeries
		}

		if let timeSeries = countryTimeSerieses.first(where: { $0.region == region }) {
			return timeSeries
		}

		if worldwideTimeSeries?.region == region {
			return worldwideTimeSeries
		}

		return nil
	}

	func load() -> Bool {
		loadTimeSeries()
		return loadReports()
	}

	func loadAsync(completion: @escaping (Bool) -> ()) {
		DispatchQueue.global().async {
			self.loadTimeSeries()
			let result = self.loadReports()
			DispatchQueue.main.async {
				completion(result);
			}
		}
	}

	private func loadReports() -> Bool {
		do {
			/// All reports
			let data = try Disk.retrieve(dailyReportFileName, from: .caches, as: Data.self)

			let decoder = CSVDecoder()
			decoder.headerStrategy = .firstLine
			allReports = try decoder.decode([Report].self, from: data)

			/// Main reports
			var reports = [Report]()
			reports.append(contentsOf: allReports.filter({ $0.region.province.isEmpty }))
			Dictionary(grouping: allReports.filter({ report in
				!report.region.province.isEmpty
			}), by: { report in
				report.region.country
			}).forEach { (key, value) in
				let report = Report(subReports: value.map { $0 })
				reports.append(report)
			}
			countryReports = reports

			/// Global report
			worldwideReport = Report(subReports: allReports)
			worldwideReport?.region.country = "Worldwide"

			/// Top countries
			topReports = [Report](
				countryReports.filter({ $0.region.name != "Others" })
					.sorted(by: { $0.stat.confirmedCount < $1.stat.confirmedCount })
					.reversed()
					.prefix(6)
			)
		}
		catch {
			print("Unexpected error: \(error).")
			return false
		}

		return true
	}

	private func loadTimeSeries() {
		do {
			/// All time serieses
			var data = try Disk.retrieve(confirmedTimeSeriesFileName, from: .caches, as: Data.self)
			let result = loadFileTimeSeries(data: data)
			let confirmed = result.rows
			let headers = result.headers

			data = try Disk.retrieve(recoveredTimeSeriesFileName, from: .caches, as: Data.self)
			let recovered = loadFileTimeSeries(data: data).rows

			data = try Disk.retrieve(deathsTimeSeriesFileName, from: .caches, as: Data.self)
			let deaths = loadFileTimeSeries(data: data).rows

			let dateFormatter = DateFormatter()
			dateFormatter.locale = .posix
			dateFormatter.dateFormat = "M/d/yy"

			let dateStrings = headers.dropFirst(4)

			var timeSerieses: [TimeSeries] = []
			for row in confirmed.indices {
				let confirmedTimeSeries = confirmed[row]
				let recoveredTimeSeries = recovered[row]
				let deathsTimeSeries = deaths[row]

				var series: [Date : Statistic] = [:]
				for column in confirmedTimeSeries.values.indices {
					let dateString = dateStrings[dateStrings.startIndex + column]
					if let date = dateFormatter.date(from: dateString) {
						let stat = Statistic(
							confirmedCount: confirmedTimeSeries.values[column],
							recoveredCount: recoveredTimeSeries.values[column],
							deathCount: deathsTimeSeries.values[column]
						)
						series[date] = stat
					}
				}
				let timeSeries = TimeSeries(region: confirmedTimeSeries.region, series: series)
				timeSerieses.append(timeSeries)
			}
			allTimeSerieses = timeSerieses

			/// Main time serieses
			timeSerieses = []
			timeSerieses.append(contentsOf: allTimeSerieses.filter({ $0.region.province.isEmpty }))
			Dictionary(grouping: allTimeSerieses.filter({ timeSeries in
				!timeSeries.region.province.isEmpty
			}), by: { timeSeries in
				timeSeries.region.country
			}).forEach { (key, value) in
				let timeSeries = TimeSeries(subSerieses: value.map { $0 })
				timeSerieses.append(timeSeries)
			}
			countryTimeSerieses = timeSerieses

			/// Global time series
			worldwideTimeSeries = TimeSeries(subSerieses: allTimeSerieses)
			worldwideTimeSeries?.region.country = "Worldwide"
		}
		catch {
			print("Unexpected error: \(error).")
		}
	}

	private func loadFileTimeSeries(data: Data) -> (rows: [CounterTimeSeries], headers: [String]) {
		do {
			let decoder = CSVDecoder()
			decoder.headerStrategy = .firstLine
			let result = try decoder.decode([CounterTimeSeries].self, from: data)

			let rows = try CSVReader(data: data).parseRow()

			return (result, rows ?? [])
		}
		catch {
			print("Unexpected error: \(error).")
			return ([], [])
		}
	}
}

extension DataManager {
	func download(completion: @escaping (Bool) -> ()) {
		#if DEBUG
//		return
		#endif
		downloadDailyReport(completion: completion)
	}

	private func downloadDailyReport(completion: @escaping (Bool) -> ()) {
		let today = Date()
		downloadDailyReport(date: today, completion: completion)
	}

	private func downloadDailyReport(date: Date, completion: @escaping (Bool) -> ()) {
		if date.ageDays > maxOldDataAge {
			completion(false)
			return
		}

		let formatter = DateFormatter()
		formatter.locale = .posix
		formatter.dateFormat = "MM-dd-YYYY"
		let fileName = formatter.string(from: date)

		print("Downloading \(fileName)")
		let url = URL(string: String(format: dailyReportURLString, fileName), relativeTo: baseURL)!

		_ = URLSession.shared.dataTask(with: url) { (data, response, error) in
			DispatchQueue.global().async {
				guard error == nil,
					let data = data,
					let string = String(data: data, encoding: .utf8),
					!string.contains("<html") else {

						print("Failed downloading \(fileName)")
						self.downloadDailyReport(date: date.yesterday, completion: completion)
						return
				}

				try? Disk.save(data, to: .caches, as: self.dailyReportFileName)
				print("Download success \(fileName)")

				_ = self.loadReports()
				completion(true)

				self.downloadTimeSerieses(completion: completion)
			}
		}.resume()
	}

	private func downloadTimeSerieses(completion: @escaping (Bool) -> ()) {
		let dispatchGroup = DispatchGroup()
		var result = true

		dispatchGroup.enter()
		downloadFile(url: confirmedTimeSeriesURL, fileName: confirmedTimeSeriesFileName) { success in
			result = result && success
			dispatchGroup.leave()
		}

		dispatchGroup.enter()
		downloadFile(url: recoveredTimeSeriesURL, fileName: recoveredTimeSeriesFileName) { success in
			result = result && success
			dispatchGroup.leave()
		}

		dispatchGroup.enter()
		downloadFile(url: deathsTimeSeriesURL, fileName: deathsTimeSeriesFileName) { success in
			result = result && success
			dispatchGroup.leave()
		}

		dispatchGroup.notify(queue: .main) {
			if result {
				self.loadTimeSeries()
			}
			completion(result)
		}
	}

	private func downloadFile(url: URL, fileName: String, completion: @escaping (Bool) -> ()) {
		print("Downloading \(fileName)")
		_ = URLSession.shared.dataTask(with: url) { (data, response, error) in
			DispatchQueue.global().async {
				guard error == nil,
					let data = data,
					let string = String(data: data, encoding: .utf8),
					!string.contains("<html") else {

						print("Failed downloading \(fileName)")
						completion(false)
						return
				}

				try? Disk.save(data, to: .caches, as: fileName)
				print("Download success \(fileName)")
				completion(true)
			}
		}.resume()
	}

}
