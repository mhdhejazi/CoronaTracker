//
//  Corona Tracker
//  Created by Mhd Hejazi on 4/8/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

protocol RegionChartView: UIView {
	@available(iOS 13.0, *)
	var contextMenuActions: [UIMenuElement] { get }

	var shareableText: String? { get }

	var shareAction: (() -> Void)? { get set }

	var interactive: Bool { get set }

	var mode: Statistic.Kind { get set }

	var extraMenuItems: [MenuItem] { get }

	var region: Region? { get set }

	init(fontScale: CGFloat)

	func updateOptions(from chartView: RegionChartView)

	func update(region: Region?, animated: Bool)

	func prepareForShare(shareCallback: () -> Void)
}
