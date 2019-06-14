//
//  FakeCollectionViewCell.swift
//  APPaginator_Example
//
//  Created by Alexey Pak on 14/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class FakeCollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var titleLabel: UILabel!

	func configure(model: Fake) {
		titleLabel.text = model.name
	}

}

