//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/2/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import MapKit

import FloatingPanel

class MapController: UIViewController {
	private static let updateInterval: TimeInterval = 60 * 5 /// 5 mins

	static var shared: MapController!
	static var initialRegionCode: String?

	@IBOutlet private var mapView: MKMapView!
	@IBOutlet private var effectView: UIVisualEffectView!
	@IBOutlet private var buttonUpdate: UIButton!
	@IBOutlet private var viewOptions: UIView!
	@IBOutlet private var effectViewOptions: UIVisualEffectView!
	@IBOutlet private var buttonMode: UIButton!

	private var cityZoomLevel: CGFloat { 5 }
	private var allAnnotations: [RegionAnnotation] = []
	private var currentRegion: Region?

	private var panelController: FloatingPanelController!
	private var regionPanelController: RegionPanelController!

	var mode: Statistic.Kind = .confirmed {
		didSet {
			update()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		MapController.shared = self

		initializeView()
		initializeBottomSheet()

		DataManager.shared.load { _ in
			if let regionCode = Self.initialRegionCode,
			   let initialRegion = DataManager.shared.world.subRegions.first(where: { $0.isoCode == regionCode }) {
				self.currentRegion = initialRegion
			}

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
		effectViewOptions.layer.cornerRadius = effectViewOptions.bounds.height / 2
		viewOptions.enableShadow()

		buttonUpdate.layer.cornerRadius = buttonUpdate.bounds.height / 2
		buttonUpdate.isHidden = true

		if #available(iOS 13.0, *) {
			effectView.effect = UIBlurEffect(style: .systemThinMaterial)
			effectViewOptions.effect = UIBlurEffect(style: .systemUltraThinMaterial)
		}

		if #available(iOS 11.0, *) {
			mapView.mapType = .mutedStandard
			mapView.register(RegionAnnotationView.self,
							 forAnnotationViewWithReuseIdentifier: RegionAnnotationView.reuseIdentifier)
		}

		#if targetEnvironment(macCatalyst)
		viewOptions.isHidden = true

		/// Workaround for hiding the iPhone frame that appears on app start
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

		if #available(iOS 11.0, *), view.safeAreaInsets.bottom == 0 {
			panelController.additionalSafeAreaInsets = .init(top: 0, left: 0, bottom: 15, right: 0)
		}
	}

	func updateRegionScreen(region: Region?) {
		currentRegion = region
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
		guard let annotation = mapView.annotations.first(where: { annotation in
			(annotation as? RegionAnnotation)?.region == region
		}) else {
			return
		}

		if onlyIfVisible, !mapView.visibleMapRect.contains(MKMapPoint(annotation.coordinate)) {
			return
		}

		self.mapView.selectAnnotation(annotation, animated: true)
	}

	private func update() {
		allAnnotations = DataManager.shared.allRegions()
			.filter { $0.report?.stat.number(for: mode) ?? 0 > 0 }
			.map { RegionAnnotation(region: $0, mode: mode) }

		let currentAnnotations = allAnnotations.filter { annotation in
			annotation.region.isCountry || mapView.zoomLevel > cityZoomLevel
		}

		let currentRegion = self.currentRegion

		mapView.superview?.transition {
			self.mapView.removeAnnotations(self.mapView.annotations)
			self.mapView.addAnnotations(currentAnnotations)
		}

		regionPanelController.regionDataController.region = currentRegion
		regionPanelController.regionDataController.update()
	}

	func downloadIfNeeded() {
		let showSpinner = allAnnotations.isEmpty
		if showSpinner {
			showHUD(message: L10n.Data.updating)
		}
		regionPanelController.isUpdating = true

		DataManager.shared.download { success in
			DispatchQueue.main.async {
				self.regionPanelController.isUpdating = false

				if success {
					self.hideHUD()
					self.update()
				} else {
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

	func showShareButtons() {
		showRegionScreen()
		regionPanelController.regionDataController.setEditing(true, animated: true)
	}

	func showSearchScreen() {
		regionPanelController.isSearching = true
	}

	// MARK: - Actions

	@IBAction private func buttonUpdateTapped(_ sender: Any) {
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
		Menu.show(above: self, sourceView: buttonMode, items: [
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
			}
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
			let view = mapView.dequeueReusableAnnotationView(
				withIdentifier: RegionAnnotationView.reuseIdentifier) as? RegionAnnotationView
			annotationView = view ?? RegionAnnotationView(annotation: annotation,
														  reuseIdentifier: RegionAnnotationView.reuseIdentifier)
		}

		annotationView.mapZoomLevel = mapView.zoomLevel

		return annotationView
	}

	func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
		for annotation in allAnnotations {
			if let view = mapView.view(for: annotation) as? RegionAnnotationView {
				view.mapZoomLevel = mapView.zoomLevel
			}
		}
	}

	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		if mapView.zoomLevel > cityZoomLevel {
			if mapView.annotations.count != allAnnotations.count {
				mapView.addAnnotations(self.allAnnotations.filter { !$0.region.isCountry })
			}
		} else {
			if mapView.annotations.count == allAnnotations.count {
				mapView.removeAnnotations(self.allAnnotations.filter { !$0.region.isCountry })
			}
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
	func floatingPanel(_ controller: FloatingPanelController,
					   layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {

		(newCollection.userInterfaceIdiom == .pad ||
			newCollection.verticalSizeClass == .compact) ? LandscapePanelLayout() : PanelLayout()
	}

	func floatingPanelWillBeginDragging(_ controller: FloatingPanelController) {
		let currentPosition = controller.position

		// currentPosition == .full means deceleration will start from top to bottom (i.e. user dragging the panel down)
		if currentPosition == .full, regionPanelController.isSearching {
			// Reset to region container's default mode then hide the keyboard
			self.regionPanelController.isSearching = false
		}
	}
}
