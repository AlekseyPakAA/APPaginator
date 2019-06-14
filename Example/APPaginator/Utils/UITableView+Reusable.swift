//
//  UITableView+Reusable.swift
//  Wipon
//
//  Created by Alexey Pak on 15/12/2018.
//  Copyright © 2018 Wipon. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {

	func register<T: UITableViewCell>(_: T.Type) {
		if let nib = T.nib {
			self.register(nib, forCellReuseIdentifier: T.reuseIdentifier)
		} else {
			self.register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
		}
	}

	func register<T: UITableViewHeaderFooterView>(_: T.Type) {
		if let nib = T.nib {
			self.register(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
		} else {
			self.register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
		}
	}

	func dequeueReusableCell<T: UITableViewCell>(_: T.Type, for indexPath: IndexPath) -> T {
		guard let cell = self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
			fatalError("Unable to dequeue reusable cell with reuse identifier \(T.reuseIdentifier)")
		}

		return cell
	}

	func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_: T.Type) -> T {
		guard let view = self.dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T else {
			fatalError("Unable to dequeue reusable view with reuse identifier \(T.reuseIdentifier)")
		}

		return view
	}

}
