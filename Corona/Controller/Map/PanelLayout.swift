//
//  Corona Tracker
//  Created by Mhd Hejazi on 4/8/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import FloatingPanel

class PanelLayout: FloatingPanelLayout {
	public var supportedPositions: Set<FloatingPanelPosition> {
		Set([.full, .half])
	}

	public var initialPosition: FloatingPanelPosition {
		#if targetEnvironment(macCatalyst)
		return .full
		#else
		return UIDevice.current.userInterfaceIdiom == .pad ? .full : .half
		#endif
	}

	public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
		switch position {
		case .full: return 16
		case .half: return 198
		default: return nil
		}
	}

	func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
		if #available(iOS 11.0, *) {
			return [
				surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0),
				surfaceView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0)
			]
		} else {
			return [
				surfaceView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0),
				surfaceView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0)
			]
		}
	}

	func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
		position == .full ? 0.3 : 0.0
	}
}

class LandscapePanelLayout: PanelLayout {
	override func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
		if #available(iOS 11.0, *) {
			return [
				surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0),
				surfaceView.widthAnchor.constraint(equalToConstant: 400)
			]
		} else {
			return [
				surfaceView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0),
				surfaceView.widthAnchor.constraint(equalToConstant: 400)
			]
		}
	}

	override func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
		0.0
	}
}
