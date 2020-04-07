//
//  ChartController.swift
//  Corona Tracker
//
//  Created by Mohammad on 4/3/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class ChartController: UIViewController {
	private var chartView: RegionChartView!

	@IBOutlet var labelTitle: UILabel!
	@IBOutlet var labelTime: UILabel!
	@IBOutlet var imageLogo: UIImageView!
	@IBOutlet var chartViewContainer: UIView!

	var sourceChartView: RegionChartView!

	override var keyCommands: [UIKeyCommand]? {
		return [UIKeyCommand(input: UIKeyCommand.inputEscape,
							 modifierFlags: [],
							 action: #selector(doneButtonTapped(_:)))]
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		#if targetEnvironment(macCatalyst)
		self.modalPresentationStyle = .overFullScreen
		self.modalTransitionStyle = .crossDissolve
		#endif
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let fontScale: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 1 : 1.3

		let chartViewType = type(of: sourceChartView) as RegionChartView.Type
		chartView = chartViewType.init(fontScale: fontScale)
		chartViewContainer.addSubview(chartView)
		chartView.snapEdgesToSuperview()
		chartView.interactive = true
		chartView.shareAction = share
		chartView.updateOptions(from: sourceChartView)
		chartView.update(region: sourceChartView.region, animated: true)

		if #available(iOS 11.0, *) {
			labelTitle.font = .preferredFont(forTextStyle: .largeTitle)
		} else {
			labelTitle.font = .boldSystemFont(ofSize: 24)
		}
		labelTitle.text = (chartViewType == TopChartView.self) ? L10n.Region.world : sourceChartView.region?.localizedName
		labelTime.text = sourceChartView.region?.report?.lastUpdate.relativeTimeString
	}

	private func share() {
		var image: UIImage? = nil
		chartView.prepareForShare {
			image = self.view.snapshot()
		}

		let imageBounds = CGRect(origin: .zero, size: image?.size ?? .zero)
		image = UIGraphicsImageRenderer(bounds: imageBounds).image { rendererContext in
			SystemColor.secondarySystemBackground.setFill()
			rendererContext.fill(imageBounds)

			image?.draw(at: .zero)
		}

		ShareManager.instance.share(image: image,
									text: chartView.shareableText,
									sourceView: self.view)
	}

	@IBAction func doneButtonTapped(_ sender: Any) {
		dismiss(animated: true)
	}
}
