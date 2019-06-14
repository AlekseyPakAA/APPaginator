//
//  ActivityIndicatorLargeCollectionViewCell.swift
//  APPaginator_Example
//
//  Created by Alexey Pak on 14/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class ActivityIndicatorLargeCollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	override func prepareForReuse() {
		super.prepareForReuse()

		activityIndicator.startAnimating()
	}

}
