//
//  Corona Tracker
//  Created by Mhd Hejazi on 3/10/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

public protocol DataService {
	typealias FetchResultBlock = ([Region]?, Error?) -> Void

	func fetchReports(completion: @escaping FetchResultBlock)

	func fetchTimeSerieses(completion: @escaping FetchResultBlock)
}
