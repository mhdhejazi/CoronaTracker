//
//  StatsView.swift
//  LocalStatsWidgetExtension
//
//  Created by Andrei Ciobanu on 18/10/2020.
//  Copyright © 2020 Samabox. All rights reserved.
//

import SwiftUI
import WidgetKit

enum StatsViewType: String {
	case confirmed
	case active
	case recovered
	case deaths

	var color: Color {
		switch self {
		case .confirmed: return .orange
		case .active: return .yellow
		case .recovered: return .green
		case .deaths: return .red
		}
	}

	func value(for region: Region) -> Int? {
		switch self {
		case .confirmed: return region.report?.stat.confirmedCount
		case .active: return region.report?.stat.activeCount
		case .recovered: return region.report?.stat.recoveredCount
		case .deaths: return region.report?.stat.deathCount
		}
	}

	func delta(for region: Region) -> String? {
		switch self {
		case .confirmed: return region.dailyChange?.newConfirmedString
		case .active: return nil
		case .recovered: return region.dailyChange?.newRecoveredString
		case .deaths: return region.dailyChange?.newDeathsString
		}
	}
}

struct StatsView: View {

	// MARK: - Instance Properties -

	let displayTitle: Bool
	let type: StatsViewType
	let region: Region

	// MARK: - Body -

	@ViewBuilder
	var body: some View {
		VStack {
			if displayTitle, let titleValue = type.rawValue {
				Text(titleValue)
					.padding(.bottom, 0.5)
					.textCase(.uppercase)
					.font(.system(size: 14))
					.lineLimit(1)
					.minimumScaleFactor(0.5)
			}
			if let countValue = type.value(for: region) {
				Text("\(countValue)")
					.bold()
					.font(.callout)
					.lineLimit(1)
					.minimumScaleFactor(0.5)
			}
			if let deltaValue = type.delta(for: region) {
				Text(deltaValue)
					.bold()
					.font(.callout)
					.lineLimit(1)
					.minimumScaleFactor(0.5)
			}
		}
		.padding(8)
		.background(type.color)
		.cornerRadius(8)
	}
}

// MARK: - PREVIEWS -

struct MediumStatsView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			let region: Region = .mockRegion
			StatsView(displayTitle: false, type: .confirmed, region: region)
			StatsView(displayTitle: false, type: .active, region: region)
			StatsView(displayTitle: false, type: .recovered, region: region)
			StatsView(displayTitle: false, type: .deaths, region: region)
		}
		.previewContext(WidgetPreviewContext(family: .systemSmall))
		.colorScheme(.light)
	}
}
