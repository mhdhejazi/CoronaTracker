//
//  EstimationController.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/24/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class EstimationController: UIViewController {
	var region: Region?

	var confirmedCases: Int {
		region?.report?.stat.confirmedCount ?? 0
	}

	var trueCases: Int {
		let daysUntilDeath = 17.3 /// Days
		let doublingTime = 6.18 /// Days
		let mortalityRate = 0.87
		let deaths = Double(region?.report?.stat.deathCount ?? 0)
		let trueCases = pow(2, daysUntilDeath / doublingTime) * (100 / mortalityRate) * deaths
		return Int(floor(trueCases))
	}

	var trueCasesFactor: Int {
		Int(floor(Double(trueCases) / Double(confirmedCases)))
	}

	@IBOutlet var labelConfirmedCount: UILabel!
	@IBOutlet var labelTrueCount: UILabel!
	@IBOutlet var labelFactor: UILabel!

    override func viewDidLoad() {
		super.viewDidLoad()

		labelConfirmedCount.text = confirmedCases.groupingFormatted
		labelTrueCount.text = trueCases.groupingFormatted
		labelFactor.text = "\(trueCasesFactor)x"
	}
	
	@IBAction func buttonDoneTapped(_ sender: Any) {
		dismiss(animated: true)
	}
}
