//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/10/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

public class JHUWebDataService: DataService {
	enum FetchError: Error {
		case noNewData
		case invalidData
		case downloadError
	}

	// swiftlint:disable line_length
	private static var reportsURL: URL {
		URL(string: "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases/FeatureServer/1/query?f=json&where=Confirmed%20%3E%200&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=Confirmed%20desc%2CCountry_Region%20asc%2CProvince_State%20asc&resultOffset=0&resultRecordCount=500&cacheHint=false&rnd=\(Int.random())")!
	}
	private static let globalTimeSeriesURL = URL(string: "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/cases_time_v3/FeatureServer/0/query?f=json&where=1%3D1&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=Report_Date_String%20asc&outSR=102100&resultOffset=0&resultRecordCount=2000&cacheHint=true")!

	private static let usRecoveredCasesURL = URL(string: "https://services9.arcgis.com/N9p5hsImWXAccRNI/arcgis/rest/services/Nc2JKvYFoAEOFCG5JSI6/FeatureServer/1/query?f=json&where=Country_Region%3D%27US%27&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&outStatistics=%5B%7B%22statisticType%22%3A%22sum%22%2C%22onStatisticField%22%3A%22Recovered%22%2C%22outStatisticFieldName%22%3A%22value%22%7D%5D&outSR=102100&cacheHint=true")!
	// swiftlint:enable line_length

	static let instance = JHUWebDataService()

	private var lastReportsDataHash: String?
	private var lastTimeSeriesDataHash: String?

	public func fetchReports(completion: @escaping FetchResultBlock) {
		print("Calling API")
		requestAPI(url: Self.reportsURL) { data, error in
			guard let data = data else {
				completion(nil, error)
				return
			}

			DispatchQueue.global(qos: .default).async {
				let dataHash = data.sha1Hash()
				if dataHash == self.lastReportsDataHash {
					print("Nothing new")
					completion(nil, FetchError.noNewData)
					return
				}

				print("Download success")
				self.lastReportsDataHash = dataHash

				self.parseReports(data: data) { result, error in
					/// Update recovered cases for US
					self.requestAPI(url: Self.usRecoveredCasesURL) { data, error in
						var result = result
						if let recoveredCount = self.parseRecoveredCount(data: data) {
							/// Workaround: Add the recovered data as a dummy province since we don't have US region at this level
							let dummyRegion = Region(level: .province, name: "Recovered", parentName: "US", location: .zero)
							let dummyStat = Statistic(confirmedCount: 0, recoveredCount: recoveredCount, deathCount: 0)
							dummyRegion.report = Report(lastUpdate: Date().yesterday, stat: dummyStat)
							result?.append(dummyRegion)
						}
						completion(result, error)
					}
				}
			}
		}
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

	private func parseRecoveredCount(data: Data?) -> Int? {
		guard let data = data else { return nil }

		do {
			let decoder = JSONDecoder()
			let result = try decoder.decode(USRecoveredCallResult.self, from: data)
			return result.value
		} catch {
			print("Unexpected error: \(error).")
			return nil
		}
	}

	public func fetchTimeSerieses(completion: @escaping FetchResultBlock) {
		print("Calling API")
		requestAPI(url: Self.globalTimeSeriesURL) { data, error in
			guard let data = data else {
				completion(nil, error)
				return
			}

			DispatchQueue.global(qos: .default).async {
				let dataHash = data.sha1Hash()
				if dataHash == self.lastTimeSeriesDataHash {
					print("Nothing new")
					completion(nil, FetchError.noNewData)
					return
				}

				print("Download success")
				self.lastTimeSeriesDataHash = dataHash

				self.parseTimeSerieses(data: data, completion: completion)
			}
		}
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

	private func requestAPI(url: URL, completion: @escaping (Data?, Error?) -> Void) {
		var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
		request.setValue(url.host, forHTTPHeaderField: "referer")
		_ = URLSession.shared.dataTask(with: request) { (data, response, _) in
			guard let response = response as? HTTPURLResponse,
				response.statusCode == 200,
				let data = data else {

					print("Failed API call")
					completion(nil, FetchError.downloadError)
					return
			}

			completion(data, nil)
		}.resume()
	}
}

// swiftlint:disable identifier_name
// MARK: - Decodable entities. DON'T change property names
// MARK: - Global Report API

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
	let Lat: Double?
	let Long_: Double?
	let Confirmed: Int?
	let Deaths: Int?
	let Recovered: Int?

	var region: Region {
		let location = Coordinate(latitude: Lat ?? 0, longitude: Long_ ?? 0)
		let lastUpdate = Date(timeIntervalSince1970: Double(Last_Update) / 1_000)
		let stat = Statistic(confirmedCount: Confirmed ?? 0, recoveredCount: Recovered ?? 0, deathCount: Deaths ?? 0)
		let report = Report(lastUpdate: lastUpdate, stat: stat)

		var region: Region
		if let name = Province_State {
			region = Region(level: .province, name: name, parentName: Country_Region, location: location)
		} else {
			region = Region(level: .country, name: Country_Region, parentName: nil, location: location)
		}
		region.report = report

		return region
	}
}

// MARK: - Global Time Series API

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
	let Report_Date: Int
	let Report_Date_String: String
	let Total_Confirmed: Int?
	let Total_Recovered: Int?
	let Delta_Confirmed: Int?
	let Delta_Recovered: Int?

	var date: Date {
		Date(timeIntervalSince1970: Double(Report_Date) / 1_000)
	}
	var stat: Statistic {
		Statistic(confirmedCount: Total_Confirmed ?? 0, recoveredCount: Total_Recovered ?? 0, deathCount: 0)
	}
}

// MARK: - US Recovered API

private struct USRecoveredCallResult: Decodable {
	let features: [USRecoveredFeature]

	var value: Int? { features.first?.attributes.value }
}

private struct USRecoveredFeature: Decodable {
	let attributes: USRecoveredAttributes
}

private struct USRecoveredAttributes: Decodable {
	let value: Int?
}
