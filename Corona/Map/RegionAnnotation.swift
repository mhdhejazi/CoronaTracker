//
//  RegionAnnotation.swift
//  Corona
//
//  Created by Mohammad on 3/3/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

class RegionAnnotation: NSObject, MKAnnotation {
	let region: Region
	let coordinate: CLLocationCoordinate2D
	let title: String?

	init(region: Region) {
		self.region = region
		self.coordinate = region.location.clLocation
		self.title = region.longName
	}
}
