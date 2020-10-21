//
//  Corona Tracker
//  Created by Mhd Hejazi on 4/20/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

public class BaseDataService {
	enum FetchError: Error {
		case noNewData
		case invalidData
		case downloadError
	}

	/// To detect when data changes we keep the hash of the recently fetched data
	private var lastDataHashes: [URL: String] = [:]

	func fetchData(from url: URL, addRandomParameter: Bool = false, completion: @escaping (Data?, Error?) -> Void) {

		var dataURL = url
		if addRandomParameter {
			dataURL = URL(string: dataURL.absoluteString + "&__rnd__=\(Int.random())")!
		}

		print("Calling API")
		requestAPI(url: dataURL) { data, error in
			guard let data = data else {
				completion(nil, error)
				return
			}

			DispatchQueue.global(qos: .default).async {
				let dataHash = data.sha1Hash()
				let lastDataHash = self.lastDataHashes[dataURL]
				if dataHash == lastDataHash {
					print("Nothing new")
					completion(nil, FetchError.noNewData)
					return
				}

				print("Download success")
				self.lastDataHashes[dataURL] = dataHash

				completion(data, nil)
			}
		}
	}

	func requestAPI(url: URL, completion: @escaping (Data?, Error?) -> Void) {
		var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
		request.setValue(url.host, forHTTPHeaderField: "referer")
		request.setValue("en-us", forHTTPHeaderField: "accept-language")
		URLSession.shared.dataTask(with: request) { (data, response, _) in
			guard let response = response as? HTTPURLResponse,
				response.statusCode == 200,
				let data = data else {

					print("Failed API call")
					completion(nil, FetchError.downloadError)
					return
			}

			completion(data, nil)
		}.resume()
	}

}
