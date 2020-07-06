//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/10/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

public class RKIDataService: BaseDataService, DataService {
	// swiftlint:disable:next line_length
	private static let reportsURL = URL(string: "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/Coronaf%C3%A4lle_in_den_Bundesl%C3%A4ndern/FeatureServer/0/query?f=json&where=1%3D1&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=Fallzahl%20desc&resultOffset=0&resultRecordCount=25&cacheHint=true")!

	static let shared = RKIDataService()

	public func fetchReports(completion: @escaping FetchResultBlock) {
		fetchData(from: Self.reportsURL, addRandomParameter: true) { data, error in
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
		case objectID = "OBJECTID_1"
		case province = "LAN_ew_GEN"
		case lastUpdateTimestamp = "Aktualisierung"
		case confirmed = "Fallzahl"
		case deaths = "Death"
	}

	let objectID: Int
	let province: String
	let lastUpdateTimestamp: Int
	let confirmed: Int?
	let deaths: Int?

	/// Using the objectID field makes more sense than Province_State
	/// but the later could be used with a .filter if needed
	let coordinates: [Coordinate] = [
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
	]

	var region: Region {
		let lastUpdate = Date(timeIntervalSince1970: Double(lastUpdateTimestamp) / 1_000)
		let stat = Statistic(confirmedCount: confirmed ?? 0, recoveredCount: 0, deathCount: deaths ?? 0)
		let report = Report(lastUpdate: lastUpdate, stat: stat)

		let location = coordinates[objectID - 1]
		let region = Region(level: .province, name: province, parentName: "Germany", location: location)
		region.report = report

		return region
	}
}
