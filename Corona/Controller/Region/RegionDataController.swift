//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class RegionDataController: UITableViewController {
	private typealias Row = (type: RegionDataCell.Type, height: CGFloat)
	private let allRows: [Row] = [
		(type: StatsCell.self, height: 135),
		(type: CurrentChartCell.self, height: 250),
		(type: DeltaChartCell.self, height: 275),
		(type: HistoryChartCell.self, height: 300),
		(type: TopChartCell.self, height: 300),
		(type: TrendlineChartCell.self, height: 350),
		(type: UpdateTimeCell.self, height: 40),
		(type: DataSourceCell.self, height: 40),
		(type: AuthorInfoCell.self, height: 40)
	]
	private var currentRows: [Row] = []

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

		if region?.timeSeries == nil {
			currentRows = allRows.filter { $0.type != DeltaChartCell.self && $0.type != HistoryChartCell.self }
		} else {
			currentRows = allRows
		}
		tableView.reloadData()

		updateParent()
	}

	func updateParent() {
		container?.update(region: region)
	}

	private func createShareImage(for cell: RegionDataCell?) -> UIImage? {
		guard let cell = cell,
			let shareableImage = cell.shareableImage else { return nil }

		let cellImage = shareableImage
		let hideTitle = cell is TopChartCell && region?.isWorld != true
		let headerImage = container!.snapshotHeader(hideTitle: hideTitle)
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

		return image
	}

	private func shareImage(for cell: RegionDataCell?) {
		guard let cell = cell,
			let image = createShareImage(for: cell) else { return }

		ShareManager.instance.share(image: image, text: cell.shareableText, sourceView: cell)
	}

	private func copyImage(for cell: RegionDataCell?) {
		guard let image = createShareImage(for: cell) else { return }

		UIPasteboard.general.image = image
	}
}

extension RegionDataController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		currentRows.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellType = currentRows[indexPath.row].type
		let cell = tableView.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath)
		if let cell = cell as? RegionDataCell {
			cell.region = region
			cell.shareAction = {
				self.setEditing(false, animated: true)
				self.shareImage(for: cell)
			}
			cell.copyAction = {
				self.copyImage(for: cell)
			}
		}
		return cell
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		currentRows[indexPath.row].height
	}

	override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		false
	}

	override func tableView(_ tableView: UITableView,
							editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		.none
	}

	@available(iOS 11.0, *)
	override func tableView(_ tableView: UITableView,
							trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

		let cell = tableView.cellForRow(at: indexPath) as? RegionDataCell
		let action = UIContextualAction(style: .normal, title: nil) { _, _, completion in
			completion(true)
			self.shareImage(for: cell)
		}
		action.image = Asset.shareCircle.image
		action.backgroundColor = UIColor.black.withAlphaComponent(0.001)

		let config = UISwipeActionsConfiguration(actions: [action])
		return config
	}
}
