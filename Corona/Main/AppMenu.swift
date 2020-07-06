//
//  Corona Tracker
//  Created by Mhd Hejazi on 4/9/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class AppMenu {
	@available(iOS 13.0, *)
	init(builder: UIMenuBuilder) {
		buildMenu(with: builder)
	}
}

@available(iOS 13.0, *)
extension AppMenu {
	func canPerformAction(_ action: Selector) -> Bool {
		switch action {
		case #selector(searchAction(_:)),
			 #selector(reloadAction(_:)),
			 #selector(shareAction(_:)),
			 #selector(releaseNotesAction(_:)),
			 #selector(reportIssueAction(_:)),
			 #selector(showHelp(_:)):
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
		builder.insertChild(helpMenu(), atStartOfMenu: .help)
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

	private func helpMenu() -> UIMenu {
		UIMenu(title: "", options: .displayInline, children: [
			UICommand(title: L10n.Menu.releaseNotes,
					  action: #selector(releaseNotesAction(_:))),
			UICommand(title: L10n.Menu.reportIssue,
					  action: #selector(reportIssueAction(_:)))
		])
	}

	private func reportIssueMenu() -> UIMenu {
		let command = UICommand(title: L10n.Menu.reportIssue,
								action: #selector(reportIssueAction(_:)))
		return UIMenu(title: "", options: .displayInline, children: [command])
	}

	// MARK: - Actions

	@objc
	private func searchAction(_ sender: UICommand) {
		MapController.shared.showSearchScreen()
	}

	@objc
	private func reloadAction(_ sender: UICommand) {
		MapController.shared.downloadIfNeeded()
	}

	@objc
	private func shareAction(_ sender: UICommand) {
		MapController.shared.showShareButtons()
	}

	@objc
	private func releaseNotesAction(_ sender: UICommand) {
		App.openReleaseNotesPage()
	}

	@objc
	private func reportIssueAction(_ sender: UICommand) {
		App.openNewIssuePage()
	}

	@objc
	private func showHelp(_ sender: UICommand) {
		App.openHelpPage()
	}
}
