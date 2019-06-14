//
//  UICollectionView+Reusable.swift
//  APPaginator_Example
//
//  Created by Alexey Pak on 14/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {

	func register<T: UICollectionViewCell>(_: T.Type) {
		if let nib = T.nib {
			self.register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
		} else {
			self.register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
		}
	}

	func register<T: UICollectionReusableView>(_ : T.Type, kind: String) {
		if let nib = T.nib {
			self.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
		} else {
			self.register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
		}
	}

	func dequeueReusableCell<T: UICollectionViewCell>(_: T.Type, for indexPath: IndexPath) -> T {
		guard let cell = self.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
			fatalError("Unable to dequeue reusable cell with reuse identifier \(T.reuseIdentifier)")
		}

		return cell
	}
	// swiftlint:disable line_length
	func dequeueReusableSupplementaryView<T: UICollectionReusableView>(_: T.Type, kind: String, for indexPath: IndexPath) -> T {
		guard let view = self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
			fatalError("Unable to dequeue reusable view with reuse identifier \(T.reuseIdentifier)")
		}

		return view
	}
	// swiftlint:enable line_length
}
