//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/3/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation
import CommonCrypto
import MapKit

extension CLLocationCoordinate2D {
	public var location: CLLocation {
		CLLocation(latitude: latitude, longitude: longitude)
	}

	public func distance(from coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
		location.distance(from: coordinate.location)
	}
}

extension CLPlacemark {
	var iso3CountryCode: String? { Locale.iso3Code(for: isoCountryCode ?? "") }
}

extension Locale {
	public static let posix = Locale(identifier: "en_US_POSIX")

	// swiftlint:disable:next line_length
	private static let iso2ToISO3: [String: String] = ["AF": "AFG", "AX": "ALA", "AL": "ALB", "DZ": "DZA", "AS": "ASM", "AD": "AND", "AO": "AGO", "AI": "AIA", "AQ": "ATA", "AG": "ATG", "AR": "ARG", "AM": "ARM", "AW": "ABW", "AU": "AUS", "AT": "AUT", "AZ": "AZE", "BS": "BHS", "BH": "BHR", "BD": "BGD", "BB": "BRB", "BY": "BLR", "BE": "BEL", "BZ": "BLZ", "BJ": "BEN", "BM": "BMU", "BT": "BTN", "BO": "BOL", "BQ": "BES", "BA": "BIH", "BW": "BWA", "BV": "BVT", "BR": "BRA", "IO": "IOT", "BN": "BRN", "BG": "BGR", "BF": "BFA", "BI": "BDI", "CV": "CPV", "KH": "KHM", "CM": "CMR", "CA": "CAN", "KY": "CYM", "CF": "CAF", "TD": "TCD", "CL": "CHL", "CN": "CHN", "CX": "CXR", "CC": "CCK", "CO": "COL", "KM": "COM", "CG": "COG", "CD": "COD", "CK": "COK", "CR": "CRI", "CI": "CIV", "HR": "HRV", "CU": "CUB", "CW": "CUW", "CY": "CYP", "CZ": "CZE", "DK": "DNK", "DJ": "DJI", "DM": "DMA", "DO": "DOM", "EC": "ECU", "EG": "EGY", "SV": "SLV", "GQ": "GNQ", "ER": "ERI", "EE": "EST", "SZ": "SWZ", "ET": "ETH", "FK": "FLK", "FO": "FRO", "FJ": "FJI", "FI": "FIN", "FR": "FRA", "GF": "GUF", "PF": "PYF", "TF": "ATF", "GA": "GAB", "GM": "GMB", "GE": "GEO", "DE": "DEU", "GH": "GHA", "GI": "GIB", "GR": "GRC", "GL": "GRL", "GD": "GRD", "GP": "GLP", "GU": "GUM", "GT": "GTM", "GG": "GGY", "GN": "GIN", "GW": "GNB", "GY": "GUY", "HT": "HTI", "HM": "HMD", "VA": "VAT", "HN": "HND", "HK": "HKG", "HU": "HUN", "IS": "ISL", "IN": "IND", "ID": "IDN", "IR": "IRN", "IQ": "IRQ", "IE": "IRL", "IM": "IMN", "IL": "ISR", "IT": "ITA", "JM": "JAM", "JP": "JPN", "JE": "JEY", "JO": "JOR", "KZ": "KAZ", "KE": "KEN", "KI": "KIR", "KP": "PRK", "KR": "KOR", "KW": "KWT", "KG": "KGZ", "LA": "LAO", "LV": "LVA", "LB": "LBN", "LS": "LSO", "LR": "LBR", "LY": "LBY", "LI": "LIE", "LT": "LTU", "LU": "LUX", "MO": "MAC", "MK": "MKD", "MG": "MDG", "MW": "MWI", "MY": "MYS", "MV": "MDV", "ML": "MLI", "MT": "MLT", "MH": "MHL", "MQ": "MTQ", "MR": "MRT", "MU": "MUS", "YT": "MYT", "MX": "MEX", "FM": "FSM", "MD": "MDA", "MC": "MCO", "MN": "MNG", "ME": "MNE", "MS": "MSR", "MA": "MAR", "MZ": "MOZ", "MM": "MMR", "NA": "NAM", "NR": "NRU", "NP": "NPL", "NL": "NLD", "NC": "NCL", "NZ": "NZL", "NI": "NIC", "NE": "NER", "NG": "NGA", "NU": "NIU", "NF": "NFK", "MP": "MNP", "NO": "NOR", "OM": "OMN", "PK": "PAK", "PW": "PLW", "PS": "PSE", "PA": "PAN", "PG": "PNG", "PY": "PRY", "PE": "PER", "PH": "PHL", "PN": "PCN", "PL": "POL", "PT": "PRT", "PR": "PRI", "QA": "QAT", "RE": "REU", "RO": "ROU", "RU": "RUS", "RW": "RWA", "BL": "BLM", "SH": "SHN", "KN": "KNA", "LC": "LCA", "MF": "MAF", "PM": "SPM", "VC": "VCT", "WS": "WSM", "SM": "SMR", "ST": "STP", "SA": "SAU", "SN": "SEN", "RS": "SRB", "SC": "SYC", "SL": "SLE", "SG": "SGP", "SX": "SXM", "SK": "SVK", "SI": "SVN", "SB": "SLB", "SO": "SOM", "ZA": "ZAF", "GS": "SGS", "SS": "SSD", "ES": "ESP", "LK": "LKA", "SD": "SDN", "SR": "SUR", "SJ": "SJM", "SE": "SWE", "CH": "CHE", "SY": "SYR", "TW": "TWN", "TJ": "TJK", "TZ": "TZA", "TH": "THA", "TL": "TLS", "TG": "TGO", "TK": "TKL", "TO": "TON", "TT": "TTO", "TN": "TUN", "TR": "TUR", "TM": "TKM", "TC": "TCA", "TV": "TUV", "UG": "UGA", "UA": "UKR", "AE": "ARE", "GB": "GBR", "US": "USA", "UM": "UMI", "UY": "URY", "UZ": "UZB", "VU": "VUT", "VE": "VEN", "VN": "VNM", "VG": "VGB", "VI": "VIR", "WF": "WLF", "EH": "ESH", "YE": "YEM", "ZM": "ZMB", "ZW": "ZWE"]

	static func iso3Code(for iso2Code: String) -> String? {
		iso2ToISO3[iso2Code]
	}

	static func isoCode(for englishCountryName: String) -> String? {
		if let pair = YAMLFiles.isoCountryNames
			.compactMapValues({ $0 as? [String] })
			.first(where: { $0.value.contains(englishCountryName) }) {
			return iso2ToISO3[pair.key]
		}

		if let regionCode = Locale.isoRegionCodes.first(where: { code in
			code == englishCountryName || posix.localizedString(forRegionCode: code) == englishCountryName
		}) {
			return iso2ToISO3[regionCode]
		}

		return nil
	}

	static func translateCountryName(_ englishCountryName: String) -> String? {
		guard let code = isoCode(for: englishCountryName) else { return englishCountryName }
		return Locale.current.localizedString(forRegionCode: code)
	}

	var isEnglish: Bool { languageCode == "en" }
}

extension Calendar {
	public static let posix: Calendar = {
		var calendar = Calendar(identifier: .gregorian)
		calendar.locale = .posix
		calendar.timeZone = .utc
		return calendar
	}()
}

extension Date {
	public static let reference = Calendar.posix.date(from: DateComponents(year: 2_000))!

	public static func fromReferenceDays(days: Int) -> Date {
		Calendar.posix.date(byAdding: .day, value: days, to: Date.reference)!
	}

	public var referenceDays: Int {
		Calendar.posix.dateComponents([.day], from: Date.reference, to: self).day!
	}

	public var ageDays: Int {
		Calendar.posix.dateComponents([.day], from: self, to: Date()).day!
	}

	public var yesterday: Date {
		Calendar.posix.date(byAdding: .day, value: -1, to: self)!
	}

	public var relativeTimeString: String {
		if #available(iOS 13.0, *) {
			let formatter = RelativeDateTimeFormatter()
			formatter.unitsStyle = .short
			return formatter.localizedString(for: self, relativeTo: Date())
		}

		let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: Date())

		var interval: Int
		var unit: String
		if let value = components.year, value > 0 {
			interval = value
			unit = "year"
		} else if let value = components.month, value > 0 {
			interval = value
			unit = "month"
		} else if let value = components.day, value > 0 {
			interval = value
			unit = "day"
		} else if let value = components.hour, value > 0 {
			interval = value
			unit = "hour"
		} else if let value = components.minute, value > 0 {
			interval = value
			unit = "minute"
		} else {
			return "moments ago"
		}

		return "\(interval) \(unit + (interval > 1 ? "s" : "")) ago"
	}

	public var relativeDateString: String {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		formatter.doesRelativeDateFormatting = true
		return formatter.string(from: self)
	}
}

extension TimeZone {
	public static let utc = TimeZone(identifier: "UTC")!
}

extension Double {
	public var kmFormatted: String {
		if self >= 1_000, self < 1_000_000 {
			return NumberFormatter.groupingFormatter.string(from: NSNumber(value: self / 1_000))! + "k"
		}

		if self >= 1_000_000 {
			return NumberFormatter.groupingFormatter.string(from: NSNumber(value: self / 1_000_000))! + "m"
		}

		return NumberFormatter.groupingFormatter.string(from: NSNumber(value: self))!
	}

	public var percentFormatted: String {
		NumberFormatter.percentFormatter.string(from: NSNumber(value: self))!
	}

	public var radians: Double { self * Double.pi / 180 }
}

extension Int {
	public var kmFormatted: String {
		Double(self).kmFormatted
	}

	public var groupingFormatted: String {
		NumberFormatter.groupingFormatter.string(from: NSNumber(value: self))!
	}

	public var radians: Double { Double(self).radians }

	public static func random() -> Int { random(in: 1..<max) }
}

extension NumberFormatter {
	public static let groupingFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.usesGroupingSeparator = true
		formatter.groupingSize = 3
		formatter.maximumFractionDigits = 1
		return formatter
	}()

	public static let percentFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .percent
		formatter.maximumFractionDigits = 1
		formatter.multiplier = 1
		return formatter
	}()
}

extension FileManager {
	static let cachesDirectoryURL: URL? = {
		try? FileManager.default.url(for: .cachesDirectory,
									 in: .userDomainMask,
									 appropriateFor: nil,
									 create: true)
	}()
}

extension String {
	func sha1Hash() -> String? {
		guard let data = self.data(using: .utf8) else { return nil }
		return data.sha1Hash()
	}
}

extension Data {
	func sha1Hash() -> String {
		var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
		_ = withUnsafeBytes { CC_SHA1($0.baseAddress, CC_LONG(self.count), &digest) }
		return digest.map { String(format: "%02x", $0) }.joined()
	}
}

extension Bundle {
	var name: String? { infoDictionary?["CFBundleName"] as? String }

	var version: String? { infoDictionary?["CFBundleVersion"] as? String }
}

extension Collection {
	func sum(_ transform: (Self.Element) throws -> Int) rethrows -> Int {
		try reduce(0) { $0 + (try transform($1)) }
	}

	func sum(_ transform: (Self.Element) throws -> CGFloat) rethrows -> CGFloat {
		try reduce(0) { $0 + (try transform($1)) }
	}
}

extension URL {
	public var queryParameters: [String: String]? {
		guard
			let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
			let queryItems = components.queryItems else { return nil }
		return queryItems.reduce(into: [String: String]()) { (result, item) in
			result[item.name] = item.value
		}
	}
}
