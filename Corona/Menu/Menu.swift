//
//  Menu.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/19/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class Menu {
	static func show(above controller: UIViewController, sourceView: UIView, items: [MenuItem]) {
		show(above: controller, sourceView: sourceView, width: 200, items: items)
	}

	static func show(above controller: UIViewController, sourceView: UIView, width: CGFloat, items: [MenuItem]) {
		let menuController = MenuController(items: items, width: width)
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
}
