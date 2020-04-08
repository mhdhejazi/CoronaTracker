//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/5/20.
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
				   insets: UIEdgeInsets(top: 8, left: 20, bottom: 19, right: 20))

		self.chartView = chartView
		self.minimumSize = CGSize(width: 80, height: 40)
		self.roundCorners = true
	}

	public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
		var result: String
		if let contentCallback = contentCallback {
			result = contentCallback(entry, highlight)
		} else {
			result = ""
			if let xValueFormatter = xValueFormatter {
				let value = xValueFormatter.stringForValue(entry.x, axis: nil)
				result += "\(value): "
			}
			if let yValueFormatter = yValueFormatter {
				let value = yValueFormatter.stringForValue(entry.y, axis: nil)
				result += "\(value)"
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
