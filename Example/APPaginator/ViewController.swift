//
//  ViewController.swift
//  APPaginator_Example
//
//  Created by Alexey Pak on 14/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
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
	private let paginator = Paginator<Fake>()

	override func viewDidLoad() {
		super.viewDidLoad()

		setup()

		paginator.loadNextPage()
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
		collectionView?.register(EmptyCollectionViewCell.self)
		collectionView?.delegate = self

		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(
			self,
			action: #selector(refreshData(_:)),
			for: .valueChanged
		)
		collectionView?.refreshControl = refreshControl
	}

	@objc private func refreshData(_ sender: UIRefreshControl) {
		paginator.refresh()
	}

	func setupPaginator() {

        paginator.requestClosure = { page, resultClosure in
            return FakeAPI.shared.fakes(at: page) {
                switch $0 {
                case .success(let data):
                    resultClosure(.success((data.lastPage, Items: data.data)))
                case .failure(let error):
                    resultClosure(.failure(error))
                }
            }
        }

        paginator.stateChangeClosure = { items, state in
            let newItems: [Item]

            switch state {
            case .empty:
                newItems = []
            case .emptyProgress:
                newItems = [.activityIndicatorLarge]
            case .emptyError:
                newItems = [.errorMessageLarge]
            case .emptyData:
                newItems = []
            case .dataAll:
                newItems = items.map { .fake(model: $0) }
            case .refresh:
                newItems = self.items
            case .data, .dataProgress:
                newItems = items.map { .fake(model: $0) } + [.activityIndicator]
            case .dataError:
                newItems = items.map { .fake(model: $0) } + [.errorMessage]
            }

            let isRefreshing = self.collectionView?.refreshControl?.isRefreshing ?? false
            if case .refresh = state {
                //do nothing
            } else if isRefreshing {
                self.collectionView?.refreshControl?.endRefreshing()
            }

            let changes = diff(old: self.items, new: newItems)
            self.collectionView?.reload(changes: changes, updateData: {
                self.items = newItems
            })
        }
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
			size.height = 100.0
		}

		return size
	}

	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		switch paginator.state {
		case .data:
			let visibleAreaHeight = scrollView.frame.height - (topLayoutGuide.length + bottomLayoutGuide.length)
			let normalizedContentOffset = scrollView.contentOffset.y + scrollView.frame.height - bottomLayoutGuide.length

			if normalizedContentOffset >= scrollView.contentSize.height - visibleAreaHeight {
				paginator.loadNextPage()
			}
		default:
			break
		}
	}

}

extension ViewController: ErrorMessageCollectionViewCellDelegate {

	func didTouchTryAgainButton(sender: ErrorMessageCollectionViewCell) {
		paginator.loadNextPage()
	}

}
