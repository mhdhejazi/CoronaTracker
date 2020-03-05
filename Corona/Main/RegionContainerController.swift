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

	@IBOutlet var effectView: UIVisualEffectView!
	@IBOutlet var labelTitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

		if #available(iOS 13.0, *) {
			effectView.effect = UIBlurEffect(style: .systemMaterial)
			effectView.contentView.alpha = 0
		}
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is RegionController {
			regionController = segue.destination as? RegionController
		}
    }

	func update(report: VirusReport?) {
		UIView.transition(with: view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
			self.labelTitle.text = report?.region.name ?? "No data"
		}, completion: nil)
	}
}
