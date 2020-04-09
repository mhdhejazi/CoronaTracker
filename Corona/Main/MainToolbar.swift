//
//  Corona Tracker
//  Created by Mhd Hejazi on 4/9/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class MainToolbar: NSObject {
	@available(iOS 13.0, *)
	init(windowScene: UIWindowScene) {
		super.init()

		#if targetEnvironment(macCatalyst)
		configureToolbar(for: windowScene)
		#endif
	}
}

#if targetEnvironment(macCatalyst)
extension MainToolbar: NSToolbarDelegate {
	func configureToolbar(for windowScene: UIWindowScene) {
		guard let titlebar = windowScene.titlebar else { return }

		titlebar.titleVisibility = .hidden

		let toolbar = NSToolbar()
		toolbar.centeredItemIdentifier = .title
		toolbar.delegate = self
		titlebar.toolbar = toolbar
	}

	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		[.search, .mode, .reload, .title]
	}

	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		[.search, .reload, .share, .flexibleSpace, .title, .flexibleSpace, .mode]
	}

	func toolbar(_ toolbar: NSToolbar,
				 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
				 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
		switch itemIdentifier {
		case .mode:
			let item = NSToolbarItemGroup(itemIdentifier: itemIdentifier,
										  titles: Statistic.Kind.all.map { $0.description },
										  selectionMode: .selectOne,
										  labels: nil,
										  target: self,
										  action: #selector(toolbarGroupSelectionChanged(group:)))
			item.controlRepresentation = .collapsed
			item.selectedIndex = MapController.instance.mode.rawValue
			return item

		case .reload:
			let button = UIBarButtonItem(image: Asset.reload.image,
										 style: .plain,
										 target: self,
										 action: #selector(toolbarItemClicked(item:)))
			return NSToolbarItem(itemIdentifier: itemIdentifier, barButtonItem: button)

		case .search:
			let button = UIBarButtonItem(image: Asset.search.image,
										 style: .plain,
										 target: self,
										 action: #selector(toolbarItemClicked(item:)))
			return NSToolbarItem(itemIdentifier: itemIdentifier, barButtonItem: button)

		case .share:
			let button = UIBarButtonItem(image: Asset.share.image,
										 style: .plain,
										 target: self,
										 action: #selector(toolbarItemClicked(item:)))
			return NSToolbarItem(itemIdentifier: itemIdentifier, barButtonItem: button)

		case .title:
			let item = NSToolbarItem(itemIdentifier: itemIdentifier)
			item.isBordered = false
			item.title = Bundle.main.name ?? ""
			return item

		default:
			return nil
		}
	}

	@objc
	func toolbarGroupSelectionChanged(group: NSToolbarItemGroup) {
		MapController.instance.mode = Statistic.Kind(rawValue: group.selectedIndex) ?? .confirmed
	}

	@objc
	func toolbarItemClicked(item: NSToolbarItem) {
		switch item.itemIdentifier {
		case .reload:
			MapController.instance.downloadIfNeeded()

		case .search:
			MapController.instance.showSearchScreen()

		case .share:
			MapController.instance.showShareButtons()

		default:
			break
		}
	}
}

extension NSToolbarItem.Identifier {
	static let mode = NSToolbarItem.Identifier("mode")
	static let reload = NSToolbarItem.Identifier("reload")
	static let search = NSToolbarItem.Identifier("search")
	static let share = NSToolbarItem.Identifier("share")
	static let title = NSToolbarItem.Identifier("title")
}
#endif
