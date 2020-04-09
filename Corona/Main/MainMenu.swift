//
//  Corona Tracker
//  Created by Mhd Hejazi on 4/9/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class MainMenu {
	@available(iOS 13.0, *)
	init(builder: UIMenuBuilder) {
		buildMenu(with: builder)
	}
}

@available(iOS 13.0, *)
extension MainMenu {
	func canPerformAction(_ action: Selector) -> Bool {
		switch action {
		case #selector(searchAction(_:)),
			 #selector(reloadAction(_:)),
			 #selector(shareAction(_:)):
			return true

		default:
			return false
		}
	}

	private func buildMenu(with builder: UIMenuBuilder) {
		guard builder.system == .main else { return }

		builder.remove(menu: .format)

		builder.insertSibling(searchMenu(), afterMenu: .standardEdit)
		builder.insertChild(reloadMenu(), atStartOfMenu: .view)
		builder.insertChild(shareMenu(), atStartOfMenu: .file)
	}

	private func searchMenu() -> UIMenu {
		let command = UIKeyCommand(title: L10n.Menu.search,
								   action: #selector(searchAction(_:)),
								   input: "F",
								   modifierFlags: .command)
		return UIMenu(title: "", options: .displayInline, children: [command])
	}

	private func reloadMenu() -> UIMenu {
		let command = UIKeyCommand(title: L10n.Menu.update,
								   action: #selector(reloadAction(_:)),
								   input: "R",
								   modifierFlags: .command)
		return UIMenu(title: "", options: .displayInline, children: [command])
	}

	private func shareMenu() -> UIMenu {
		let command = UIKeyCommand(title: L10n.Menu.share,
								   action: #selector(shareAction(_:)),
								   input: "S",
								   modifierFlags: .command)
		return UIMenu(title: "", options: .displayInline, children: [command])
	}

	@objc
	private func searchAction(_ sender: UICommand) {
		MapController.instance.showSearchScreen()
	}

	@objc
	private func reloadAction(_ sender: UICommand) {
		MapController.instance.downloadIfNeeded()
	}

	@objc
	private func shareAction(_ sender: UICommand) {
		MapController.instance.showShareButtons()
	}
}
