
import Foundation
import UIKit

class ActivityIndicatorCollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	override func prepareForReuse() {
		super.prepareForReuse()

		activityIndicator.startAnimating()
	}

}
