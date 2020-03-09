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
	public typealias Block = (_ entry: ChartDataEntry, _ highlight: Highlight) -> String

    private var xValueFormatter: IAxisValueFormatter?
	private var yValueFormatter: IAxisValueFormatter?
	private var block: Block?

	private var unhighlightTask: DispatchWorkItem?

	var timeout: TimeInterval = 2 /// Seconds

    public init(chartView: ChartViewBase, block: Block? = nil) {
		if block == nil {
			self.xValueFormatter = chartView is PieChartView ? nil : xValueFormatter
			self.yValueFormatter = DefaultAxisValueFormatter(formatter: NumberFormatter.groupingFormatter)
		} else {
			self.block = block
		}

        super.init(color: UIColor.darkGray.withAlphaComponent(0.9),
				   font: .boldSystemFont(ofSize: 13),
				   textColor: .white,
				   insets: UIEdgeInsets(top: 8, left: 10, bottom: 23, right: 10))

		self.chartView = chartView
		self.arrowSize = CGSize(width: 15, height: 15)
		self.minimumSize = CGSize(width: 80, height: 40)
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
		var result: String
		if let block = block {
			result = block(entry, highlight)
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
		unhighlightTask?.cancel()
		let task = DispatchWorkItem {
			self.chartView?.highlightValues(nil)
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: task)
		unhighlightTask = task
    }
    
}
