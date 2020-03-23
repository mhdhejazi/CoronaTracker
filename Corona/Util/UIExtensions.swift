//
//  Extensions.swift
//  Corona
//
//  Created by Mohammad on 3/3/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

extension MKMapView {
	public static let maxZoom: CGFloat = 20
	public var zoomLevel: CGFloat {
		let zoomScale = self.visibleMapRect.size.width / Double(self.frame.size.width)
		let zoomExponent = log2(zoomScale)
		return Self.maxZoom - CGFloat(zoomExponent)
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
	public func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping () -> Void) {
		let sleeve = ClosureSleeve(closure)
		addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
		objc_setAssociatedObject(self, "[\(arc4random())]", sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
	}
}

/// WARNING: This solution causes memory leaks
@objc class ClosureSleeve: NSObject {
	let closure: () -> Void

	init (_ closure: @escaping () -> Void) {
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

	public func snapshot() -> UIImage {
		UIGraphicsImageRenderer(bounds: bounds).image { layer.render(in: $0.cgContext) }
	}

	public func snapEdgesToSuperview() {
		snapEdges(to: superview!)
	}

	public func snapEdges(to view: UIView) {
		translatesAutoresizingMaskIntoConstraints = false
		leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	}

	public func enableShadow(
    radius: CGFloat = 3,
    opacity: Float = 0.2,
    color: UIColor = .black,
    offset: CGSize = .zero) {
		layer.shadowRadius = radius
		layer.shadowOpacity = opacity
		layer.shadowColor = color.cgColor
		layer.shadowOffset = offset
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
			alertController.addAction(.init(title: L10n.Message.ok, style: .default))
			self.present(alertController, animated: true)
		}
	}
}

extension UIImage {
	enum ImageType: String {
		case jpeg = "jpg"
		case png = "png"
	}

	func saveToFile(fileName: String = "image", imageType: ImageType = .jpeg) -> URL? {
		guard let directoryURL = FileManager.cachesDirectoryURL else { return nil }

		let imageURL = directoryURL.appendingPathComponent("\(fileName).\(imageType.rawValue)")
		print(imageURL)

		var data: Data?

		switch imageType {
		case .jpeg:
			data = self.jpegData(compressionQuality: 1)
		case .png:
			data = self.pngData()
		}

		guard let imageData = data else { return nil }

		do {
			try imageData.write(to: imageURL)
		} catch {
			return nil
		}

		return imageURL
	}

	func scaledToAspectFit(size: CGSize) -> UIImage {
		let imageSize = self.size
		let imageAspectRatio = imageSize.width / imageSize.height
		let canvasAspectRatio = size.width / size.height

		var resizeFactor: CGFloat

		if imageAspectRatio > canvasAspectRatio {
			resizeFactor = size.width / imageSize.width
		} else {
			resizeFactor = size.height / imageSize.height
		}

		if resizeFactor > 1 {
			return self
		}

		let scaledSize = CGSize(width: imageSize.width * resizeFactor, height: imageSize.height * resizeFactor)

		UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0)
		draw(in: CGRect(origin: .zero, size: scaledSize))

		let scaledImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
		UIGraphicsEndImageContext()

		return scaledImage
	}
}
