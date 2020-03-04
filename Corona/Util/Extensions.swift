//
//  Extensions.swift
//  Corona
//
//  Created by Mohammad on 3/3/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

extension MKMapView {
    var zoomLevel: CGFloat {
        let maxZoom: CGFloat = 20
        let zoomScale = self.visibleMapRect.size.width / Double(self.frame.size.width)
        let zoomExponent = log2(zoomScale)
        return maxZoom - CGFloat(zoomExponent)
    }
}

extension CLLocationCoordinate2D {
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    func distance(from coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        return location.distance(from: coordinate.location)
    }
}
