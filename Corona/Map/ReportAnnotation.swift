//
//  ReportAnnotation.swift
//  Corona
//
//  Created by Mohammad on 3/3/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

class ReportAnnotation: NSObject, MKAnnotation {
	let report: Report
	let coordinate: CLLocationCoordinate2D
	let title: String?

	init(report: Report) {
		self.report = report
		self.coordinate = report.region.location.clLocation
		self.title = report.region.name

		super.init()
	}
}
