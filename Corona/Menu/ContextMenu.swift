//
//  Corona Tracker
//  Created by Mhd Hejazi on 4/10/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class ContextMenu: NSObject {
	private weak var view: UIView?
	private weak var menuBuilder: ContextMenuBuilder?
	private var viewBackgroundColor: UIColor?

	init(view: UIView, menuBuilder: ContextMenuBuilder) {
		self.view = view
		self.menuBuilder = menuBuilder
		super.init()

		if #available(iOS 13.0, *) {
			view.addInteraction(UIContextMenuInteraction(delegate: self))
		}
	}
}

@available(iOS 13.0, *)
extension ContextMenu: UIContextMenuInteractionDelegate {
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
								configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {

		guard let menu = self.menuBuilder?.buildContextMenu() else { return nil }

		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in menu })
	}

	func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
								previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

		guard let view = view else { return nil }

		let parameters = UIPreviewParameters()
		parameters.backgroundColor = .clear
		return UITargetedPreview(view: view, parameters: parameters)
	}

	func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
								willDisplayMenuFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {

		#if !targetEnvironment(macCatalyst)
		if view?.backgroundColor == UIColor.clear {
			viewBackgroundColor = UIColor.clear
			view?.backgroundColor = SystemColor.secondarySystemBackground
		}
		#endif
	}

	func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
								willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {

		if viewBackgroundColor != nil {
			UIView.animate(withDuration: 0.25) {
				self.view?.backgroundColor = self.viewBackgroundColor
			}
		}
	}
}

protocol ContextMenuBuilder: AnyObject {
	@available(iOS 13.0, *)
	func buildContextMenu() -> UIMenu?
}
