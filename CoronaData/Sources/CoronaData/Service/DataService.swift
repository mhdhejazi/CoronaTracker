//
//  DataService.swift
//  Corona Tracker
//
//  Created by Mohammad on 3/10/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

public protocol DataService {
	typealias FetchListBlock<T> = ([T]?, Error?) -> Void
	typealias FetchReportsBlock = FetchListBlock<Report>
	typealias FetchTimeSeriesesBlock = FetchListBlock<TimeSeries>

	func fetchReports(completion: @escaping FetchReportsBlock)

	func fetchTimeSerieses(completion: @escaping FetchTimeSeriesesBlock)
}
