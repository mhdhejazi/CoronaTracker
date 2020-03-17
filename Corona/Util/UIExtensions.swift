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
						  options: [.transitionCrossDissolve, .allowUserInteraction],
						  animations: animations,
						  completion: nil)
	}
}

extension UIViewController {
	private static let hudTag = "UIAlertController#hud".hashValue

	func showHUD(message: String, completion: (() -> Void)? = nil) {
		hideHUD(animated: false) {
			let alertController = UIAlertController(title: "\n\(message)\n\n", message: nil, preferredStyle: .alert)
			alertController.view.tag = Self.hudTag
			self.present(alertController, animated: true, completion: completion)
		}
	}

	func hideHUD(animated: Bool = true, afterDelay delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
		guard let alertController = self.presentedViewController as? UIAlertController,
			alertController.view.tag == Self.hudTag else {
				completion?()
				return
		}

		if delay == 0 {
			alertController.dismiss(animated: animated, completion: completion)
			return
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
			alertController.dismiss(animated: animated, completion: completion)
		}
	}

	func showMessage(title: String?, message: String?) {
		hideHUD(animated: false) {
			let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
			alertController.addAction(.init(title: "OK", style: .default))
			self.present(alertController, animated: true)
		}
	}
}
