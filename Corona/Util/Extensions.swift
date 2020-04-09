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
		return CLLocation(latitude: latitude, longitude: longitude)
	}

	public func distance(from coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
		return location.distance(from: coordinate.location)
	}
}

extension Locale {
	public static let posix = Locale(identifier: "en_US_POSIX")

	static func isoCode(from englishCountryName: String) -> String? {
		if let pair = YAMLFiles.isoCountryNames
			.compactMapValues({ $0 as? [String] })
			.first(where: { $0.value.contains(englishCountryName) }) {
			return pair.key
		}

		return Locale.isoRegionCodes.first { code in
			code == englishCountryName || posix.localizedString(forRegionCode: code) == englishCountryName
		}
	}

	static func translateCountryName(_ englishCountryName: String) -> String? {
		guard let code = isoCode(from: englishCountryName) else { return englishCountryName }
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
}

extension Int {
	public var kmFormatted: String {
		Double(self).kmFormatted
	}

	public var groupingFormatted: String {
		NumberFormatter.groupingFormatter.string(from: NSNumber(value: self))!
	}

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
	func md5Hash() -> String? {
		guard let data = self.data(using: .utf8) else { return nil }
		return data.sha1Hash()
	}
}

extension Data {
	func sha1Hash() -> String {
		let length = Int(CC_SHA1_DIGEST_LENGTH)
		var digest = [UInt8](repeating: 0, count: length)

		_ = self.withUnsafeBytes { body in
			CC_SHA1(body.baseAddress, CC_LONG(self.count), &digest)
		}

		return (0..<length).reduce("") {
			$0 + String(format: "%02x", digest[$1])
		}
	}
}

extension Bundle {
	var name: String? { infoDictionary?["CFBundleName"] as? String }

	var version: String? { infoDictionary?["CFBundleVersion"] as? String }
}
