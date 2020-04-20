//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/4/20.
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
		countLabel.textColor = UIColor.white.withAlphaComponent(0.8)
		countLabel.textAlignment = .center
		countLabel.adjustsFontSizeToFitWidth = true
		countLabel.minimumScaleFactor = 0.5
		countLabel.baselineAdjustment = .alignCenters
		self.addSubview(countLabel)
		return countLabel
	}()

	private var radius: CGFloat {
		let value = CGFloat(number ?? 0)
		var radius = log( 1 + value) * CGFloat(mapZoomLevel - 2.2)
		if isProvinceRegion {
			radius *= (mapZoomLevel - 2.2) * 0.25
		}
		return 10 + radius
	}

	private var color: UIColor {
		switch mode {
		case .active: return SystemColor.systemOrange.withAlphaComponent(0.8)
		case .recovered: return SystemColor.systemGreen.withAlphaComponent(0.8)
		case .deaths: return SystemColor.systemRed.withAlphaComponent(0.8)
		default: break
		}

		let value = CGFloat(number ?? 0)
		let level = log10(value + 10) * 2
		let brightness = max(0, 255 - level * 40) / 255
		let saturation = brightness > 0 ? 1 : max(0, 255 - ((level * 40) - 255)) / 255
		return UIColor(red: saturation, green: brightness, blue: brightness * 0.4, alpha: 0.8)
	}

	var region: Region? { (annotation as? RegionAnnotation)?.region }
	var isProvinceRegion: Bool {
		region?.isProvince == true
	}

	var mode: Statistic.Kind { (annotation as? RegionAnnotation)?.mode ?? .confirmed }

	private var number: Int? { region?.report?.stat.number(for: mode) }

	private var detailsString: NSAttributedString? {
		let descriptor = UIFontDescriptor
			.preferredFontDescriptor(withTextStyle: .footnote)
			.withSymbolicTraits(.traitBold)
		let boldFont = UIFont(descriptor: descriptor!, size: 0)

		let string = NSMutableAttributedString()
		string.append(.init(string: region?.report?.stat.confirmedCountString ?? "",
							attributes: [.foregroundColor: UIColor.systemOrange, .font: boldFont]))

		string.append(.init(string: "\n" + (region?.report?.stat.activeCountString ?? ""),
							attributes: [.foregroundColor: UIColor.systemYellow, .font: boldFont]))

		string.append(.init(string: "\n" + (region?.report?.stat.recoveredCountString ?? ""),
							attributes: [.foregroundColor: UIColor.systemGreen, .font: boldFont]))

		string.append(.init(string: "\n" + (region?.report?.stat.deathCountString ?? ""),
							attributes: [.foregroundColor: UIColor.systemRed, .font: boldFont]))

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
	var shouldShowLabel: Bool {
		round(self.mapZoomLevel) > (isProvinceRegion ? 7 : 4)
	}

	override var annotation: MKAnnotation? {
		didSet {
			guard annotation != nil else {
				return
			}

			configure()

			/// Ensure that the report text is set each time the annotation is updated
			detailAccessoryView?.detailsLabel?.attributedText = detailsString

			if #available(iOS 11.0, *) {
				/// Give provinces a low display priority
				/// Give the top 30 countries a required priority
				/// Give the others a high priority
				displayPriority = isProvinceRegion
					? .defaultLow
					: ((region?.order ?? Int.max) < 30 ? .required : .defaultHigh)
			}
		}
	}

	private lazy var rightAccessoryView: UIView? = {
		let button = UIButton(type: .detailDisclosure)
		button.addAction {
			MapController.shared.updateRegionScreen(region: self.region)
			MapController.shared.showRegionScreen()
		}
		return button
	}()

	override var rightCalloutAccessoryView: UIView? {
		get { rightAccessoryView }
		set { _ = newValue }
	}

	private lazy var detailAccessoryView: DetailsView? = { DetailsView() }()

	override var detailCalloutAccessoryView: UIView? {
		get { detailAccessoryView }
		set { _ = newValue }
	}

	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

		canShowCallout = true
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure() {
		if shouldShowLabel {
			self.countLabel.text = number?.groupingFormatted
			let fontSize = 13 * max(1, log(self.mapZoomLevel - 2))
			self.countLabel.font = .boldSystemFont(ofSize: fontSize * (isProvinceRegion ? mapZoomLevel * 0.07 : 1))
			self.countLabel.alpha = 1
		} else {
			self.countLabel.alpha = 0
		}

		let diameter = self.radius * 2 * (isProvinceRegion ? 0.3 : 1)
		self.frame.size = CGSize(width: diameter, height: diameter)

		self.backgroundColor = self.color
		self.layer.cornerRadius = self.frame.height / 2
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
