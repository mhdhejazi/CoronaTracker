//
//  VirusData.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

class VirusData {
	private lazy var numberFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.usesGroupingSeparator = true
		formatter.groupingSize = 3
		return formatter
	}()

	let confirmedCount: Int
	let recoveredCount: Int
	let deathCount: Int
	var existingCount: Int { confirmedCount - recoveredCount - deathCount }

	var recoveredPercent: Double { 100.0 * Double(recoveredCount) / Double(confirmedCount) }
	var deathPercent: Double { 100.0 * Double(deathCount) / Double(confirmedCount) }
	var existingPercent: Double { 100.0 * Double(existingCount) / Double(confirmedCount) }

	var confirmedCountString: String { numberFormatter.string(from: NSNumber(value: confirmedCount))! }
	var recoveredCountString: String { numberFormatter.string(from: NSNumber(value: recoveredCount))! }
	var deathCountString: String { numberFormatter.string(from: NSNumber(value: deathCount))! }

	init(confirmedCount: Int, recoveredCount: Int, deathCount: Int) {
		self.confirmedCount = confirmedCount
		self.recoveredCount = recoveredCount
		self.deathCount = deathCount
	}

	init(subData: [VirusData]) {
		self.confirmedCount = subData.reduce(0) { $0 + $1.confirmedCount }
		self.recoveredCount = subData.reduce(0) { $0 + $1.recoveredCount }
		self.deathCount = subData.reduce(0) { $0 + $1.deathCount }
	}
}
