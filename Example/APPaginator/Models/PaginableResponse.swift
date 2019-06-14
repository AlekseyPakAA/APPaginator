//
//  PaginationResponse.swift
//  Wipon
//
//  Created by Alexey Pak on 20/01/2019.
//  Copyright © 2019 Wipon. All rights reserved.
//

import Foundation

struct PaginableResponse<T> {

	let currentPage: Int
	let lastPage: Int

	let data: [T]

}
