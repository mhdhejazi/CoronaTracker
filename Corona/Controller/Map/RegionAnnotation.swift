//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/3/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

class RegionAnnotation: NSObject, MKAnnotation {
	let region: Region
	let mode: Statistic.Kind
	let coordinate: CLLocationCoordinate2D
	let title: String?

	init(region: Region, mode: Statistic.Kind = .confirmed) {
		self.region = region
		self.mode = mode
		self.coordinate = region.location.clLocation
		self.title = region.localizedLongName
	}
}
