//
//  ViewController.swift
//  Corona
//
//  Created by Mohammad on 3/2/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import MapKit

import FloatingPanel
import PKHUD

class MapController: UIViewController {
	private static let cityZoomLevel = CGFloat(4)
	private static let updateInterval: TimeInterval = 60 * 5 /// 5 mins

	static var instance: MapController!

	private var allAnnotations: [ReportAnnotation] = []
	private var countryAnnotations: [ReportAnnotation] = []
	private var currentAnnotations: [ReportAnnotation] = []

	private var panelController: FloatingPanelController!
	private var regionContainerController: RegionContainerController!

	@IBOutlet var mapView: MKMapView!
	@IBOutlet var effectView: UIVisualEffectView!

	override func viewDidLoad() {
		super.viewDidLoad()

		MapController.instance = self

		if #available(iOS 13.0, *) {
			effectView.effect = UIBlurEffect(style: .systemThinMaterial)
		}

		let identifier = String(describing: RegionContainerController.self)
		regionContainerController = storyboard?.instantiateViewController(
			withIdentifier: identifier) as? RegionContainerController

		initializeBottomSheet()

		if #available(iOS 11.0, *) {
			mapView.register(ReportAnnotationView.self,
							 forAnnotationViewWithReuseIdentifier: ReportAnnotation.reuseIdentifier)
		}

		DataManager.instance.load { _ in
			self.update()
			self.downloadIfNeeded()
		}

		Timer.scheduledTimer(withTimeInterval: Self.updateInterval, repeats: true) { _ in
			self.downloadIfNeeded()
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		panelController.addPanel(toParent: self, animated: true)
		regionContainerController.regionController.tableView.setContentOffset(.zero, animated: false)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		panelController.removePanelFromParent(animated: animated)
	}

	private func initializeBottomSheet() {
		panelController = FloatingPanelController()
		panelController.delegate = self
		panelController.surfaceView.cornerRadius = 12
		panelController.surfaceView.shadowHidden = false
		panelController.set(contentViewController: regionContainerController)
		panelController.track(scrollView: regionContainerController.regionController.tableView)
		panelController.surfaceView.backgroundColor = .clear
		panelController.surfaceView.contentView.backgroundColor = .clear
	}

	func updateRegionScreen(report: Report?) {
		regionContainerController.regionController.report = report
		regionContainerController.regionController.update()
	}

	func showRegionScreen() {
		panelController.move(to: .full, animated: true)
	}

	func hideRegionScreen() {
		panelController.move(to: .half, animated: true)
	}

	private func update() {
		allAnnotations = DataManager.instance.allReports
			.filter({ $0.stat.confirmedCount > 0 })
			.map({ ReportAnnotation(report: $0) })

		countryAnnotations = DataManager.instance.countryReports
			.filter({ $0.stat.confirmedCount > 0 })
			.map({ ReportAnnotation(report: $0) })

		currentAnnotations = mapView.zoomLevel > Self.cityZoomLevel ? allAnnotations : countryAnnotations

		mapView.removeAnnotations(mapView.annotations)
		mapView.addAnnotations(currentAnnotations)

		regionContainerController.regionController.report = nil
		regionContainerController.regionController.update()
	}

	func downloadIfNeeded() {
		let showSpinner = allAnnotations.isEmpty
		if showSpinner {
			HUD.show(.label("Updating..."), onView: view)
		}
		regionContainerController.isUpdating = true

		DataManager.instance.download { success in
			DispatchQueue.main.async {
				self.regionContainerController.isUpdating = false

				if success {
					HUD.hide()
					self.update()
				}
				else {
					if showSpinner {
						HUD.flash(.error, onView: self.view, delay: 1.0)
					}
				}
			}
		}
	}
}

extension MapController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard !(annotation is MKUserLocation) else {
			return nil
		}

		var annotationView: ReportAnnotationView
		if #available(iOS 11.0, *) {
			guard let view = mapView.dequeueReusableAnnotationView(
				withIdentifier: ReportAnnotation.reuseIdentifier,
				for: annotation) as? ReportAnnotationView else { return nil }
			annotationView = view
		} else {
			/// iOS 10
			let view = mapView.dequeueReusableAnnotationView(
				withIdentifier: ReportAnnotation.reuseIdentifier) as? ReportAnnotationView
			annotationView = view ?? ReportAnnotationView(annotation: annotation,
														  reuseIdentifier: ReportAnnotation.reuseIdentifier)
		}

		annotationView.mapZoomLevel = mapView.zoomLevel

		return annotationView
	}

	func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
//		print(mapView.zoomLevel)
		for annotation in currentAnnotations {
			if let view = mapView.view(for: annotation) as? ReportAnnotationView {
				view.mapZoomLevel = mapView.zoomLevel
			}
		}
	}

	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		if mapView.zoomLevel > Self.cityZoomLevel {
			if currentAnnotations.count != allAnnotations.count {
				mapView.removeAnnotations(mapView.annotations)
				currentAnnotations = allAnnotations
				mapView.addAnnotations(currentAnnotations)
			}
		}
		else {
			if currentAnnotations.count != countryAnnotations.count {
				mapView.removeAnnotations(mapView.annotations)
				currentAnnotations = countryAnnotations
				mapView.addAnnotations(currentAnnotations)
			}
		}
	}

	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		updateRegionScreen(report: (view as? ReportAnnotationView)?.report)
	}

	func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
		updateRegionScreen(report: nil)
	}
}

extension MapController: FloatingPanelControllerDelegate {
	func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
		(newCollection.userInterfaceIdiom == .pad ||
			newCollection.verticalSizeClass == .compact) ? LandscapePanelLayout() : PanelLayout()
	}
}

class PanelLayout: FloatingPanelLayout {
	public var initialPosition: FloatingPanelPosition {
		return .half
	}

	public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
		switch position {
		case .full: return 16
		case .half: return 185
		case .tip: return 68
		default: return nil
		}
	}

	func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
		if #available(iOS 11.0, *) {
			return [
				surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0),
				surfaceView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0),
			]
		} else {
			/// iOS 10
			return [
				surfaceView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0),
				surfaceView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0),
			]
		}
	}

	func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
		return position == .full ? 0.3 : 0.0
	}
}

class LandscapePanelLayout: PanelLayout {
	override func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
		if #available(iOS 11.0, *) {
			return [
				surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0),
				surfaceView.widthAnchor.constraint(equalToConstant: 400),
			]
		} else {
			/// iOS 10
			return [
				surfaceView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0),
				surfaceView.widthAnchor.constraint(equalToConstant: 400),
			]
		}
	}

	override func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
		return 0.0
	}
}
