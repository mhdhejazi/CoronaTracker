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
    private var xAxisValueFormatter: IAxisValueFormatter
	private var yAxisFormatter = NumberFormatter.groupingFormatter
    
    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets, xAxisValueFormatter: IAxisValueFormatter) {
        self.xAxisValueFormatter = xAxisValueFormatter

        super.init(color: color, font: font, textColor: textColor, insets: insets)
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
		let x = xAxisValueFormatter.stringForValue(entry.x, axis: XAxis())
		let y = yAxisFormatter.string(from: NSNumber(value: entry.y))!
		let string = "\(x): \(y)"

        setLabel(string)
    }
    
}
