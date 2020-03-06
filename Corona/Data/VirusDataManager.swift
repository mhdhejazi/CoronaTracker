//
//  VirusDataManager.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

import CodableCSV
import Disk

class VirusDataManager {
	private let maxOldDataAge = 10 // Days
	private let dailyReportFileName = "daily_report.csv"
	private let confirmedTimeSeriesFileName = "time_series_confirmed.csv"
	private let recoveredTimeSeriesFileName = "time_series_recovered.csv"
	private let deathsTimeSeriesFileName = "time_series_deaths.csv"

//	private let baseURL = URL(string: "https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/")!
//	private lazy var dailyReportURLString = "csse_covid_19_daily_reports/%@.csv"
//	private lazy var confirmedTimeSeriesURL = URL(string: "csse_covid_19_time_series/time_series_19-covid-Confirmed.csv", relativeTo: baseURL)!
//	private lazy var recoveredTimeSeriesURL = URL(string: "csse_covid_19_time_series/time_series_19-covid-Recovered.csv", relativeTo: baseURL)!
//	private lazy var deathsTimeSeriesURL = URL(string: "csse_covid_19_time_series/time_series_19-covid-Deaths.csv", relativeTo: baseURL)!
	private let baseURL = URL(string: "https://github.com/MhdHejazi/COVID19/raw/master/data/")!
	private lazy var dailyReportURL = URL(string: "report.csv", relativeTo: baseURL)!
	private lazy var confirmedTimeSeriesURL = URL(string: "history-confirmed.csv", relativeTo: baseURL)!
	private lazy var recoveredTimeSeriesURL = URL(string: "history-recovered.csv", relativeTo: baseURL)!
	private lazy var deathsTimeSeriesURL = URL(string: "history-deaths.csv", relativeTo: baseURL)!

	static let instance = VirusDataManager()

	var allReports: [VirusReport] = []
	var mainReports: [VirusReport] = []
	var globalReport: VirusReport?

	var allTimeSerieses: [VirusTimeSeries] = []
	var mainTimeSerieses: [VirusTimeSeries] = []
	var globalTimeSeries: VirusTimeSeries?

	private init() {
//		load()
	}

	func report(for region: Region) -> VirusReport? {
		if let report = allReports.first(where: { $0.region == region }) {
			return report
		}

		if let report = mainReports.first(where: { $0.region == region }) {
			return report
		}

		if globalReport?.region == region {
			return globalReport
		}

		return nil
	}

	func timeSeries(for region: Region) -> VirusTimeSeries? {
		if let timeSeries = allTimeSerieses.first(where: { $0.region == region }) {
			return timeSeries
		}

		if let timeSeries = mainTimeSerieses.first(where: { $0.region == region }) {
			return timeSeries
		}

		if globalTimeSeries?.region == region {
			return globalTimeSeries
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
//			let dataFilePath = Bundle.main.path(forResource: "daily_report", ofType: "csv")
//			let data = try Data(contentsOf: URL(fileURLWithPath: dataFilePath!), options: [])
			let data = try Disk.retrieve(dailyReportFileName, from: .caches, as: Data.self)

			let decoder = CSVDecoder()
			decoder.headerStrategy = .firstLine
			allReports = try decoder.decode([VirusReport].self, from: data)

			/// Main reports
			var reports = [VirusReport]()
			reports.append(contentsOf: allReports.filter({ $0.region.province.isEmpty }))
			Dictionary(grouping: allReports.filter({ report in
				!report.region.province.isEmpty
			}), by: { report in
				report.region.country
			}).forEach { (key, value) in
				let report = VirusReport(provinceReports: value.map { $0 })
				reports.append(report)
			}
			mainReports = reports

			/// Global report
			globalReport = VirusReport(provinceReports: allReports)
			globalReport?.region.country = "Worldwide"
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
//			var dataFilePath = Bundle.main.path(forResource: "time_series_confirmed", ofType: "csv")
//			var data = try Data(contentsOf: URL(fileURLWithPath: dataFilePath!), options: [])
			var data = try Disk.retrieve(confirmedTimeSeriesFileName, from: .caches, as: Data.self)
			let result = loadFileTimeSeries(data: data)
			let confirmed = result.rows
			let headers = result.headers

//			dataFilePath = Bundle.main.path(forResource: "time_series_recovered", ofType: "csv")
//			data = try Data(contentsOf: URL(fileURLWithPath: dataFilePath!), options: [])
			data = try Disk.retrieve(recoveredTimeSeriesFileName, from: .caches, as: Data.self)
			let recovered = loadFileTimeSeries(data: data).rows

//			dataFilePath = Bundle.main.path(forResource: "time_series_deaths", ofType: "csv")
//			data = try Data(contentsOf: URL(fileURLWithPath: dataFilePath!), options: [])
			data = try Disk.retrieve(deathsTimeSeriesFileName, from: .caches, as: Data.self)
			let deaths = loadFileTimeSeries(data: data).rows

			let dateFormatter = DateFormatter()
			dateFormatter.locale = .posix
			dateFormatter.dateFormat = "M/d/yy"

			let dateStrings = headers.dropFirst(4)

			var virusTimeSerieses: [VirusTimeSeries] = []
			for row in confirmed.indices {
				let confirmedTimeSeries = confirmed[row]
				let recoveredTimeSeries = recovered[row]
				let deathsTimeSeries = deaths[row]

				var series: [Date : VirusData] = [:]
				for column in confirmedTimeSeries.values.indices {
					let dateString = dateStrings[dateStrings.startIndex + column]
					if let date = dateFormatter.date(from: dateString) {
						let virusData = VirusData(
							confirmedCount: confirmedTimeSeries.values[column],
							recoveredCount: recoveredTimeSeries.values[column],
							deathCount: deathsTimeSeries.values[column]
						)
						series[date] = virusData
					}
				}
				let virusTimeSeries = VirusTimeSeries(region: confirmedTimeSeries.region, series: series)
				virusTimeSerieses.append(virusTimeSeries)
			}
			allTimeSerieses = virusTimeSerieses

			/// Main time serieses
			var timeSerieses = [VirusTimeSeries]()
			timeSerieses.append(contentsOf: allTimeSerieses.filter({ $0.region.province.isEmpty }))
			Dictionary(grouping: allTimeSerieses.filter({ timeSeries in
				!timeSeries.region.province.isEmpty
			}), by: { timeSeries in
				timeSeries.region.country
			}).forEach { (key, value) in
				let timeSeries = VirusTimeSeries(provinceSerieses: value.map { $0 })
				timeSerieses.append(timeSeries)
			}
			mainTimeSerieses = timeSerieses

			/// Global time series
			globalTimeSeries = VirusTimeSeries(provinceSerieses: allTimeSerieses)
			globalTimeSeries?.region.country = "Worldwide"
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

extension VirusDataManager {
	func download(completion: @escaping (Bool) -> ()) {
		downloadDailyReport(completion: completion)
	}

	private func downloadDailyReport(completion: @escaping (Bool) -> ()) {
//		let today = Date()
//		downloadDailyReport(date: today, completion: completion)
		downloadFile(url: dailyReportURL, fileName: dailyReportFileName) { success in
			if !success {
				completion(false)
				return
			}

			self.downloadTimeSerieses(completion: completion)
		}
	}

//	private func downloadDailyReport(date: Date, completion: @escaping (Bool) -> ()) {
//		if date.ageDays > maxOldDataAge {
//			completion(false)
//			return
//		}
//
//		let formatter = DateFormatter()
//		formatter.locale = .posix
//		formatter.dateFormat = "MM-dd-YYYY"
//		let fileName = formatter.string(from: date)
//
//		print("Downloading \(fileName)")
//		let url = URL(string: String(format: dailyReportURLString, fileName), relativeTo: baseURL)!
//
//		_ = URLSession.shared.dataTask(with: url) { (data, response, error) in
//			DispatchQueue.global().async {
//				guard error == nil,
//					let data = data,
//					let string = String(data: data, encoding: .utf8),
//					!string.contains("<html") else {
//
//						print("Failed downloading \(fileName)")
//						self.downloadDailyReport(date: date.yesterday, completion: completion)
//						return
//				}
//
//				try? Disk.save(data, to: .caches, as: self.dailyReportFileName)
//				print("Download success \(fileName)")
//				completion(true)
//
//				self.downloadTimeSerieses(completion: completion)
//			}
//		}.resume()
//	}

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
