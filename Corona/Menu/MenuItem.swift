//
//  Corona Tracker
//  Created by Mhd Hejazi on 4/8/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

enum MenuItem {
	case regular(title: String?, image: UIImage?, action: () -> Void)
	case option(title: String?, selected: Bool, action: () -> Void)
	case separator

	var height: CGFloat {
		switch self {
		case .regular, .option:
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
