//
//  PlaceAnnotation.swift
//  Corona
//
//  Created by Mohammad on 3/3/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

class VirusReportAnnotation: NSObject, MKAnnotation {
	static let reuseIdentifier = String(describing: VirusReportAnnotation.self)

	let virusReport: VirusReport

	let coordinate: CLLocationCoordinate2D
	let title: String?

	init(virusReport: VirusReport) {
		self.virusReport = virusReport

		let region = virusReport.region
		self.coordinate = region.location
		self.title = region.name

		super.init()
	}
}
