//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/18/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class MenuController: UITableViewController {
	let items: [MenuItem]

	init(items: [MenuItem]) {
		self.items = items

		super.init(style: .plain)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.isScrollEnabled = false
		tableView.showsVerticalScrollIndicator = false
		tableView.backgroundColor = .clear
		tableView.separatorStyle = .none
		tableView.rowHeight = 44

		let maxTitleWidth = items.map { $0.calculateTitleWidth(using: ItemCell.font) }.max()

		preferredContentSize = CGSize(width: (maxTitleWidth ?? 0) + 100,
									  height: items.sum { $0.height } - 1)
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		items.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let item = items[indexPath.row]
		let cell: ItemCell

		switch item {
		case .regular(let title, let image, _):
			cell = ItemCell(title: title, image: image)

		case .option(let title, let selected, _):
			cell = ItemCell(title: title, selected: selected)

		case .separator:
			cell = SeparatorCell()
		}

		if indexPath.row < items.count - 1, case .separator = items[indexPath.row + 1] {
			cell.separatorView?.isHidden = true
		}

		return cell
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		items[indexPath.row].height
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let item = items[indexPath.row]
		switch item {
		case .regular(_, _, let action), .option(_, _, let action):
			action()

		case .separator:
			break
		}
	}
}
