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
    private var xAxisValueFormatter: IAxisValueFormatter?
	private var yAxisFormatter = NumberFormatter.groupingFormatter
	private var unhighlighteTask: DispatchWorkItem?

    public init(chartView: ChartViewBase) {
		self.xAxisValueFormatter = chartView is PieChartView ? nil : xAxisValueFormatter

        super.init(color: UIColor.darkGray.withAlphaComponent(0.75),
				   font: .boldSystemFont(ofSize: 13),
				   textColor: .white,
				   insets: UIEdgeInsets(top: 8, left: 10, bottom: 23, right: 10))

		self.chartView = chartView
		self.arrowSize = CGSize(width: 15, height: 15)
		self.minimumSize = CGSize(width: 80, height: 40)
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
		if let xFormatter = xAxisValueFormatter {
			let x = xFormatter.stringForValue(entry.x, axis: XAxis())
			let y = yAxisFormatter.string(from: NSNumber(value: entry.y))!
			setLabel("\(x): \(y)")
		}
		else {
			let y = yAxisFormatter.string(from: NSNumber(value: entry.y))!
			setLabel("\(y)")
		}

		unhighlighteTask?.cancel()
		let task = DispatchWorkItem {
			self.chartView?.highlightValues(nil)
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: task)
		unhighlighteTask = task
    }
    
}
