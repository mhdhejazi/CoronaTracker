//
//  Corona Tracker
//  Created by Mhd Hejazi on 4/8/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
	static let font: UIFont = .preferredFont(forTextStyle: .callout)

	class var separatorHeight: CGFloat { 0.5 }
	var separatorView: UIVisualEffectView?

	init() {
		super.init(style: .default, reuseIdentifier: nil)

		backgroundColor = .clear
		textLabel?.font = Self.font

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
		fatalError("init(coder:) has not been implemented")
	}
}

class SeparatorCell: ItemCell {
	override class var separatorHeight: CGFloat { 8 }

	override init() {
		super.init()

		separatorView?.contentView.backgroundColor = SystemColor.systemFill
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
