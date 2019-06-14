
import Foundation
import UIKit

class ActivityIndicatorLargeCollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	override func prepareForReuse() {
		super.prepareForReuse()

		activityIndicator.startAnimating()
	}

}
