//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/19/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class Menu {
	static func show(above controller: UIViewController, sourceView: UIView, items: [MenuItem]) {
		let menuController = MenuController(items: items)
		let segue = MenuSegue(identifier: nil, source: controller, destination: menuController)
		segue.sourceView = sourceView
		controller.prepare(for: segue, sender: sourceView)
		segue.perform()
	}
}

enum MenuItem {
	case regular(title: String?, image: UIImage?, action: () -> Void)
	case option(title: String?, selected: Bool, action: () -> Void)
	case separator

	var height: CGFloat {
		switch self {
		case .regular(_, _, _), .option(_, _, _):
			return 44
		case .separator:
			return 8
		}
	}

	func calculateTitleWidth(using font: UIFont) -> CGFloat {
		let string: String?
		switch self {
		case .regular(let title, _, _), .option(let title, _, _):
			string = title
		case .separator:
			return 0
		}

		let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
		let rect = string?.boundingRect(with: size,
										options: .usesLineFragmentOrigin,
										attributes: [.font: font],
										context: nil)

		return ceil(rect?.width ?? 0)
	}
}
