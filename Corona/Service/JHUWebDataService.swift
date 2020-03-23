//
//  JHUWebDataService.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/10/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

import Disk

public class JHUWebDataService: DataService {

	enum FetchError: Error {
		case noNewData
		case invalidData
		case downloadError
	}

	private static let reportsFileName = "JHUWebDataService-Reports.json"
	private static let globalTimeSeriesFileName = "JHUWebDataService-GlobalTimeSeries.json"

  // swiftlint:disable line_length
	private static var reportsURL: URL { URL(string: "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases/FeatureServer/1/query?f=json&where=Confirmed%20%3E%200&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=Confirmed%20desc%2CCountry_Region%20asc%2CProvince_State%20asc&resultOffset=0&resultRecordCount=500&cacheHint=false&rnd=\(Int.random())")!
	}
  // swiftlint:enable line_length

  // swiftlint:disable line_length
	private static let globalTimeSeriesURL = URL(string: "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/cases_time_v3/FeatureServer/0/query?f=json&where=1%3D1&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=Report_Date_String%20asc&outSR=102100&resultOffset=0&resultRecordCount=2000&cacheHint=true")!
  // swiftlint:enable line_length

	static let instance = JHUWebDataService()

	public func fetchReports(completion: @escaping FetchResultBlock) {
		print("Calling API")
		let request = URLRequest(url: Self.reportsURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
		_ = URLSession.shared.dataTask(with: request) { (data, response, _) in
			guard let response = response as? HTTPURLResponse,
				response.statusCode == 200,
				let data = data else {

					print("Failed API call")
					completion(nil, FetchError.downloadError)
					return
			}

			DispatchQueue.global(qos: .default).async {
				let oldData = try? Disk.retrieve(Self.reportsFileName, from: .caches, as: Data.self)
				if oldData == data {
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

	private func parseReports(data: Data, completion: @escaping FetchResultBlock) {
		do {
			let decoder = JSONDecoder()
			let result = try decoder.decode(ReportsCallResult.self, from: data)
			let regions = result.features.map { $0.attributes.region }
			completion(regions, nil)
		} catch {
			print("Unexpected error: \(error).")
			completion(nil, error)
		}
	}

	public func fetchTimeSerieses(completion: @escaping FetchResultBlock) {
		print("Calling API")
		let request = URLRequest(url: Self.globalTimeSeriesURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
		_ = URLSession.shared.dataTask(with: request) { (data, response, _) in
			guard let response = response as? HTTPURLResponse,
				response.statusCode == 200,
				let data = data else {

					print("Failed API call")
					completion(nil, FetchError.downloadError)
					return
			}

			DispatchQueue.global(qos: .default).async {
				let oldData = try? Disk.retrieve(Self.globalTimeSeriesFileName, from: .caches, as: Data.self)
				if oldData == data {
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

	private func parseTimeSerieses(data: Data, completion: @escaping FetchResultBlock) {
		do {
			let decoder = JSONDecoder()
			let result = try decoder.decode(GlobalTimeSeriesCallResult.self, from: data)
			let region = result.region
			completion([region], nil)
		} catch {
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
	let provinceState: String?
	let countryRegion: String
	let lastUpdate: Int
	let latitude: Double
	let longitude: Double
	let confirmed: Int?
	let deaths: Int?
	let recovered: Int?

	var region: Region {
		let location = Coordinate(latitude: latitude, longitude: longitude)
		let lastUpdateMilli = Date(timeIntervalSince1970: Double(lastUpdate) / 1000)
		let stat = Statistic(confirmedCount: confirmed ?? 0, recoveredCount: recovered ?? 0, deathCount: deaths ?? 0)
		let report = Report(lastUpdate: lastUpdateMilli, stat: stat)

		var region: Region
		if let name = provinceState {
			region = Region(level: .province, name: name, parentName: countryRegion, location: location)
		} else {
			region = Region(level: .country, name: countryRegion, parentName: nil, location: location)
		}
		region.report = report

		return region
	}
}

private struct GlobalTimeSeriesCallResult: Decodable {
	let features: [GlobalTimeSeriesFeature]

	var region: Region {
		let series = [Date: Statistic](
			uniqueKeysWithValues: zip(
				features.map({ $0.attributes.date }),
				features.map({ $0.attributes.stat })
			)
		)
		let timeSeries = TimeSeries(series: series)

		let region = Region.world
		region.timeSeries = timeSeries

		return region
	}
}

private struct GlobalTimeSeriesFeature: Decodable {
	let attributes: GlobalTimeSeriesAttributes
}

private struct GlobalTimeSeriesAttributes: Decodable {

	let reportDate: Int
	let reportDateString: String
	let totalConfirmed: Int?
	let totalRecovered: Int?
	let deltaConfirmed: Int?
	let deltaRecovered: Int?

	var date: Date {
		Date(timeIntervalSince1970: Double(reportDate) / 1000)
	}

	var stat: Statistic {
		Statistic(confirmedCount: totalConfirmed ?? 0, recoveredCount: totalRecovered ?? 0, deathCount: 0)
	}

}
