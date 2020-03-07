//
//  ReportAnnotation.swift
//  Corona
//
//  Created by Mohammad on 3/3/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

class ReportAnnotation: NSObject, MKAnnotation {
	static let reuseIdentifier = String(describing: ReportAnnotation.self)

	let report: Report

	let coordinate: CLLocationCoordinate2D
	let title: String?

	init(report: Report) {
		self.report = report

		let region = report.region
		self.coordinate = region.location
		self.title = region.name

		super.init()
	}
}
