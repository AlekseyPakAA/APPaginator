//
//  ViewController.swift
//  APPaginator
//
//  Created by AlekseyPakAA on 06/13/2019.
//  Copyright (c) 2019 AlekseyPakAA. All rights reserved.
//

import UIKit
import APPaginator

final class ViewController: UICollectionViewController {

    enum Item {
        case activityIndicator
        case activityIndicatorLarge
        case errorMessage
        case errorMessageLarge
        case repository
    }

    var items: [Item] = []
    let paginator = Paginator<ViewController>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
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
            //cell.delegate = self as! ErrorMessageCollectionViewCellDelegate
            return cell
        case .repository:
            let cell = collectionView.dequeueReusableCell(
                RepositoryCollectionViewCell.self,
                for: indexPath
            )
            //cell.configure(model: model)
            return cell
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        var size = collectionView.bounds.size
        let item = items[indexPath.item]

        switch item {
        case .activityIndicatorLarge, .errorMessageLarge:
            break
        case .activityIndicator, .errorMessage:
            size.height = 160.0
        case .repository:
            size.height = 48.0
        }

        return size
    }

}

private extension ViewController {

    func setup() {
        registerCells()
    }

    func registerCells() {
        collectionView?.register(ActivityIndicatorCollectionViewCell.self)
        collectionView?.register(ActivityIndicatorLargeCollectionViewCell.self)
        collectionView?.register(ErrorMessageCollectionViewCell.self)
        collectionView?.register(RepositoryCollectionViewCell.self)
    }

}

extension ViewController: PaginatorDelegate {

    typealias ItemType = Repository

    func paginator(
        _ paginator: Paginator<ViewController>,
        itemsAtPage page: Int,
        resultBlock: @escaping ((Int, [Repository]) -> Void),
        errorBlock: @escaping ((Error) -> Void)
    ) -> Cancelable {
        return self
    }

    func paginator(
        _ paginator: Paginator<ViewController>,
        didChangeState state: PaginatorState,
        items: [Repository]
    ) {

    }

}

extension ViewController: Cancelable {

    func cancel() {

    }

}
