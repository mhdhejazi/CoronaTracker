//
//  JHUWebDataService.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/10/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

import Disk

class JHUWebDataService: DataService {
	enum FetchError: Error {
		case noNewData
		case invalidData
		case downloadError
	}

	private static let reportsFileName = "JHUWebDataService-Reports.json"
	private static let globalTimeSeriesFileName = "JHUWebDataService-GlobalTimeSeries.json"

	private static let reportsURL = URL(string: "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases/FeatureServer/1/query?f=json&where=Confirmed%20%3E%200&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=Confirmed%20desc%2CCountry_Region%20asc%2CProvince_State%20asc&resultOffset=0&resultRecordCount=500&cacheHint=true")!
	private static let globalTimeSeriesURL = URL(string: "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/cases_time_v3/FeatureServer/0/query?f=json&where=1%3D1&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=Report_Date_String%20asc&outSR=102100&resultOffset=0&resultRecordCount=2000&cacheHint=true")!

	static let instance = JHUWebDataService()

	func fetchReports(completion: @escaping FetchReportsBlock) {
		print("Calling API")
		_ = URLSession.shared.dataTask(with: Self.reportsURL) { (data, response, error) in
			guard let response = response as? HTTPURLResponse,
				response.statusCode == 200,
				let data = data else {

					print("Failed API call")
					completion(nil, FetchError.downloadError)
					return
			}

			DispatchQueue.global(qos: .default).async {
				let oldData = try? Disk.retrieve(Self.reportsFileName, from: .caches, as: Data.self)
				if (oldData == data) {
					print("Nothing new")
					completion(nil, FetchError.noNewData)
					return
				}

				print("Download success")
				try? Disk.save(data, to: .caches, as: Self.reportsFileName)

				self.parseReports(data: data, completion: completion)
			}
		}.resume()
	}

	private func parseReports(data: Data, completion: @escaping FetchReportsBlock) {
		do {
			let decoder = JSONDecoder()
			let result = try decoder.decode(ReportsCallResult.self, from: data)
			let reports = result.features.map { $0.attributes.report }
			completion(reports, nil)
		}
		catch {
			print("Unexpected error: \(error).")
			completion(nil, error)
		}
	}

	func fetchTimeSerieses(completion: @escaping FetchTimeSeriesesBlock) {
		print("Calling API")
		_ = URLSession.shared.dataTask(with: Self.globalTimeSeriesURL) { (data, response, error) in
			guard let response = response as? HTTPURLResponse,
				response.statusCode == 200,
				let data = data else {

					print("Failed API call")
					completion(nil, FetchError.downloadError)
					return
			}

			DispatchQueue.global(qos: .default).async {
				let oldData = try? Disk.retrieve(Self.globalTimeSeriesFileName, from: .caches, as: Data.self)
				if (oldData == data) {
					print("Nothing new")
					completion(nil, FetchError.noNewData)
					return
				}

				print("Download success")
				try? Disk.save(data, to: .caches, as: Self.globalTimeSeriesFileName)

				self.parseTimeSerieses(data: data, completion: completion)
			}
		}.resume()
	}

	private func parseTimeSerieses(data: Data, completion: @escaping FetchTimeSeriesesBlock) {
		do {
			let decoder = JSONDecoder()
			let result = try decoder.decode(GlobalTimeSeriesCallResult.self, from: data)
			let timeSeries = result.timeSeries
			completion([timeSeries], nil)
		}
		catch {
			print("Unexpected error: \(error).")
			completion(nil, error)
		}
	}
}

private struct ReportsCallResult: Decodable {
	let features: [ReportFeature]
}

private struct ReportFeature: Decodable {
	let attributes: ReportAttributes
}

private struct ReportAttributes: Decodable {
	let Province_State: String?
	let Country_Region: String
	let Last_Update: Int
	let Lat: Double
	let Long_: Double
	let Confirmed: Int?
	let Deaths: Int?
	let Recovered: Int?

	var report: Report {
		let location = Coordinate(latitude: Lat, longitude: Long_)
		let region = Region(countryName: Country_Region, provinceName: Province_State ?? "", location: location)
		let lastUpdate = Date(timeIntervalSince1970: Double(Last_Update) / 1000)
		let stat = Statistic(confirmedCount: Confirmed ?? 0, recoveredCount: Recovered ?? 0, deathCount: Deaths ?? 0)

		return Report(region: region, lastUpdate: lastUpdate, stat: stat)
	}
}

private struct GlobalTimeSeriesCallResult: Decodable {
	let features: [GlobalTimeSeriesFeature]

	var timeSeries: TimeSeries {
		let location = Coordinate(latitude: 0, longitude: 0)
		let region = Region(countryName: "Worldwide", provinceName: "", location: location)
		let series = [Date : Statistic](
			uniqueKeysWithValues: zip(
				features.map({ $0.attributes.date }),
				features.map({ $0.attributes.stat })
			)
		)
		return TimeSeries(region: region, series: series)
	}
}

private struct GlobalTimeSeriesFeature: Decodable {
	let attributes: GlobalTimeSeriesAttributes
}

private struct GlobalTimeSeriesAttributes: Decodable {
	let Report_Date: Int
	let Report_Date_String: String
	let Total_Confirmed: Int?
	let Total_Recovered: Int?
	let Delta_Confirmed: Int?
	let Delta_Recovered: Int?

	var date: Date {
		Date(timeIntervalSince1970: Double(Report_Date) / 1000)
	}
	var stat: Statistic {
		Statistic(confirmedCount: Total_Confirmed ?? 0, recoveredCount: Total_Recovered ?? 0, deathCount: 0)
	}
}
