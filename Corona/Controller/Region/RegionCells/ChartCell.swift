//
//  Corona Tracker
//  Created by Mhd Hejazi on 4/8/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class ChartDataCell<C: RegionChartView>: RegionDataCell {
	lazy var chartView = C()

	@available(iOS 13.0, *)
	override var contextMenuActions: [UIMenuElement] {
		var actions = chartView.contextMenuActions
		actions.append(contentsOf: super.contextMenuActions)
		return actions
	}

	override var shareAction: (() -> Void)? {
		didSet {
			chartView.shareAction = shareAction
		}
	}

	override var shareableImage: UIImage? {
		var image: UIImage?
		chartView.prepareForShare {
			image = self.snapshot()
		}
		return image
	}

	override var shareableText: String? {
		chartView.shareableText
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		contentView.addSubview(chartView)
		chartView.snapEdgesToSuperview()
		chartView.interactive = false

		contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:))))
	}

	override func update(animated: Bool) {
		chartView.update(region: region, animated: animated)
	}

	// MARK: - Actions

	@objc
	func cellTapped(_ sender: Any) {
		guard let chartController = App.topViewController.storyboard?.instantiateViewController(
			withIdentifier: String(describing: ChartController.self)) as? ChartController else { return }

		chartController.sourceChartView = chartView

		App.topViewController.present(chartController, animated: true)
	}
}

class CurrentChartCell: ChartDataCell<CurrentChartView> {
}

class DeltaChartCell: ChartDataCell<DeltaChartView> {
}

class HistoryChartCell: ChartDataCell<HistoryChartView> {
}

class TopChartCell: ChartDataCell<TopChartView> {
}

class TrendlineChartCell: ChartDataCell<TrendlineChartView> {
}
