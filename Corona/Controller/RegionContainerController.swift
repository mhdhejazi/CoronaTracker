//
//  RegionContainerController.swift
//  Corona
//
//  Created by Mohammad on 3/5/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class RegionContainerController: UIViewController {
	var regionController: RegionController!
	var isUpdating: Bool = false {
		didSet {
			updateTime()
		}
	}

	@IBOutlet var effectViewBackground: UIVisualEffectView!
	@IBOutlet var effectViewHeader: UIVisualEffectView!
	@IBOutlet var labelTitle: UILabel!
	@IBOutlet var labelUpdated: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		if #available(iOS 13.0, *) {
			effectViewBackground.effect = UIBlurEffect(style: .systemMaterial)
			effectViewBackground.contentView.alpha = 0

			effectViewHeader.effect = UIBlurEffect(style: .systemMaterial)
		}

		if #available(iOS 11.0, *) {
			/// Do nothing
		} else {
			/// iOS 10
			labelTitle.font = .boldSystemFont(ofSize: 24)
		}

		Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { _ in
			self.updateTime()
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is RegionController {
			regionController = segue.destination as? RegionController
		}
	}

	func update(report: Report?) {
		UIView.transition(with: view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
			self.labelTitle.text = report?.region.name ?? "No data"
		}, completion: nil)

		updateTime()
	}

	func updateTime() {
		if isUpdating {
			self.labelUpdated.text = "Updating..."
			return
		}

		self.labelUpdated.text = self.regionController.report?.lastUpdate.relativeTimeString
	}
}
