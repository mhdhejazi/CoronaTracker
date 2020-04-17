//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/19/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class MenuSegue: UIStoryboardSegue, UIViewControllerTransitioningDelegate {
	private var selfRetainer: MenuSegue?
	var sourceView: UIView?

	override func perform() {
		selfRetainer = self
		destination.modalPresentationStyle = .custom
		destination.transitioningDelegate = self
		source.present(destination, animated: true, completion: nil)
	}

	public func animationController(forPresented presented: UIViewController,
									presenting: UIViewController,
									source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		Presenter(segue: self, sourceView: sourceView)
	}

	public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		selfRetainer = nil
		return Dismisser()
	}

	public func presentationController(forPresented presented: UIViewController,
									   presenting: UIViewController?,
									   source: UIViewController) -> UIPresentationController? {
		PresentationController(presentedViewController: presented, presenting: presenting)
	}
}

private class PresentationController: UIPresentationController {
	override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
		super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
	}

	override func presentationTransitionWillBegin() {
		guard let containerView = containerView else { return }

		/// Dismiss on tap
		let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
		recognizer.cancelsTouchesInView = false
		containerView.addGestureRecognizer(recognizer)

		/// Dim background
		containerView.backgroundColor = .clear
		presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
			containerView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
		})
	}

	override func dismissalTransitionWillBegin() {
		guard let containerView = containerView else { return }

		containerView.gestureRecognizers = []

		presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
			containerView.backgroundColor = .clear
		})
	}

	override func viewWillTransition(to size: CGSize, with transitionCoordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: transitionCoordinator)

		transitionCoordinator.animate(alongsideTransition: { _ in
			self.presentedViewController.dismiss(animated: true)
		})
	}

	// MARK: - Actions

	@objc
	private func onTap(_ sender: UITapGestureRecognizer) {
		presentedViewController.dismiss(animated: true)
	}
}

private class Presenter: NSObject, UIViewControllerAnimatedTransitioning {
	private lazy var shadowView: UIView = {
		let shadowView = UIView()
		shadowView.layer.shadowColor = UIColor.black.cgColor
		shadowView.layer.shadowOffset = .zero
		shadowView.layer.shadowRadius = 30
		shadowView.layer.shadowOpacity = 0.15
		shadowView.translatesAutoresizingMaskIntoConstraints = false
		return shadowView
	}()
	private lazy var effectView: UIVisualEffectView = {
		var style: UIBlurEffect.Style
		if #available(iOS 13.0, *) {
			style = .systemUltraThinMaterial
		} else {
			style = .regular
		}
		let effectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
		effectView.backgroundColor = SystemColor.systemBackground.withAlphaComponent(0.15)
		effectView.layer.masksToBounds = true
		effectView.layer.cornerRadius = 10
		return effectView
	}()

	var segue: MenuSegue
	var sourceView: UIView?

	init(segue: MenuSegue, sourceView: UIView? = nil) {
		self.segue = segue
		self.sourceView = sourceView
	}

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		0.5
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let containerView = transitionContext.containerView
		let presentedView = transitionContext.view(forKey: .to)!
		let presentedViewController = transitionContext.viewController(forKey: .to)!

		/// Add shadow view
		let size = presentedViewController.preferredContentSize
		var maxY = containerView.bounds.maxY - 10
		if #available(iOS 11.0, *) {
			maxY -= containerView.safeAreaInsets.bottom
		}
		var right: CGFloat = 0
		var top: CGFloat = 0
		if let sourceView = sourceView {
			let sourceViewRect = sourceView.convert(sourceView.bounds, to: containerView)
			right = round(containerView.bounds.maxX - sourceViewRect.maxX)
			top = round(min(sourceViewRect.maxY, maxY - size.height)) + 3
		}
		containerView.addSubview(shadowView)
		shadowView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
		shadowView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
		shadowView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -right).isActive = true
		shadowView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: top).isActive = true

		/// Add effect view
		shadowView.addSubview(effectView)
		effectView.snapEdgesToSuperview()

		/// Add presented View
		effectView.contentView.addSubview(presentedView)
		presentedView.snapEdgesToSuperview()

		containerView.layoutIfNeeded()

		transitionContext.completeTransition(true)

		/// Animate
		shadowView.alpha = 0
		shadowView.transform = CGAffineTransform(scaleX: 1, y: 0.1).translatedBy(x: 0, y: -shadowView.bounds.height * 6)
		UIView.animate(withDuration: transitionDuration(using: transitionContext),
					   delay: 0,
					   usingSpringWithDamping: 0.7,
					   initialSpringVelocity: 0,
					   options: [.allowUserInteraction], animations: {
			self.shadowView.alpha = 1
			self.shadowView.transform = .identity
		})
	}
}

private class Dismisser: NSObject, UIViewControllerAnimatedTransitioning {
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		0.2
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
			transitionContext.containerView.subviews.forEach { $0.alpha = 0 }
		}, completion: { completed in
			transitionContext.completeTransition(completed)
		})
	}
}
