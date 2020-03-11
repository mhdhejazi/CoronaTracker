//
//  Extensions.swift
//  Corona
//
//  Created by Mohammad on 3/3/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

extension MKMapView {
	var zoomLevel: CGFloat {
		let maxZoom: CGFloat = 20
		let zoomScale = self.visibleMapRect.size.width / Double(self.frame.size.width)
		let zoomExponent = log2(zoomScale)
		return maxZoom - CGFloat(zoomExponent)
	}
}

extension CLLocationCoordinate2D {
	var location: CLLocation {
		return CLLocation(latitude: latitude, longitude: longitude)
	}

	func distance(from coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
		return location.distance(from: coordinate.location)
	}
}

extension UIControl {
	func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping () -> ()) {
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
	func transition(duration: TimeInterval = 0.5, animations: @escaping (() -> Void)) {
		UIView.transition(with: self,
						  duration: duration,
						  options: [.transitionCrossDissolve],
						  animations: animations,
						  completion: nil)
	}
}

extension Locale {
	static let posix = Locale(identifier: "en_US_POSIX")
}

extension Calendar {
	static let posix: Calendar = {
		var calendar = Calendar(identifier: .gregorian)
		calendar.locale = .posix
		return calendar
	}()
}

extension Date {
	static let reference = Calendar.posix.date(from: DateComponents(year: 2000))!

	static func fromReferenceDays(days: Int) -> Date {
		Calendar.posix.date(byAdding: .day, value: days, to: Date.reference)!
	}

	var referenceDays: Int {
		Calendar.posix.dateComponents([.day], from: Date.reference, to: self).day!
	}

	var ageDays: Int {
		Calendar.posix.dateComponents([.day], from: self, to: Date()).day!
	}

	var yesterday: Date {
		Calendar.posix.date(byAdding: .day, value: -1, to: self)!
	}

	var relativeTimeString: String {
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
}

extension Double {
	var kmFormatted: String {
		if self >= 10_000, self < 1_000_000 {
			return String(format: "%.1fk", locale: .posix, self / 1_000).replacingOccurrences(of: ".0", with: "")
		}

		if self >= 1_000_000 {
			return String(format: "%.1fm", locale: .posix, self / 1_000_000).replacingOccurrences(of: ".0", with: "")
		}

		return NumberFormatter.groupingFormatter.string(from: NSNumber(value: self))!
	}

	var percentFormatted: String {
		NumberFormatter.percentFormatter.string(from: NSNumber(value: self))!
	}
}

extension Int {
	var kmFormatted: String { Double(self).kmFormatted }
}

extension NumberFormatter {
	static let groupingFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.usesGroupingSeparator = true
		formatter.groupingSize = 3
		formatter.maximumFractionDigits = 1
		return formatter
	}()

	static let percentFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .percent
		formatter.maximumFractionDigits = 1
		formatter.multiplier = 1
		return formatter
	}()
}
