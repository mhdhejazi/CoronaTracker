//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/5/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

import Charts

class PercentValueFormatter: DefaultValueFormatter {
	let minPercent: Double

	init(minPercent: Double = 8) {
		self.minPercent = minPercent

		super.init(formatter: .percentFormatter)
	}

	override func stringForValue(_ value: Double,
								 entry: ChartDataEntry,
								 dataSetIndex: Int,
								 viewPortHandler: ViewPortHandler?) -> String {
		if value < minPercent {
			return ""
		}

		return super.stringForValue(value, entry: entry, dataSetIndex: dataSetIndex, viewPortHandler: viewPortHandler)
	}
}
