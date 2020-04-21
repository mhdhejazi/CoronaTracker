//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/25/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

class RegionDataCell: UITableViewCell {
	class var reuseIdentifier: String { String(describing: Self.self) }

	private lazy var buttonShare: UIButton = {
		let button = UIButton(type: .custom)
		button.setImage(Asset.shareCircle.image, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.widthAnchor.constraint(equalToConstant: 50).isActive = true
		button.heightAnchor.constraint(equalToConstant: 50).isActive = true
		button.transform = .init(scaleX: 0.1, y: 0.1)
		button.alpha = 0
		button.addAction {
			self.shareAction?()
		}
		return button
	}()

	private var contextMenu: ContextMenu?

	@available(iOS 13.0, *)
	var contextMenuActions: [UIMenuElement] {
		var items = [UIMenuElement]()

		#if targetEnvironment(macCatalyst)
		items.append(UIMenu(title: "", options: .displayInline, children: [
			UIAction(title: L10n.Menu.copy) { _ in self.copyAction?() }
		]))
		#endif

		items.append(UIAction(title: L10n.Menu.share, image: Asset.share.image) { _ in
			self.shareAction?()
		})

		return items
	}

	var copyAction: (() -> Void)?
	var shareAction: (() -> Void)?
	var shareableImage: UIImage? { nil }
	var shareableText: String? { nil }

	var region: Region? {
		didSet {
			guard region !== oldValue else { return }
			update()
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		clipsToBounds = false
		contentView.clipsToBounds = false

		contentView.addSubview(buttonShare)
		buttonShare.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		buttonShare.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true

		contextMenu = ContextMenu(view: self, menuBuilder: self)
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		guard shareableText != nil, superview is UITableView else { return }

		UIView.animate(withDuration: animated ? (editing ? 0.5 : 0.25) : 0,
					   delay: 0,
					   usingSpringWithDamping: editing ? 0.7 : 2,
					   initialSpringVelocity: 0,
					   options: [],
					   animations: {

						let scale: CGFloat = editing ? 1 : 0.1
						let alpha: CGFloat = editing ? 1 : 0
						self.buttonShare.transform = .init(scaleX: scale, y: scale)
						self.buttonShare.alpha = alpha
						self.contentView.subviews.filter { $0 !== self.buttonShare }.forEach { subview in
							subview.transform = editing ? .init(translationX: -self.buttonShare.bounds.width - 15, y: 0) : .identity
						}
		})
	}

	func update(animated: Bool = true) {
	}
}

@available(iOS 13.0, *)
extension RegionDataCell: ContextMenuBuilder {
	func buildContextMenu() -> UIMenu? {
		guard shareableText != nil, !isEditing else { return nil }

		return UIMenu(title: "", children: self.contextMenuActions)
	}
}
