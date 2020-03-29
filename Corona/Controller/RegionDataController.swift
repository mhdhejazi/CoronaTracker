//
//  RegionDataController.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class RegionDataController: UITableViewController {
	private typealias Row = (type: RegionDataCell.Type, height: CGFloat)
	private let rows: [Row] = [
		(type: StatsCell.self, height: 150),
		(type: CurrentChartCell.self, height: 250),
		(type: DeltaChartCell.self, height: 275),
		(type: HistoryChartCell.self, height: 300),
		(type: TopChartCell.self, height: 300),
		(type: TrendlineChartCell.self, height: 350),
		(type: UpdateTimeCell.self, height: 40),
		(type: DataSourceCell.self, height: 50)
	]

	var region: Region? {
		didSet {
			if region == nil {
				region = DataManager.instance.world
			}
		}
	}
	private var container: RegionPanelController? { parent as? RegionPanelController }

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .clear
		tableView.tableFooterView = UIView()
	}

	override func didMove(toParent parent: UIViewController?) {
		super.didMove(toParent: parent)

		updateParent()
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		container?.setEditing(editing, animated: animated)
	}

	func update() {
		if region == nil {
			region = DataManager.instance.world
		}

		/// Update row heights ti show/hide some rows
		tableView.beginUpdates()
		tableView.endUpdates()

		for cell in tableView.visibleCells {
			(cell as? RegionDataCell)?.region = region
		}

		updateParent()
	}

	func updateParent() {
		container?.update(region: region)
	}

	private func shareImage(for cell: RegionDataCell?) {
		guard let cell = cell, let shareable = cell.shareable else { return }

		let cellImage = cell.snapshot()
		let headerImage = container!.snapshotHeader(hideTitle: shareable == .chartTop || shareable == .chartTrendline)
		var logoImage = Asset.iconSmall.image
		if #available(iOS 13.0, *) {
			logoImage = logoImage.withTintColor(SystemColor.secondaryLabel)
		}

		let newSize = CGSize(width: cellImage.size.width, height: cellImage.size.height + headerImage.size.height)
		let newBounds = CGRect(origin: .zero, size: newSize)
		let image = UIGraphicsImageRenderer(bounds: newBounds).image { rendererContext in
			SystemColor.secondarySystemBackground.setFill()
			rendererContext.fill(newBounds)

			headerImage.draw(at: .zero)
			logoImage.draw(at: .init(x: headerImage.size.width - 60, y: 22))
			cellImage.draw(at: .init(x: 0, y: headerImage.size.height))
		}

		var items: [Any] = [ImageItemSource(image: image, imageName: "Corona Tracker")]
		items.append(TextItemSource(text: shareable.title))

		let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)

		if UIDevice.current.userInterfaceIdiom == .pad {
			activityController.modalPresentationStyle = .popover
			activityController.popoverPresentationController?.sourceView = cell
			activityController.popoverPresentationController?.sourceRect = cell.bounds
		}
		present(activityController, animated: true, completion: nil)
	}
}

extension RegionDataController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		rows.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellType = rows[indexPath.row].type
		let cell = tableView.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath)
		if let cell = cell as? RegionDataCell {
			cell.region = region
			cell.shareAction = {
				self.setEditing(false, animated: true)
				self.shareImage(for: cell)
			}
		}
		return cell
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let row = rows[indexPath.row]

		if row.type == DeltaChartCell.self || row.type == HistoryChartCell.self {
			if region?.timeSeries == nil {
				return 0
			}
		}

		return row.height
	}

	override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		false
	}

	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		.none
	}

	@available(iOS 11.0, *)
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let cell = tableView.cellForRow(at: indexPath) as? RegionDataCell
		let action = UIContextualAction(style: .normal, title: nil) { action, sourceView, completion in
			completion(true)
			self.shareImage(for: cell)
		}
		action.image = Asset.shareCircle.image
		action.backgroundColor = UIColor.black.withAlphaComponent(0.001)

		let config = UISwipeActionsConfiguration(actions: [action])
		return config
	}
}
