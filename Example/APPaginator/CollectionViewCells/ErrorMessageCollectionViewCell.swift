
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
