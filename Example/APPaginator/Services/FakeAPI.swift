//
//  FakeAPI.swift
//  APPaginator_Example
//
//  Created by Alexey Pak on 14/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import APPaginator

class FakeAPI {

	static let shared = FakeAPI()
	static var internetIsON: Bool = true

	private init() {  }

	func fakes(at page: Int, handler: @escaping ((Result<PaginableResponse<Fake>>) -> Void)) -> Request {
		let reqest = Request()

		let ping = Double.random(in: 1.0...3.0).rounded()
		DispatchQueue.main.asyncAfter(deadline: .now() + ping, execute: {
			guard !reqest.canceled else {
				return
			}

			guard FakeAPI.internetIsON else {
				handler(.failure(error: NSError()))
				return
			}

			let fakes: [Fake] = (0..<30).map {
				let id = page * 100 + $0
				return Fake(id: id, name: "Fake #\(id)")
			}

			let response = PaginableResponse<Fake>(currentPage: page, lastPage: 10, data: fakes)
			handler(.success(data: response))
		})

		return reqest
	}

}

enum Result<T> {
	case success(data: T), failure(error: Error)
}

class Request: Cancelable {

	fileprivate var canceled: Bool = false

	func cancel() {
		canceled = true
	}

}
