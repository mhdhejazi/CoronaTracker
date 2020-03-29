//
//  XYMarkerView.swift
//  Corona
//
//  Created by Mohammad on 3/5/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

public class SimpleMarkerView: BalloonMarker {
	public typealias ContentCallback = (_ entry: ChartDataEntry, _ highlight: Highlight) -> String
	public typealias VisibilityCallback = (_ entry: ChartDataEntry, _ visible: Bool) -> Void

	private var xValueFormatter: IAxisValueFormatter?
	private var yValueFormatter: IAxisValueFormatter?
	private var contentCallback: ContentCallback?
	private var unhighlightTask: DispatchWorkItem?

	public var timeout: TimeInterval = 2 /// Seconds
	public var visibilityCallback: VisibilityCallback?

	public init(chartView: ChartViewBase, contentCallback: ContentCallback? = nil) {
		if contentCallback == nil {
			self.xValueFormatter = chartView is PieChartView ? nil : chartView.xAxis.valueFormatter
			self.yValueFormatter = DefaultAxisValueFormatter(formatter: NumberFormatter.groupingFormatter)
		} else {
			self.contentCallback = contentCallback
		}

		super.init(color: UIColor.darkGray.withAlphaComponent(0.9),
				   font: .systemFont(ofSize: 13),
				   textColor: UIColor.white.withAlphaComponent(0.9),
				   insets: UIEdgeInsets(top: 8, left: 10, bottom: 23, right: 10))

		self.chartView = chartView
		self.arrowSize = CGSize(width: 15, height: 15)
		self.minimumSize = CGSize(width: 80, height: 40)
	}

	public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
		var result: String
		if let contentCallback = contentCallback {
			result = contentCallback(entry, highlight)
		}
		else {
			result = ""
			if let xValueFormatter = xValueFormatter {
				let x = xValueFormatter.stringForValue(entry.x, axis: nil)
				result += "\(x): "
			}
			if let yValueFormatter = yValueFormatter {
				let y = yValueFormatter.stringForValue(entry.y, axis: nil)
				result += "\(y)"
			}
		}
		setLabel(result)

		/// Auto hide the marker after timeout
		visibilityCallback?(entry, true)
		unhighlightTask?.cancel()
		let task = DispatchWorkItem {
			self.chartView?.highlightValues(nil)
			self.visibilityCallback?(entry, false)
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: task)
		unhighlightTask = task
	}
}
