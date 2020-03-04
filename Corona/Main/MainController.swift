//
//  MainController.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import OverlayContainer

class MainController: UIViewController {

    enum OverlayNotch: Int, CaseIterable {
        case minimum, maximum
    }

    @IBOutlet var overlayContainerView: UIView!
    @IBOutlet var backgroundView: UIView!

    @IBOutlet private var widthConstraint: NSLayoutConstraint!
    @IBOutlet private var trailingConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()


		var identifier = String(describing: RegionController.self)
		guard let regionController = storyboard?.instantiateViewController(
			withIdentifier: identifier) as? RegionController else { return }

		identifier = String(describing: MapController.self)
		guard let mapController = storyboard?.instantiateViewController(
			withIdentifier: identifier) as? MapController else { return }

        let overlayController = OverlayContainerViewController()
        overlayController.delegate = self
        overlayController.viewControllers = [regionController]
        addChild(overlayController, in: overlayContainerView)
        addChild(mapController, in: backgroundView)
    }

    override func viewWillLayoutSubviews() {
        setUpConstraints(for: view.bounds.size)
        super.viewWillLayoutSubviews()
    }

    // MARK: - Private

    private func setUpConstraints(for size: CGSize) {
        if size.width > size.height {
            trailingConstraint.isActive = false
            widthConstraint.isActive = true
        } else {
            trailingConstraint.isActive = true
            widthConstraint.isActive = false
        }
    }

    private func notchHeight(for notch: OverlayNotch, availableSpace: CGFloat) -> CGFloat {
        switch notch {
        case .maximum:
            return availableSpace * 3 / 4
        case .minimum:
            return availableSpace * 1 / 4
        }
    }
}

extension MainController: OverlayContainerViewControllerDelegate {

    // MARK: - OverlayContainerViewControllerDelegate

    func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int {
        return OverlayNotch.allCases.count
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        heightForNotchAt index: Int,
                                        availableSpace: CGFloat) -> CGFloat {
        let notch = OverlayNotch.allCases[index]
        return notchHeight(for: notch, availableSpace: availableSpace)
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        scrollViewDrivingOverlay overlayViewController: UIViewController) -> UIScrollView? {
        return (overlayViewController as? RegionController)?.tableView
    }

//    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
//                                        shouldStartDraggingOverlay overlayViewController: UIViewController,
//                                        at point: CGPoint,
//                                        in coordinateSpace: UICoordinateSpace) -> Bool {
//        guard let header = (overlayViewController as? RegionController)?.header else {
//            return false
//        }
//
//        let convertedPoint = coordinateSpace.convert(point, to: header)
//        return header.bounds.contains(convertedPoint)
//    }
}

extension UIViewController {
	func addChild(_ child: UIViewController, in containerView: UIView) {
		guard containerView.isDescendant(of: view) else { return }
		addChild(child)
		containerView.addSubview(child.view)
		child.view.pinToSuperview()
		child.didMove(toParent: self)
	}

	func removeChild(_ child: UIViewController) {
		child.willMove(toParent: nil)
		child.view.removeFromSuperview()
		child.removeFromParent()
	}
}

extension UIView {
	func pinToSuperview(with insets: UIEdgeInsets = .zero, edges: UIRectEdge = .all) {
		guard let superview = superview else { return }
		translatesAutoresizingMaskIntoConstraints = false
		if edges.contains(.top) {
			topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top).isActive = true
		}
		if edges.contains(.bottom) {
			bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom).isActive = true
		}
		if edges.contains(.left) {
			leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left).isActive = true
		}
		if edges.contains(.right) {
			trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right).isActive = true
		}
	}
}
