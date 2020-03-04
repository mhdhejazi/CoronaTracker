//
//  VirusDataManager.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

import CodableCSV

class VirusDataManager {
	static let instance = VirusDataManager()

	var allReports: [VirusReport] = []
	var mainReports: [VirusReport] = []

	var allTimeSerieses: [VirusTimeSeries] = []
	var mainTimeSerieses: [VirusTimeSeries] = []

	init() {
		load()
	}

	func report(for region: Region) -> VirusReport? {
		if let report = allReports.first(where: { $0.region == region }) {
			return report
		}

		return mainReports.first { $0.region == region }
	}

	func timeSeries(for region: Region) -> VirusTimeSeries? {
		if let report = allTimeSerieses.first(where: { $0.region == region }) {
			return report
		}

		return mainTimeSerieses.first { $0.region == region }
	}

	func load() {
		loadReports()
		loadTimeSeries()
	}

	private func loadReports() {
		do {
			/// All reports
			let dataFilePath = Bundle.main.path(forResource: "daily_report", ofType: "csv")
			let data = try Data(contentsOf: URL(fileURLWithPath: dataFilePath!), options: [])

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
		}
		catch {
			print("Unexpected error: \(error).")
		}
	}

	private func loadTimeSeries() {
		/// All time serieses
		var dataFilePath = Bundle.main.path(forResource: "time_series_confirmed", ofType: "csv")
		var dataFileURL = URL(fileURLWithPath: dataFilePath!)
		let result = loadFileTimeSeries(fileURL: dataFileURL)
		let confirmed = result.rows
		let headers = result.headers

		dataFilePath = Bundle.main.path(forResource: "time_series_recovered", ofType: "csv")
		dataFileURL = URL(fileURLWithPath: dataFilePath!)
		let recovered = loadFileTimeSeries(fileURL: dataFileURL).rows

		dataFilePath = Bundle.main.path(forResource: "time_series_deaths", ofType: "csv")
		dataFileURL = URL(fileURLWithPath: dataFilePath!)
		let deaths = loadFileTimeSeries(fileURL: dataFileURL).rows

		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
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
	}

	private func loadFileTimeSeries(fileURL: URL) -> (rows: [CounterTimeSeries], headers: [String]) {
		do {
			let data = try Data(contentsOf: fileURL, options: [])

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
