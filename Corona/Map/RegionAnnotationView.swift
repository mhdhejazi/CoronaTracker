//
//  RegionAnnotationView.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

class RegionAnnotationView: MKAnnotationView {
	static let reuseIdentifier = String(describing: RegionAnnotationView.self)

	private lazy var countLabel: UILabel = {
		let countLabel = UILabel()
		countLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		countLabel.backgroundColor = .clear
		countLabel.font = .boldSystemFont(ofSize: 13)
		countLabel.textColor = .white
		countLabel.textAlignment = .center
		countLabel.adjustsFontSizeToFitWidth = true
		countLabel.minimumScaleFactor = 0.5
		countLabel.baselineAdjustment = .alignCenters
		self.addSubview(countLabel)
		return countLabel
	}()

	private var radius: CGFloat {
		guard let annotation = annotation as? RegionAnnotation else { return 1 }
		let number = CGFloat(annotation.region.report?.stat.confirmedCount ?? 0)
		return 10 + log( 1 + number) * CGFloat(mapZoomLevel - 2.2)
	}

	private var color: UIColor {
		guard let annotation = annotation as? RegionAnnotation else { return .clear }
		let number = CGFloat(annotation.region.report?.stat.confirmedCount ?? 0)
		let level = log10(number + 10) * 2
		let brightness = max(0, 255 - level * 40) / 255;
		let saturation = brightness > 0 ? 1 : max(0, 255 - ((level * 40) - 255)) / 255;
		return UIColor(red: saturation, green: brightness, blue: brightness * 0.4, alpha: 0.8)
	}

	var region: Region? {
		(annotation as? RegionAnnotation)?.region
	}

	private var detailsString: NSAttributedString? {
		let descriptor = UIFontDescriptor
			.preferredFontDescriptor(withTextStyle: .footnote)
			.withSymbolicTraits(.traitBold)
		let boldFont = UIFont(descriptor: descriptor!, size: 0)

		let string = NSMutableAttributedString()
		string.append(.init(string: "Confirmed: "))
		string.append(.init(string: region?.report?.stat.confirmedCountString ?? "",
			attributes: [.foregroundColor: UIColor.systemOrange, .font: boldFont]))

		string.append(.init(string: "\nRecovered: "))
		string.append(.init(string: region?.report?.stat.recoveredCountString ?? "",
			attributes: [.foregroundColor : UIColor.systemGreen, .font: boldFont]))

		string.append(.init(string: "\nDeath: "))
		string.append(.init(string: region?.report?.stat.deathCountString ?? "",
			attributes: [.foregroundColor : UIColor.systemRed, .font: boldFont]))

		return string
	}

	var mapZoomLevel: CGFloat = 1 {
		didSet {
			if mapZoomLevel.rounded() == oldValue.rounded() {
				return
			}

			configure()
		}
	}

	override var annotation: MKAnnotation? {
		didSet {
			configure()
		}
	}

	private lazy var rightAccessoryView: UIView? = {
		let button = UIButton(type: .detailDisclosure)
		button.addAction {
			MapController.instance.updateRegionScreen(region: self.region)
			MapController.instance.showRegionScreen()
		}
		return button
	}()
	override var rightCalloutAccessoryView: UIView? { get { rightAccessoryView } set {} }

	private lazy var detailAccessoryView: UIView? = {
		let label = UILabel()
		label.textColor = .systemGray
		label.font = UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .footnote), size: 0)
		label.attributedText = detailsString
		label.numberOfLines = 10
		return label
	}()
	override var detailCalloutAccessoryView: UIView? { get { detailAccessoryView } set {} }

	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

		canShowCallout = true

		layer.borderColor = UIColor.white.cgColor
		layer.borderWidth = 2
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure() {
		guard let region = region else { return }
		if self.mapZoomLevel > 4 {
			self.countLabel.text = region.report?.stat.confirmedCountString
			self.countLabel.font = .boldSystemFont(ofSize: 13 * max(1, log(self.mapZoomLevel - 2)))
			self.countLabel.alpha = 1
		}
		else {
			self.countLabel.alpha = 0
		}

		let diameter = self.radius * 2
		self.frame.size = CGSize(width: diameter, height: diameter)

		self.backgroundColor = self.color
		self.layer.cornerRadius = self.frame.width / 2
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		countLabel.frame = bounds
	}
}

extension RegionAnnotationView { // Pressable view
	private func setTouched(_ isTouched: Bool) {
		let scale = 0.9 + 0.06 * max(1, self.frame.width / 400)
		let transform = isTouched ? CGAffineTransform(scaleX: scale, y: scale) : .identity
		UIView.animate(withDuration: 0.4,
					   delay: 0.1,
					   usingSpringWithDamping: 0.7,
					   initialSpringVelocity: 1,
					   options: .allowUserInteraction,
					   animations: {
			self.transform = transform
		})
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)

		setTouched(true)
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)

		setTouched(false)
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)

		setTouched(false)
	}
}
