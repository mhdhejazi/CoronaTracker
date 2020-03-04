//
//  ViewController.swift
//  Corona
//
//  Created by Mohammad on 3/2/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import MapKit

import CodableCSV

class MapController: UIViewController {
	private var allAnnotations: [VirusReportAnnotation] = []
	private var mainAnnotations: [VirusReportAnnotation] = []
	private var annotations: [VirusReportAnnotation] = []

	@IBOutlet var mapView: MKMapView!

	override func viewDidLoad() {
		super.viewDidLoad()

		for report in VirusDataManager.instance.allReports where report.data.confirmedCount > 0 {
			let annotation = VirusReportAnnotation(virusReport: report)
			allAnnotations.append(annotation)
		}

		for report in VirusDataManager.instance.mainReports where report.data.confirmedCount > 0 {
			let annotation = VirusReportAnnotation(virusReport: report)
			mainAnnotations.append(annotation)
		}

		annotations = allAnnotations
		mapView.addAnnotations(annotations)
		mapView.register(VirusReportAnnotationView.self,
						 forAnnotationViewWithReuseIdentifier: VirusReportAnnotation.reuseIdentifier)
		mapView.showsPointsOfInterest = false
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	private func showRegionScreen(report: VirusReport) {
		let identifier = String(describing: RegionController.self)
		guard let controller = storyboard?.instantiateViewController(
			withIdentifier: identifier) as? RegionController else { return }

		controller.virusReport = report

		present(controller, animated: true)

		controller.update()
	}
}

extension MapController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard !(annotation is MKUserLocation) else {
			return nil
		}

		guard let annotationView = mapView.dequeueReusableAnnotationView(
			withIdentifier: VirusReportAnnotation.reuseIdentifier,
			for: annotation) as? VirusReportAnnotationView else { return nil }

		annotationView.mapZoomLevel = mapView.zoomLevel

		return annotationView
	}

	func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
//		print(mapView.zoomLevel)
		for annotation in annotations {
			if let view = mapView.view(for: annotation) as? VirusReportAnnotationView {
				view.mapZoomLevel = mapView.zoomLevel
			}
		}

	}

	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		if mapView.zoomLevel > 4 {
			if annotations.count != allAnnotations.count {
				mapView.removeAnnotations(annotations)
				annotations = allAnnotations
				mapView.addAnnotations(annotations)
			}
		}
		else {
			if annotations.count != mainAnnotations.count {
				mapView.removeAnnotations(annotations)
				annotations = mainAnnotations
				mapView.addAnnotations(annotations)
			}
		}
	}

	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		guard let annotationView = view as? VirusReportAnnotationView else { return }
		showRegionScreen(report: annotationView.virusReport!)
	}
}


