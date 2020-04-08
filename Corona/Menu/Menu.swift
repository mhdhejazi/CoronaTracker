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
