//
//  Extensions.swift
//  Corona
//
//  Created by Mohammad on 3/3/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

extension MKMapView {
	public var zoomLevel: CGFloat {
		let maxZoom: CGFloat = 20
		let zoomScale = self.visibleMapRect.size.width / Double(self.frame.size.width)
		let zoomExponent = log2(zoomScale)
		return maxZoom - CGFloat(zoomExponent)
	}
}

extension CLLocationCoordinate2D {
	public var location: CLLocation {
		return CLLocation(latitude: latitude, longitude: longitude)
	}

	public func distance(from coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
		return location.distance(from: coordinate.location)
	}
}

extension UIControl {
	public func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping () -> ()) {
		let sleeve = ClosureSleeve(closure)
		addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
		objc_setAssociatedObject(self, "[\(arc4random())]", sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
	}
}

/// WARNING: This solution causes memory leaks
@objc class ClosureSleeve: NSObject {
	let closure: () -> ()

	init (_ closure: @escaping () -> ()) {
		self.closure = closure
	}

	@objc func invoke() {
		closure()
	}
}

extension UIView {
	public func transition(duration: TimeInterval = 0.5, animations: @escaping (() -> Void)) {
		UIView.transition(with: self,
						  duration: duration,
						  options: [.transitionCrossDissolve],
						  animations: animations,
						  completion: nil)
	}
}

extension Locale {
	public static let posix = Locale(identifier: "en_US_POSIX")
}

extension Calendar {
	public static let posix: Calendar = {
		var calendar = Calendar(identifier: .gregorian)
		calendar.locale = .posix
		return calendar
	}()
}

extension Date {
	public static let reference = Calendar.posix.date(from: DateComponents(year: 2000))!

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
		if let value = components.year, value > 0  {
			interval = value
			unit = "year"
		}
		else if let value = components.month, value > 0  {
			interval = value
			unit = "month"
		}
		else if let value = components.day, value > 0  {
			interval = value
			unit = "day"
		}
		else if let value = components.hour, value > 0  {
			interval = value
			unit = "hour"
		}
		else if let value = components.minute, value > 0  {
			interval = value
			unit = "minute"
		}
		else {
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

extension Double {
	public var kmFormatted: String {
		if self >= 10_000, self < 1_000_000 {
			return String(format: "%.1fk", locale: .posix, self / 1_000).replacingOccurrences(of: ".0", with: "")
		}

		if self >= 1_000_000 {
			return String(format: "%.1fm", locale: .posix, self / 1_000_000).replacingOccurrences(of: ".0", with: "")
		}

		return NumberFormatter.groupingFormatter.string(from: NSNumber(value: self))!
	}

	public var percentFormatted: String {
		NumberFormatter.percentFormatter.string(from: NSNumber(value: self))!
	}
}

extension Int {
	public var kmFormatted: String { Double(self).kmFormatted }
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
