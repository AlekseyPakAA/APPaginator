//
//  ViewController.swift
//  APPaginator
//
//  Created by AlekseyPakAA on 06/13/2019.
//  Copyright (c) 2019 AlekseyPakAA. All rights reserved.
//

import UIKit
import APPaginator
import DeepDiff

final class ViewController: UICollectionViewController {

	enum Item: DiffAware {
		typealias DiffId = String

		var diffId: String {
			switch self {
			case .activityIndicator:
				return ".activityIndicator"
			case .activityIndicatorLarge:
				return ".activityIndicatorLarge"
			case .errorMessage:
				return ".errorMessage"
			case .errorMessageLarge:
				return ".activityIndicator"
			case .fake(let model):
				return ".fake\(model.id)"
			}
		}

		static func compareContent(_ a: ViewController.Item, _ b: ViewController.Item) -> Bool {
			return a.diffId == b.diffId
		}

		case activityIndicator
		case activityIndicatorLarge
		case errorMessage
		case errorMessageLarge
		case fake(model: Fake)
	}

	private var items: [Item] = []
	private let paginator = Paginator<ViewController>()

	override func viewDidLoad() {
		super.viewDidLoad()

		setup()

		paginator.apply(command: .loadNextPage)
	}

	override func collectionView(
		_ collectionView: UICollectionView,
		numberOfItemsInSection section: Int
	) -> Int {
		return items.count
	}

	override func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		switch items[indexPath.item] {
		case .activityIndicator:
			return collectionView.dequeueReusableCell(
				ActivityIndicatorCollectionViewCell.self,
				for: indexPath
			)
		case .activityIndicatorLarge:
			return collectionView.dequeueReusableCell(
				ActivityIndicatorLargeCollectionViewCell.self,
				for: indexPath
			)
		case .errorMessage, .errorMessageLarge:
			let cell = collectionView.dequeueReusableCell(
				ErrorMessageCollectionViewCell.self,
				for: indexPath
			)
			cell.delegate = self
			return cell
		case .fake(let model):
			let cell = collectionView.dequeueReusableCell(
				FakeCollectionViewCell.self,
				for: indexPath
			)
			cell.configure(model: model)
			return cell
		}
	}

}

private extension ViewController {

	func setup() {
		setupPaginator()
		setupCollectionView()
	}

	func setupCollectionView() {
		collectionView?.register(ActivityIndicatorCollectionViewCell.self)
		collectionView?.register(ActivityIndicatorLargeCollectionViewCell.self)
		collectionView?.register(ErrorMessageCollectionViewCell.self)
		collectionView?.register(FakeCollectionViewCell.self)

		collectionView?.delegate = self

		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(
			self,
			action: #selector(refreshWeatherData(_:)),
			for: .valueChanged
		)
		collectionView?.refreshControl = refreshControl
	}

	@objc private func refreshWeatherData(_ sender: UIRefreshControl) {
		paginator.apply(command: .refresh)
	}

	func setupPaginator() {
		 paginator.delegate = self
	}

	@IBAction func didTouchToggleInternetButton(sender: UIBarButtonItem) {
		if FakeAPI.internetIsON {
			FakeAPI.internetIsON = false
			sender.title = "Internet ON"
		} else {
			FakeAPI.internetIsON = true
			sender.title = "Internet OFF"
		}
	}

}

extension ViewController: PaginatorDelegate {

	typealias ItemType = Fake

	func paginator(
		_ paginator: Paginator<ViewController>,
		itemsAtPage page: Int,
		resultBlock: @escaping ((Int, [Fake]) -> Void),
		errorBlock: @escaping ((Error) -> Void)
	) -> Cancelable {
		return FakeAPI.shared.fakes(at: page) {
			switch $0 {
			case .success(let data):
				resultBlock(data.lastPage, data.data)
			case .failure(let error):
				errorBlock(error)
			}
		}
	}

	func paginator(
		_ paginator: Paginator<ViewController>,
		didChangeState state: PaginatorState,
		items: [Fake]
	) {
		let newItems: [Item]

		print(paginator.state)

		switch state {
		case .empty:
			newItems = []
		case .emptyProgress:
			newItems = [.activityIndicatorLarge]
		case .emptyError:
			newItems = [.errorMessageLarge]
		case .emptyData:
			newItems = []
		case .data, .dataAll, .refresh:
			newItems = items.map { .fake(model: $0) }
		case .dataProgress:
			newItems = items.map { .fake(model: $0) } + [.activityIndicator]
		case .dataError:
			newItems = items.map { .fake(model: $0) } + [.errorMessage]
		}

		if state != .refresh {
			collectionView?.refreshControl?.endRefreshing()
		}

		let changes = diff(old: self.items, new: newItems)
		collectionView?.reload(changes: changes, updateData: {
			self.items = newItems
		})
	}

}

extension ViewController: UICollectionViewDelegateFlowLayout {

	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath
	) -> CGSize {
		var size = collectionView.bounds.size
		size.height -= topLayoutGuide.length + bottomLayoutGuide.length

		let item = items[indexPath.item]

		switch item {
		case .activityIndicatorLarge, .errorMessageLarge:
			break
		case .errorMessage, .fake, .activityIndicator:
			size.height = 68.0
		}

		return size
	}

	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		switch paginator.state {
		case .data:
			let visibleAreaHeight = scrollView.frame.height - (topLayoutGuide.length + bottomLayoutGuide.length)
			let normalizedContentOffset = scrollView.contentOffset.y + scrollView.frame.height - bottomLayoutGuide.length

			if normalizedContentOffset >= scrollView.contentSize.height - visibleAreaHeight {
				paginator.apply(command: .loadNextPage)
			}
		default:
			break
		}
	}

}

extension ViewController: ErrorMessageCollectionViewCellDelegate {

	func didTouchTryAgainButton(sender: ErrorMessageCollectionViewCell) {
		paginator.apply(command: .loadNextPage)
	}

}
