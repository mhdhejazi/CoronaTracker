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

class MapController: UIViewController {
	private static let cityZoomLevel = (UIScreen.main.bounds.width > 1000) ? CGFloat(5) : CGFloat(4)
	private static let updateInterval: TimeInterval = 60 * 5 /// 5 mins

	static var instance: MapController!

	private var allAnnotations: [RegionAnnotation] = []
	private var countryAnnotations: [RegionAnnotation] = []
	private var currentAnnotations: [RegionAnnotation] = []

	private var panelController: FloatingPanelController!
	private var regionPanelController: RegionPanelController!

	var mode: Statistic.Kind = .confirmed {
		didSet {
			update()
		}
	}

	@IBOutlet var mapView: MKMapView!
	@IBOutlet var effectView: UIVisualEffectView!
	@IBOutlet var buttonUpdate: UIButton!
	@IBOutlet var viewOptions: UIView!
	@IBOutlet var effectViewOptions: UIVisualEffectView!
	@IBOutlet var buttonMode: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()

		MapController.instance = self

		initializeView()
		initializeBottomSheet()

		DataManager.instance.load { _ in
			self.update()
			self.downloadIfNeeded()
		}

		Timer.scheduledTimer(withTimeInterval: Self.updateInterval, repeats: true) { _ in
			self.downloadIfNeeded()
		}

		checkForAppUpdate()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		panelController.addPanel(toParent: self, animated: true)
		regionPanelController.regionDataController.tableView.setContentOffset(.zero, animated: false)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		panelController.removePanelFromParent(animated: animated)
	}

	private func initializeView() {
		effectViewOptions.layer.cornerRadius = 10
		viewOptions.enableShadow()

		buttonUpdate.layer.cornerRadius = buttonUpdate.bounds.height / 2

		if #available(iOS 13.0, *) {
			effectView.effect = UIBlurEffect(style: .systemThinMaterial)
		}

		if #available(iOS 11.0, *) {
			mapView.mapType = .mutedStandard
			mapView.register(RegionAnnotationView.self,
							 forAnnotationViewWithReuseIdentifier: RegionAnnotationView.reuseIdentifier)
		}

		/// Workaround for hiding the iPhone frame that appears on app start
		#if targetEnvironment(macCatalyst)
		mapView.isHidden = true
		DispatchQueue.main.async {
			self.mapView.isHidden = false
		}
		#endif
	}

	private func initializeBottomSheet() {
		let identifier = String(describing: RegionPanelController.self)
		regionPanelController = storyboard?.instantiateViewController(
			withIdentifier: identifier) as? RegionPanelController

		panelController = FloatingPanelController()
		panelController.delegate = self
		panelController.surfaceView.cornerRadius = 12
		panelController.surfaceView.shadowHidden = false
		panelController.set(contentViewController: regionPanelController)
		panelController.track(scrollView: regionPanelController.regionDataController.tableView)
		panelController.surfaceView.backgroundColor = .clear
		panelController.surfaceView.contentView.backgroundColor = .clear

		#if targetEnvironment(macCatalyst)
		panelController.additionalSafeAreaInsets = .init(top: 0, left: 0, bottom: 10, right: 0)
		#endif
	}

	func updateRegionScreen(region: Region?) {
		regionPanelController.regionDataController.region = region
		regionPanelController.regionDataController.update()
	}

	func showRegionScreen() {
		panelController.move(to: .full, animated: true)
	}

	func showRegionOnMap(region: Region) {
		let spanDelta = region.subRegions.isEmpty ? 12.0 : 60.0
		let coordinateRegion = MKCoordinateRegion(center: region.location.clLocation,
												  span: MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta))
		mapView.selectedAnnotations = []
		mapView.setRegion(coordinateRegion, animated: true)
		updateRegionScreen(region: region)

		DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
			self.selectAnnotation(for: region)
		}
	}

	func selectAnnotation(for region: Region, onlyIfVisible: Bool = false) {
		guard let annotation = self.currentAnnotations.first(where: { $0.region == region }) else { return }

		if onlyIfVisible, !mapView.visibleMapRect.contains(MKMapPoint(annotation.coordinate)) {
			return
		}

		self.mapView.selectAnnotation(annotation, animated: true)
	}

	private func update() {
		allAnnotations = DataManager.instance.regions(of: .province)
			.filter({ $0.report?.stat.number(for: mode) ?? 0 > 0 })
			.map({ RegionAnnotation(region: $0, mode: mode) })

		countryAnnotations = DataManager.instance.regions(of: .country)
			.filter({ $0.report?.stat.number(for: mode) ?? 0 > 0 })
			.map({ RegionAnnotation(region: $0, mode: mode) })

		currentAnnotations = mapView.zoomLevel > Self.cityZoomLevel ? allAnnotations : countryAnnotations

		view.transition {
			self.mapView.removeAnnotations(self.mapView.annotations)
			self.mapView.addAnnotations(self.currentAnnotations)
		}

		regionPanelController.regionDataController.region = nil
		regionPanelController.regionDataController.update()
	}

	func downloadIfNeeded() {
		let showSpinner = allAnnotations.isEmpty
		if showSpinner {
			showHUD(message: L10n.Data.updating)
		}
		regionPanelController.isUpdating = true

		DataManager.instance.download { success in
			DispatchQueue.main.async {
				self.regionPanelController.isUpdating = false

				if success {
					self.hideHUD()
					self.update()
				}
				else {
					if showSpinner {
						self.showMessage(title: L10n.Data.errorTitle,
										 message: L10n.Data.errorMessage)
					}
				}
			}
		}
	}

	private func checkForAppUpdate() {
		App.checkForAppUpdate { updateAvailable in
			if updateAvailable {
				DispatchQueue.main.async {
					self.buttonUpdate.isHidden = false
				}
			}
		}
	}

	@IBAction func buttonUpdateTapped(_ sender: Any) {
		let alertController = UIAlertController.init(
			title: L10n.App.newVersionTitle,
			message: L10n.App.newVersionMessage(App.updateURL.absoluteString),
			preferredStyle: .alert)

		#if targetEnvironment(macCatalyst)
		alertController.addAction(UIAlertAction(title: L10n.Message.cancel, style: .cancel))
		alertController.addAction(UIAlertAction(title: L10n.Message.open, style: .default, handler: { _ in
			App.openUpdatePage(viewController: self)
		}))
		#else
		alertController.addAction(UIAlertAction(title: L10n.Message.ok, style: .cancel))
		#endif

		present(alertController, animated: true)

		buttonUpdate.isHidden = true
	}

	@IBAction func buttonModeTapped(_ sender: Any) {
		Menu.show(above: self, sourceView: buttonMode, width: 150, items: [
			.option(title: L10n.Case.confirmed, selected: mode == .confirmed) {
				self.mode = .confirmed
			},
			.option(title: L10n.Case.active, selected: mode == .active) {
				self.mode = .active
			},
			.option(title: L10n.Case.recovered, selected: mode == .recovered) {
				self.mode = .recovered
			},
			.option(title: L10n.Case.deaths, selected: mode == .deaths) {
				self.mode = .deaths
			},
		])
	}
}

extension MapController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard !(annotation is MKUserLocation) else {
			return nil
		}

		var annotationView: RegionAnnotationView
		if #available(iOS 11.0, *) {
			guard let view = mapView.dequeueReusableAnnotationView(
				withIdentifier: RegionAnnotationView.reuseIdentifier,
				for: annotation) as? RegionAnnotationView else { return nil }
			annotationView = view
		} else {
			/// iOS 10
			let view = mapView.dequeueReusableAnnotationView(
				withIdentifier: RegionAnnotationView.reuseIdentifier) as? RegionAnnotationView
			annotationView = view ?? RegionAnnotationView(annotation: annotation,
														  reuseIdentifier: RegionAnnotationView.reuseIdentifier)
		}

		annotationView.mapZoomLevel = mapView.zoomLevel

		return annotationView
	}

	func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
		for annotation in currentAnnotations {
			if let view = mapView.view(for: annotation) as? RegionAnnotationView {
				view.mapZoomLevel = mapView.zoomLevel
			}
		}
	}

	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		var annotationToSelect: MKAnnotation? = nil

		if mapView.zoomLevel > Self.cityZoomLevel {
			if currentAnnotations.count != allAnnotations.count {
				view.transition {
					annotationToSelect = mapView.selectedAnnotations.first
					mapView.removeAnnotations(mapView.annotations)
					self.currentAnnotations = self.allAnnotations
					mapView.addAnnotations(self.currentAnnotations)
				}
			}
		}
		else {
			if currentAnnotations.count != countryAnnotations.count {
				view.transition {
					annotationToSelect = mapView.selectedAnnotations.first
					mapView.removeAnnotations(mapView.annotations)
					self.currentAnnotations = self.countryAnnotations
					mapView.addAnnotations(self.currentAnnotations)
				}
			}
		}

		if let region = (annotationToSelect as? RegionAnnotation)?.region {
			selectAnnotation(for: region, onlyIfVisible: true)
		}
	}

	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		updateRegionScreen(region: (view as? RegionAnnotationView)?.region)
	}

	func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
		updateRegionScreen(region: nil)
	}
}

extension MapController: FloatingPanelControllerDelegate {
	func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
		(newCollection.userInterfaceIdiom == .pad ||
			newCollection.verticalSizeClass == .compact) ? LandscapePanelLayout() : PanelLayout()
	}

	func floatingPanelWillBeginDragging(_ vc: FloatingPanelController) {
		let currentPosition = vc.position

		// currentPosition == .full means deceleration will start from top to bottom (i.e. user dragging the panel down)
		if currentPosition == .full, regionPanelController.isSearching {
			// Reset to region container's default mode then hide the keyboard
			self.regionPanelController.isSearching = false
		}
	}
}

class PanelLayout: FloatingPanelLayout {
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
		case .half: return 215
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
