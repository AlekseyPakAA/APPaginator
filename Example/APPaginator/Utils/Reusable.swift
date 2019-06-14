//
//  Reusable.swift
//  Wipon
//
//  Created by Alexey Pak on 15/12/2018.
//  Copyright © 2018 Wipon. All rights reserved.
//

import Foundation
import UIKit

protocol Reusable: class {

	static var reuseIdentifier: String { get }
	static var nib: UINib? { get }

}

extension Reusable {

	static var reuseIdentifier: String {
		return .init(describing: self)
	}

	static var nib: UINib? {
		return UINib(nibName: .init(describing: self), bundle: nil)
	}

}

extension UITableViewCell: Reusable {}
extension UICollectionReusableView: Reusable {}
extension UITableViewHeaderFooterView: Reusable {}
