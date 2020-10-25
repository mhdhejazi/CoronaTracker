//
//  LocalStatsWidget.swift
//  LocalStatsWidget
//
//  Created by Andrei Ciobanu on 18/10/2020.
//  Copyright © 2020 Samabox. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

// MARK: - PROVIDER (LIFECYCLE) -

struct Provider: IntentTimelineProvider {
	func placeholder(in context: Context) -> SimpleEntry {
		SimpleEntry(date: Date(), region: .mockRegion)
	}

	func getSnapshot(
		for configuration: ConfigurationIntent,
		in context: Context,
		completion: @escaping (SimpleEntry) -> Void
	) {
		DataManager.shared.fetchWidgetsData(completion: { _ in
			let selectedRegion = region(for: configuration)
			let entry = SimpleEntry(date: Date(), region: selectedRegion)
			completion(entry)
		})
	}

	func getTimeline(
		for configuration: ConfigurationIntent,
		in context: Context,
		completion: @escaping (Timeline<Entry>) -> Void
	) {
		DataManager.shared.fetchWidgetsData(completion: { _ in
			let currentDate = Date()
			let nextRefreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
			let selectedRegion = region(for: configuration)
			let timelineEntry = SimpleEntry(date: currentDate, region: selectedRegion)
			let timeline = Timeline(entries: [timelineEntry], policy: .after(nextRefreshDate))

			completion(timeline)
		})
	}

	func region(for configuration: ConfigurationIntent) -> Region {
		let countryIsoCode = configuration.location?.iso3CountryCode
		let dataManager = DataManager.shared

		guard
			let countryCode = countryIsoCode,
			let countryRegion = dataManager.world.subRegions.first(where: { $0.isoCode == countryCode })
		else {
			return dataManager.world
		}

		return countryRegion
	}
}

// MARK: - ENTRY -

struct SimpleEntry: TimelineEntry {
	let date: Date
	let region: Region
}

// MARK: - PLACEHOLDER -

struct LocalStatsWidgetPlaceholderView: View {
	@Environment(\.widgetFamily) var family
	var entry: Provider.Entry

	var body: some View {
		switch family {
		case .systemSmall:
			LocalStatsSmallWidgetView(entry: entry)
				.redacted(reason: .placeholder)
		default:
			LocalStatsMediumWidgetView(entry: entry)
				.redacted(reason: .placeholder)
		}
	}
}

// MARK: - ACTUAL VIEW -

struct LocalStatsWidgetEntryView: View {
	@Environment(\.widgetFamily) var family
	var entry: Provider.Entry

	var body: some View {
		switch family {
		case .systemSmall:
			LocalStatsSmallWidgetView(entry: entry)
				.widgetURL(entry.region.deepLinkUrl)
		default:
			LocalStatsMediumWidgetView(entry: entry)
				.widgetURL(entry.region.deepLinkUrl)
		}
	}
}

// MARK: - DEFINITION -

@main
struct LocalStatsWidget: Widget {
	let kind: String = "LocalStatsWidget"

	var body: some WidgetConfiguration {
		IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
			LocalStatsWidgetEntryView(entry: entry)
		}
		.configurationDisplayName("Cases by country")
		.description("See the number of cases in a country at a quick glance.")
		.supportedFamilies([.systemMedium, .systemSmall])
	}
}

// MARK: - PREVIEWS -

struct LocalStatsWidget_Previews: PreviewProvider {
	static var previews: some View {
		let placeholderEntry = SimpleEntry(date: Date(), region: .mockRegion)

		// Widgets
		Group {
			LocalStatsWidgetEntryView(entry: placeholderEntry)
				.previewContext(WidgetPreviewContext(family: .systemMedium))
			LocalStatsWidgetEntryView(entry: placeholderEntry)
				.previewContext(WidgetPreviewContext(family: .systemSmall))
		}

		// Placeholders
		Group {
			LocalStatsWidgetPlaceholderView(entry: placeholderEntry)
				.previewContext(WidgetPreviewContext(family: .systemSmall))
			LocalStatsWidgetPlaceholderView(entry: placeholderEntry)
				.previewContext(WidgetPreviewContext(family: .systemMedium))
		}
	}
}
