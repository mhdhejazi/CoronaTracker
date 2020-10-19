//
//  LocalStatsMediumWidgetView.swift
//  Corona Tracker
//
//  Created by Andrei Ciobanu on 18/10/2020.
//  Copyright © 2020 Samabox. All rights reserved.
//

import SwiftUI
import WidgetKit

struct LocalStatsMediumWidgetView: View {

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
		VStack(alignment: .center, spacing: 8) {
			HStack(spacing: 8) {
				Image("Icon-Small")
					.resizable()
					.frame(width: 18.0, height: 18.0)
				Text(widgetData.region.localizedName)
					.textCase(.uppercase)
					.font(.system(.title3))
				Spacer()
				Text("\(widgetData.lastUpdate)")
					.font(.system(.callout))
					.foregroundColor(.secondary)
			}
			HStack {
				StatsView(displayTitle: true, type: .confirmed, region: widgetData.region)
				StatsView(displayTitle: true, type: .recovered, region: widgetData.region)
				StatsView(displayTitle: true, type: .deaths, region: widgetData.region)
			}
		}
		.padding()
	}
}

// MARK: - PREVIEWS -

struct LocalStatsMediumWidgetView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			let widgetData = LocalStatsWidgetData(
				region: Region(level: .country, name: "Romania", parentName: nil, location: .zero)
			)
			LocalStatsMediumWidgetView(data: widgetData)
				.previewContext(WidgetPreviewContext(family: .systemMedium))
		}
	}
}
