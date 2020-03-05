//
//  DayAxisValueFormatter.swift
//  Corona
//
//  Created by Mohammad on 3/5/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

import Charts

class DayAxisValueFormatter: NSObject, IAxisValueFormatter {
	weak var chart: BarLineChartViewBase?
	let months = ["Jan", "Feb", "Mar",
				  "Apr", "May", "Jun",
				  "Jul", "Aug", "Sep",
				  "Oct", "Nov", "Dec"]

	init(chart: BarLineChartViewBase) {
		self.chart = chart
	}

	public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		let date = Date.fromReferenceDays(days: Int(value))
		let year = Calendar.posix.component(.year, from: date)
		let month = Calendar.posix.component(.month, from: date)

		let monthName = months[month - 1]
		let yearName = "\(year)"

		if let chart = chart,
			chart.visibleXRange > 30 * 6 {
			return monthName + yearName
		} else {
			let dayOfMonth = Calendar.posix.component(.day, from: date)
			return String(format: "\(monthName) %d", dayOfMonth)
		}
	}
}
