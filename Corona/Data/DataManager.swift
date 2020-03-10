//
//  DataManager.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

import Disk

class DataManager {
	private static let reportsFileName = "reports.json"
	private static let timeSeriesesFileName = "time_serieses.json"

	static let instance = DataManager()

	private let dataService: DataService = JHURepoDataService.instance

	var allReports: [Report] = []
	var countryReports: [Report] = []
	var worldwideReport: Report?
	var topReports: [Report] = []

	var allTimeSerieses: [TimeSeries] = []
	var countryTimeSerieses: [TimeSeries] = []
	var worldwideTimeSeries: TimeSeries?

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

	func load(completion: @escaping (Bool) -> ()) {
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
			allReports = try Disk.retrieve(Self.reportsFileName, from: .caches, as: [Report].self)

			generateOtherReports()
		}
		catch {
			print("Unexpected error: \(error).")
			return false
		}

		return true
	}

	private func generateOtherReports() {
		/// Main reports
		var reports = [Report]()
		reports.append(contentsOf: allReports.filter({ !$0.region.isProvince }))
		Dictionary(grouping: allReports.filter({ report in
			report.region.isProvince
		}), by: { report in
			report.region.countryName
		}).forEach { (key, value) in
			let report = Report.join(subReports: value.map { $0 })
			reports.append(report)
		}
		countryReports = reports

		/// Global report
		worldwideReport = Report.join(subReports: allReports)
		worldwideReport?.region.countryName = "Worldwide"

		/// Top countries
		topReports = [Report](
			countryReports.filter({ $0.region.name != "Others" })
				.sorted(by: { $0.stat.confirmedCount < $1.stat.confirmedCount })
				.reversed()
				.prefix(6)
		)
	}

	private func loadTimeSeries() {
		do {
			/// All time serieses
			allTimeSerieses = try Disk.retrieve(Self.timeSeriesesFileName, from: .caches, as: [TimeSeries].self)

			generateOtherTimeSerieses()
		}
		catch {
			print("Unexpected error: \(error).")
		}
	}

	private func generateOtherTimeSerieses() {
		/// Main time serieses
		var timeSerieses = [TimeSeries]()
		timeSerieses.append(contentsOf: allTimeSerieses.filter({ !$0.region.isProvince }))
		Dictionary(grouping: allTimeSerieses.filter({ timeSeries in
			timeSeries.region.isProvince
		}), by: { timeSeries in
			timeSeries.region.countryName
		}).forEach { (key, value) in
			let timeSeries = TimeSeries.join(subSerieses: value.map { $0 })
			timeSerieses.append(timeSeries)
		}
		countryTimeSerieses = timeSerieses

		/// Global time series
		worldwideTimeSeries = TimeSeries.join(subSerieses: allTimeSerieses)
		worldwideTimeSeries?.region.countryName = "Worldwide"
	}
}

extension DataManager {
	func download(completion: @escaping (Bool) -> ()) {
		#if DEBUG
//		return
		#endif

		dataService.fetchReports { (reports, error) in
			guard let reports = reports else {
				completion(false)
				return
			}

			self.allReports = reports
			self.generateOtherReports()

			self.downloadTimeSerieses(completion: completion)
		}
	}

	private func downloadTimeSerieses(completion: @escaping (Bool) -> ()) {
		dataService.fetchTimeSerieses { (timeSerieses, error) in
			guard let timeSerieses = timeSerieses else {
				completion(false)
				return
			}

			self.allTimeSerieses = timeSerieses
			self.generateOtherTimeSerieses()

			try? Disk.save(self.allReports, to: .caches, as: Self.reportsFileName)
			try? Disk.save(self.allTimeSerieses, to: .caches, as: Self.timeSeriesesFileName)

			completion(true)
		}
	}
}
