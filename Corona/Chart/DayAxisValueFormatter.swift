//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/5/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

import Charts

class DayAxisValueFormatter: NSObject, IAxisValueFormatter {
	weak var chartView: BarLineChartViewBase?

	private lazy var formatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.timeZone = .utc
		return formatter
	}()

	init(chartView: BarLineChartViewBase) {
		self.chartView = chartView
	}

	public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		let date = Date.fromReferenceDays(days: Int(value))

		if let chartView = chartView, chartView.visibleXRange > 30 * 6 {
			formatter.dateFormat = "MMM yyyy"
		} else {
			formatter.dateFormat = "MMM dd"
		}

		return formatter.string(from: date)
	}
}
