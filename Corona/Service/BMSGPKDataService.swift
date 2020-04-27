//
//  Corona Tracker
//  Created by Mhd Hejazi on 4/26/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

// Data Source: https://www.data.gv.at/anwendungen/covid-19-dashboard-oesterreich/
// BMSGPK: Bundesministerium für Soziales, Gesundheit, Pflege und Konsumentenschutz

public class BMSGPKDataService: BaseDataService, DataService {
	// swiftlint:disable:next line_length
	private static let reportsURL = URL(string: "https://services1.arcgis.com/YfxQKFk1MjjurGb5/arcgis/rest/services/AUSTRIA_COVID19_Cases/FeatureServer/2/query?f=json&where=1%3D1&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=infizierte%20desc&outSR=102100&resultOffset=0&resultRecordCount=25&resultType=standard&cacheHint=true")!

	static let shared = BMSGPKDataService()

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
			let decoder = JSONDecoder()
			let result = try decoder.decode(ReportsCallResult.self, from: data)
			let regions = result.features.map { $0.attributes.region }
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

private struct ReportsCallResult: Decodable {
	let features: [ReportFeature]
}

private struct ReportFeature: Decodable {
	let attributes: ReportAttributes
}

private struct ReportAttributes: Decodable {
	private enum CodingKeys: String, CodingKey {
		case province = "bundesland"
		case lastUpdateTimestamp = "datum"
		case confirmed = "infizierte"
		case deaths = "verstorbene"
		case recovered = "genesene"
	}

	let province: String
	let lastUpdateTimestamp: Int
	let confirmed: Int?
	let deaths: Int?
	let recovered: Int?

	var coordinate: Coordinate {
		let coordinate: Coordinate

		/// Got them from https://www.latlong.net
		if province == "Tirol" {
			coordinate = Coordinate(latitude: 46.690, longitude: 11.154)
		} else if province == "Niederösterreich" {
			coordinate = Coordinate(latitude: 48.222, longitude: 15.761)
		} else if province == "Wien" {
			coordinate = Coordinate(latitude: 48.208, longitude: 16.374)
		} else if province == "Oberösterreich" {
			coordinate = Coordinate(latitude: 48.117, longitude: 13.870)
		} else if province == "Steiermark" {
			coordinate = Coordinate(latitude: 47.220, longitude: 14.868)
		} else if province == "Salzburg" {
			coordinate = Coordinate(latitude: 47.809, longitude: 13.055)
		} else if province == "Vorarlberg" {
			coordinate = Coordinate(latitude: 47.218, longitude: 9.884)
		} else if province == "Kärnten" {
			coordinate = Coordinate(latitude: 46.722, longitude: 14.181)
		} else if province == "Burgenland" {
			coordinate = Coordinate(latitude: 47.154, longitude: 16.269)
		} else {
			// Fallback to Austria
			coordinate = Coordinate(latitude: 47.516, longitude: 14.550)
		}

		return coordinate
	}

	var region: Region {
		let lastUpdate = Date(timeIntervalSince1970: Double(lastUpdateTimestamp) / 1_000)
		let stat = Statistic(confirmedCount: confirmed ?? 0, recoveredCount: recovered ?? 0, deathCount: deaths ?? 0)
		let report = Report(lastUpdate: lastUpdate, stat: stat)

		let region = Region(level: .province, name: province, parentName: "Austria", location: coordinate)
		region.report = report

		return region
	}
}
