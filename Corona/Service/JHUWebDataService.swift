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
	private static var germanyReportsURL: URL = URL(string: "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/Coronaf%C3%A4lle_in_den_Bundesl%C3%A4ndern/FeatureServer/0/query?f=json&where=1%3D1&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=Fallzahl%20desc&resultOffset=0&resultRecordCount=25&cacheHint=true")!

	private static let globalTimeSeriesURL = URL(string: "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/cases_time_v3/FeatureServer/0/query?f=json&where=1%3D1&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=Report_Date_String%20asc&outSR=102100&resultOffset=0&resultRecordCount=2000&cacheHint=true")!

	private static let usRecoveredCasesURL = URL(string: "https://services9.arcgis.com/N9p5hsImWXAccRNI/arcgis/rest/services/Nc2JKvYFoAEOFCG5JSI6/FeatureServer/1/query?f=json&where=Country_Region%3D%27US%27&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&outStatistics=%5B%7B%22statisticType%22%3A%22sum%22%2C%22onStatisticField%22%3A%22Recovered%22%2C%22outStatisticFieldName%22%3A%22value%22%7D%5D&outSR=102100&cacheHint=true")!
	// swiftlint:enable line_length

	static let shared = JHUWebDataService()

	private var lastReportsDataHash: String?
	private var lastTimeSeriesDataHash: String?

	public func fetchGermanReports(completion: @escaping FetchResultBlock) {
		fetchReports(reportsURL: Self.germanyReportsURL, completion: completion)
	}

	public func fetchReports(completion: @escaping FetchResultBlock) {
		fetchReports(reportsURL: Self.reportsURL, completion: completion)
	}

	private func fetchReports(reportsURL: URL, completion: @escaping FetchResultBlock) {
		print("Calling API")
		requestAPI(url: reportsURL) { data, error in
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

				self.parseReports(reportsURL: reportsURL, data: data) { result, error in
					/// Update recovered cases for US
					if reportsURL == Self.germanyReportsURL {
						completion(result, error)
					} else {
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
	}

	private func parseReports(reportsURL: URL, data: Data, completion: @escaping FetchResultBlock) {
		do {
			let decoder = JSONDecoder()
			var regions = [Region]()
			switch reportsURL {
			case Self.germanyReportsURL:
				let result = try decoder.decode(ReportsCallResultGermany.self, from: data)
				regions = result.features.map { $0.attributes.region() }
			default:
				let result = try decoder.decode(ReportsCallResult.self, from: data)
				regions = result.features.map { $0.attributes.region() }
			}
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
			debugPrint("Unexpected error:", error)
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

private protocol ReportAttributesProtocol: Decodable {
	func region() -> Region
}

private struct ReportAttributes: ReportAttributesProtocol {
	let Province_State: String?
	let Country_Region: String
	let Last_Update: Int
	let Lat: Double?
	let Long_: Double?
	let Confirmed: Int?
	let Deaths: Int?
	let Recovered: Int?

	func region() -> Region {
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

private struct ReportsCallResultGermany: Decodable {
	let features: [ReportFeatureGermany]
}

private struct ReportFeatureGermany: Decodable {
	let attributes: ReportAttributesGermany
}

private struct ReportAttributesGermany: ReportAttributesProtocol {
	let Province_State: String
	let Last_Update: Int
	let Confirmed: Int?
	let Deaths: Int?
	let objectID: Int

	private enum CodingKeys: String, CodingKey {
		case objectID = "OBJECTID_1"
		case Province_State = "LAN_ew_GEN"
		case Last_Update = "Aktualisierung"
		case Confirmed = "Fallzahl"
		case Deaths = "Death"
	}

	/// Using the objectID field makes more sense than Province_State
	/// but the later could be used with a .filter if needed
	let coordinates: [Coordinate] = { [
		/// Got them from https://www.latlong.net
		/// I prefer to store them hard coded instead of using Core Location for this
		//  1. Schleswig-Holstein		( Kiel )
		Coordinate(latitude: 54.323, longitude: 10.122),
		//  2. Hamburg					( Hamburg )
		Coordinate(latitude: 53.551, longitude: 9.993),
		//  3. Niedersachsen			( Hannover )
		Coordinate(latitude: 52.375, longitude: 9.732),
		//  4. Bremen					( Bremen )
		Coordinate(latitude: 53.079, longitude: 8.801),
		//  5. Nordrhein-Westfalen		( Düsseldorf )
		Coordinate(latitude: 51.227, longitude: 6.773),
		/// In case anyone wonders why I take Kassel instead of Wiesbaden
		/// - Both are very close to each other on a Map, so I decided to keep Mainz
		/// - Also, the center of Germany is very empty which is why I chose Kassel
		//  6. Hessen					( Kassel instead of Wiesbaden )
		Coordinate(latitude: 51.318, longitude: 9.494), // Wiesbaden would be latitude: 50.078, longitude: 8.239
		//  7. Rheinland-Pfalz			( Mainz )
		Coordinate(latitude: 49.992, longitude: 8.247),
		//  8. Baden-Württemberg		( Stuttgart )
		Coordinate(latitude: 48.775, longitude: 9.182),
		//  9. Bayern					( München )
		Coordinate(latitude: 48.135, longitude: 11.581),
		// 10. Saarland					( Saarbrücken )
		Coordinate(latitude: 49.234, longitude: 6.994),
		// 11. Berlin					( Berlin )
		Coordinate(latitude: 52.520, longitude: 13.404),
		// 12. Brandenburg				( Potsdam )
		Coordinate(latitude: 52.396, longitude: 13.058),
		// 13. Mecklenburg-Vorpommern   ( Schwerin )
		Coordinate(latitude: 53.635, longitude: 11.401),
		// 14. Sachsen					( Dresden )
		Coordinate(latitude: 51.050, longitude: 13.737),
		// 15. Sachsen-Anhalt			( Magdeburg )
		Coordinate(latitude: 52.131, longitude: 11.640),
		// 16. Thüringen				( Erfurt )
		Coordinate(latitude: 50.984, longitude: 11.029)
		] }()

	func region() -> Region {
		let lastUpdate = Date(timeIntervalSince1970: Double(Last_Update) / 1_000)
		let stat = Statistic(confirmedCount: Confirmed ?? 0, recoveredCount: 0, deathCount: Deaths ?? 0)
		let report = Report(lastUpdate: lastUpdate, stat: stat)

		let region = Region(level: .province, name: Province_State, parentName: "Germany",
							location: coordinates[objectID - 1])
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
