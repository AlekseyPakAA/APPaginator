//
//  ErrorMessageCollectionViewCell.swift
//  APPaginator_Example
//
//  Created by Alexey Pak on 14/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

protocol ErrorMessageCollectionViewCellDelegate: class {

	func didTouchTryAgainButton(sender: ErrorMessageCollectionViewCell)

}

class ErrorMessageCollectionViewCell: UICollectionViewCell {

	weak var delegate: ErrorMessageCollectionViewCellDelegate?

	@IBAction func didTouchTryAgainButton(sender: UIButton) {
		delegate?.didTouchTryAgainButton(sender: self)
	}

}
