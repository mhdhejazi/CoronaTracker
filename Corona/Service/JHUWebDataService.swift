//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/10/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

public class JHUWebDataService: BaseDataService, DataService {
	// swiftlint:disable line_length
	private static let reportsURL = URL(string: "https://services9.arcgis.com/N9p5hsImWXAccRNI/arcgis/rest/services/Nc2JKvYFoAEOFCG5JSI6/FeatureServer/2/query?f=json&where=1%3D1&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=Confirmed%20desc&resultOffset=0&resultRecordCount=500&resultType=standard&cacheHint=true")!

	private static let globalTimeSeriesURL = URL(string: "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/cases_time_v3/FeatureServer/0/query?f=json&where=1%3D1&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=Report_Date_String%20asc&outSR=102100&resultOffset=0&resultRecordCount=2000&cacheHint=true")!

	private static let usRecoveredCasesURL = URL(string: "https://services9.arcgis.com/N9p5hsImWXAccRNI/arcgis/rest/services/Nc2JKvYFoAEOFCG5JSI6/FeatureServer/1/query?f=json&where=Country_Region%3D%27US%27&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&outStatistics=%5B%7B%22statisticType%22%3A%22sum%22%2C%22onStatisticField%22%3A%22Recovered%22%2C%22outStatisticFieldName%22%3A%22value%22%7D%5D&outSR=102100&cacheHint=true")!
	// swiftlint:enable line_length

	static let shared = JHUWebDataService()

	public func fetchReports(completion: @escaping FetchResultBlock) {
		fetchData(from: Self.reportsURL, addRandomParameter: true) { data, error in
			guard let data = data else {
				completion(nil, error)
				return
			}

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

	private func parseReports(data: Data, completion: @escaping FetchResultBlock) {
		do {
			let decoder = JSONDecoder()
			let result = try decoder.decode(ReportsCallResult.self, from: data)
			let regions = result.features.map { $0.attributes.region }
			completion(regions, nil)
		} catch {
			debugPrint("Unexpected error:", error)
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
			debugPrint("Unexpected error:", error)
			return nil
		}
	}

	public func fetchTimeSerieses(completion: @escaping FetchResultBlock) {
		fetchData(from: Self.globalTimeSeriesURL) { data, error in
			guard let data = data else {
				completion(nil, error)
				return
			}

			self.parseTimeSerieses(data: data, completion: completion)
		}
	}

	private func parseTimeSerieses(data: Data, completion: @escaping FetchResultBlock) {
		do {
			let decoder = JSONDecoder()
			let result = try decoder.decode(GlobalTimeSeriesCallResult.self, from: data)
			let region = result.region
			completion([region], nil)
		} catch {
			debugPrint("Unexpected error:", error)
			completion(nil, error)
		}
	}
}

// MARK: - Global Report API

private struct ReportsCallResult: Decodable {
	let features: [ReportFeature]
}

private struct ReportFeature: Decodable {
	let attributes: ReportAttributes
}

private struct ReportAttributes: Decodable {
	private enum CodingKeys: String, CodingKey {
		case province = "Province_State"
		case country = "Country_Region"
		case isoCode = "ISO3"
		case lastUpdateTimestamp = "Last_Update"
		case latitude = "Lat"
		case longitude = "Long_"
		case confirmed = "Confirmed"
		case deaths = "Deaths"
		case recovered = "Recovered"
	}

	let province: String?
	let country: String
	let isoCode: String?
	let lastUpdateTimestamp: Int
	let latitude: Double?
	let longitude: Double?
	let confirmed: Int?
	let deaths: Int?
	let recovered: Int?

	var region: Region {
		let location = Coordinate(latitude: latitude ?? 0, longitude: longitude ?? 0)
		let lastUpdate = Date(timeIntervalSince1970: Double(lastUpdateTimestamp) / 1_000)
		let stat = Statistic(confirmedCount: confirmed ?? 0, recoveredCount: recovered ?? 0, deathCount: deaths ?? 0)
		let report = Report(lastUpdate: lastUpdate, stat: stat)

		var region: Region
		if let name = province {
			region = Region(level: .province, name: name, parentName: country, location: location)
		} else {
			region = Region(level: .country, name: country, parentName: nil, location: location, isoCode: isoCode)
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
				features.map { $0.attributes.date },
				features.map { $0.attributes.stat }
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
	private enum CodingKeys: String, CodingKey {
		case reportTimestamp = "Report_Date"
		case confirmed = "Total_Confirmed"
		case recovered = "Total_Recovered"
	}

	let reportTimestamp: Int
	let confirmed: Int?
	let recovered: Int?

	var date: Date {
		Date(timeIntervalSince1970: Double(reportTimestamp) / 1_000)
	}
	var stat: Statistic {
		Statistic(confirmedCount: confirmed ?? 0, recoveredCount: recovered ?? 0, deathCount: 0)
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
