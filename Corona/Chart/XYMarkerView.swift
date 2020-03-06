//
//  XYMarkerView.swift
//  Corona
//
//  Created by Mohammad on 3/5/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

public class XYMarkerView: BalloonMarker {
    private var xAxisValueFormatter: IAxisValueFormatter?
	private var yAxisFormatter = NumberFormatter.groupingFormatter
	private var unhighlighteTask: DispatchWorkItem?
    
    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets, xAxisValueFormatter: IAxisValueFormatter? = nil) {
        self.xAxisValueFormatter = xAxisValueFormatter

        super.init(color: color, font: font, textColor: textColor, insets: insets)
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
