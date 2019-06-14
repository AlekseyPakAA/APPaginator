//
//  PaginationResponse.swift
//  APPaginator_Example
//
//  Created by Alexey Pak on 14/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

struct PaginableResponse<T> {

	let currentPage: Int
	let lastPage: Int

	let data: [T]

}
