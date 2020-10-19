//
//  LocalStatsSmallWidgetView.swift
//  LocalStatsWidgetExtension
//
//  Created by Andrei Ciobanu on 18/10/2020.
//  Copyright © 2020 Samabox. All rights reserved.
//

import SwiftUI
import WidgetKit

struct LocalStatsSmallWidgetView: View {

	// MARK: - Instance Properties -

	var widgetData: LocalStatsWidgetData

	// MARK: - Initializer(s) -

	init(data: LocalStatsWidgetData) {
		self.widgetData = data
	}

	init(entry: SimpleEntry) {
		self.widgetData = LocalStatsWidgetData(region: entry.region)
	}

	// MARK: - Body -

	var body: some View {
		ZStack {
			VStack(spacing: 0) {
				HStack(spacing: 0) {
					StatsView(displayTitle: false, type: .confirmed, region: widgetData.region)
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.background(Color.orange)
					StatsView(displayTitle: false, type: .active, region: widgetData.region)
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.background(Color.yellow)
				}
				HStack(spacing: 0) {
					StatsView(displayTitle: false, type: .recovered, region: widgetData.region)
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.background(Color.green)
					StatsView(displayTitle: false, type: .deaths, region: widgetData.region)
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.background(Color.red)
				}
			}
			.foregroundColor(.black)
			.lineLimit(1)
			.minimumScaleFactor(0.5)
			.cornerRadius(12)
			HStack {
				Image("Icon-Small")
					.resizable()
					.frame(width: 16.0, height: 16.0)
				Text(widgetData.region.isoCode ?? "WORLD")
					.font(.system(.body, design: .monospaced))
					.bold()
					.textCase(.uppercase)
					.foregroundColor(Color(UIColor.label))
			}
			.padding(6)
			.background(Color(UIColor.systemBackground))
			.cornerRadius(12)
		}
	}
}

// MARK: - PREVIEWS -

struct LocalStatsSmallWidgetView_Previews: PreviewProvider {
	static var previews: some View {
		let widgetData = LocalStatsWidgetData(region: .mockRegion)
		LocalStatsSmallWidgetView(data: widgetData)
			.previewContext(WidgetPreviewContext(family: .systemSmall))
			.colorScheme(.dark)
	}
}
