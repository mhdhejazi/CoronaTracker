//
//  MenuController.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/18/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class MenuController: UITableViewController {
	let items: [MenuItem]
	var width: CGFloat

	init(items: [MenuItem], width: CGFloat = 200) {
		self.items = items
		self.width = width

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
		tableView.separatorColor = SystemColor.tertiaryLabel
		tableView.separatorInset = .zero
		tableView.rowHeight = 44

		tableView.separatorEffect = UIBlurEffect()
		preferredContentSize = CGSize(width: width,
									  height: tableView.rowHeight * CGFloat(items.count) - 1)
    }

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		items.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let item = items[indexPath.row]
		let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
		cell.backgroundColor = .clear
		cell.textLabel?.text = item.title
		cell.textLabel?.font = .preferredFont(forTextStyle: .callout)
		if item.selected {
			cell.accessoryType = .checkmark
			cell.tintColor = SystemColor.secondaryLabel
		} else {
			cell.accessoryView = UIImageView(image: item.image)
			cell.accessoryView?.tintColor = SystemColor.secondaryLabel
		}

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let item = items[indexPath.row]
		item.action()
	}
}

