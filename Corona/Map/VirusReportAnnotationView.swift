//
//  VirusReportAnnotationView.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

class VirusReportAnnotationView: MKAnnotationView {
    private var countLabel: UILabel!

	private var radius: CGFloat {
		guard let annotation = annotation as? VirusReportAnnotation else { return 1 }
		let number = CGFloat(annotation.virusReport.data.confirmedCount)
		return 10 + log( 1 + number) * CGFloat(mapZoomLevel - 2.2)
	}

	private var color: UIColor {
		guard let annotation = annotation as? VirusReportAnnotation else { return .clear }
		let number = CGFloat(annotation.virusReport.data.confirmedCount)
		let level = log10(number + 10) * 2
		let brightness = max(0, 255 - level * 40) / 255;
		let saturation = brightness > 0 ? 1 : max(0, 255 - ((level * 40) - 255)) / 255;
		return UIColor(red: saturation, green: brightness, blue: brightness, alpha: 0.8)
	}

	var virusReport: VirusReport? {
		(annotation as? VirusReportAnnotation)?.virusReport
	}

	private var detailsString: NSAttributedString? {
		let descriptor = UIFontDescriptor
			.preferredFontDescriptor(withTextStyle: .subheadline)
			.withSymbolicTraits(.traitBold)
		let boldFont = UIFont(descriptor: descriptor!, size: 0)

		let string = NSMutableAttributedString()
		string.append(NSAttributedString(string: "Confirmed: "))
		string.append(NSAttributedString(string: virusReport?.data.confirmedCountString ?? "",
			attributes: [.foregroundColor: UIColor.systemOrange, .font: boldFont]))

		string.append(NSAttributedString(string: "\nRecovered: "))
		string.append(NSAttributedString(string: virusReport?.data.recoveredCountString ?? "",
			attributes: [.foregroundColor : UIColor.systemGreen, .font: boldFont]))

		string.append(NSAttributedString(string: "\nDeath: "))
		string.append(NSAttributedString(string: virusReport?.data.deathCountString ?? "",
			attributes: [.foregroundColor : UIColor.systemRed, .font: boldFont]))

		return string
	}

	var mapZoomLevel: CGFloat = 1 {
		didSet {
			configure()
		}
	}

    override var annotation: MKAnnotation? {
        didSet {
            configure()
        }
    }

	private lazy var rightAccessoryView: UIView? = UIButton(type: .detailDisclosure)
	override var rightCalloutAccessoryView: UIView? { get { rightAccessoryView } set {} }

	private lazy var detailAccessoryView: UIView? = {
		let label = UILabel()
		label.textColor = .gray
		label.font = UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .subheadline), size: 0)
		label.attributedText = detailsString
		label.numberOfLines = 10
		return label
	}()
	override var detailCalloutAccessoryView: UIView? { get { detailAccessoryView } set {} }

	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

		canShowCallout = true

		layer.borderColor = UIColor.white.cgColor
		layer.borderWidth = 3
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowRadius = 2
		layer.shadowOpacity = 0.25
		layer.shadowOffset = .zero

		countLabel = UILabel()
		countLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		countLabel.backgroundColor = .clear
		countLabel.font = .boldSystemFont(ofSize: 13)
		countLabel.textColor = .white
		countLabel.textAlignment = .center
		countLabel.adjustsFontSizeToFitWidth = true
		countLabel.minimumScaleFactor = 0.5
		countLabel.baselineAdjustment = .alignCenters
		self.addSubview(countLabel)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    func configure() {
		guard let virusReport = virusReport else { return }
		if self.mapZoomLevel > 4 {
			self.countLabel.text = virusReport.data.confirmedCountString
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

	var isTouched: Bool = false {
		didSet {
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
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)

		isTouched = true
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)

		isTouched = false
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)

		isTouched = false
	}

}
