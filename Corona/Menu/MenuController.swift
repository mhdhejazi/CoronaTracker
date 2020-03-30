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
		tableView.separatorStyle = .none
		tableView.rowHeight = 44

		preferredContentSize = CGSize(width: width,
									  height: items.reduce(0) { $0 + $1.height } - 1)
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

class ItemCell: UITableViewCell {
	class var separatorHeight: CGFloat { 0.5 }
	var separatorView: UIVisualEffectView?

	init() {
		super.init(style: .default, reuseIdentifier: nil)

		backgroundColor = .clear
		textLabel?.font = .preferredFont(forTextStyle: .callout)

		let effect: UIVisualEffect
		if #available(iOS 13.0, *) {
			effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .systemMaterial), style: .separator)
		} else {
			effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .regular))
		}

		let effectView = UIVisualEffectView(effect: effect)
		effectView.contentView.backgroundColor = SystemColor.secondaryLabel

		effectView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(effectView)
		effectView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		effectView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		effectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		effectView.heightAnchor.constraint(equalToConstant: Self.separatorHeight).isActive = true

		separatorView = effectView
	}

	convenience init(title: String?, image: UIImage?) {
		self.init()

		textLabel?.text = title
		accessoryView = UIImageView(image: image)
		accessoryView?.tintColor = SystemColor.secondaryLabel
	}

	convenience init(title: String?, selected: Bool) {
		self.init()

		textLabel?.text = title
		if selected {
			accessoryType = .checkmark
			tintColor = SystemColor.secondaryLabel
		}
	}

	required init?(coder: NSCoder) {
		fatalError()
	}
}

class SeparatorCell: ItemCell {
	override class var separatorHeight: CGFloat { 8 }

	override init() {
		super.init()

		separatorView?.contentView.backgroundColor = SystemColor.systemFill
	}

	required init?(coder: NSCoder) {
		fatalError()
	}
}
