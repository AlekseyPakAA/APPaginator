//
//  ViewController.swift
//  APPaginator_Example
//
//  Created by Alexey Pak on 14/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

public class Paginator<ItemType> {

    public typealias RequestClosure = (_ page: Int, @escaping RequestResultClosure) -> Cancellable
    public typealias RequestResultClosure = (Result<(lastPage: Int, Items: [ItemType]), Error>) -> Void
    public typealias StateChangeClosure = (_ items: [ItemType] ,_ state: PaginatorState) -> Void

    private let firstPage: Int
    private var loadedPages: Int = 0
    private var lastPage: Int = Int.max

    public private(set) var state: PaginatorState = .empty {
        didSet { stateChangeClosure?(items, state) }
    }
    private(set) var items: [ItemType] = []

    private var request: Cancellable?

    public var requestClosure: RequestClosure?
    public var stateChangeClosure: StateChangeClosure?

    public init(startsFromPage page: Int = 1) {
        self.firstPage = page
    }

    public func refresh(_ force: Bool = false) {
        switch state {
        case .empty, .emptyError, .emptyData:
            loadData(at: firstPage)
            state = .refresh
        case .emptyProgress, .refresh:
            if force {
                loadData(at: firstPage)
                state = .refresh
            }
        case .data, .dataProgress, .dataAll, .dataError:
            loadData(at: firstPage)
            state = .refresh
        }
    }

    public func loadNextPage() {
        switch state {
        case .emptyError, .empty:
            loadData(at: firstPage)
            state = .emptyProgress
        case .emptyProgress, .emptyData:
            break
        case .data, .dataError:
            loadData(at: loadedPages + 1)
            state = .dataProgress
        case .dataProgress, .dataAll, .refresh:
            break
        }
    }

    private func loadData(at page: Int) {
        request?.cancel()

        var request: Cancellable?
        request = requestClosure?(page) { [weak self] result in
            guard !(request?.isCancelled ?? false) else {
                return
            }

            switch result {
            case .success(let lastPage, let data):
                self?.lastPage = lastPage
                self?.didLoadNewData(data)
            case .failure(let error):
                self?.didFailFetchData(error)
            }
        }

        self.request = request
    }

    private func didLoadNewData(_ data: [ItemType]) {
        switch state {
        case .empty, .emptyError, .emptyData, .data, .dataAll, .dataError:
            break
        case .emptyProgress, .dataProgress:
            items.append(contentsOf: data)
            loadedPages += 1

            if data.isEmpty || loadedPages == lastPage {
                state = .dataAll
            } else {
                state = .data
            }
        case .refresh:
            loadedPages = firstPage
            items.removeAll()
            items.append(contentsOf: data)

            if data.isEmpty {
                state = .emptyData
            } else {
                state = .data
            }
        }
    }

    private func didFailFetchData(_ error: Error) {
        switch state {
        case .empty, .emptyError, .emptyData:
            break
        case .emptyProgress:
            state = .emptyError(error: error)
        case .data, .dataAll, .dataError:
            break
        case .dataProgress:
            state = .dataError(error: error)
        case .refresh:
            if items.isEmpty {
                state = .emptyError(error: error)
            } else {
                state = .data
            }
        }
    }

}

public enum PaginatorState {
    case empty, emptyProgress, emptyError(error: Error), emptyData
    case data, dataProgress, dataError(error: Error), dataAll
    case refresh
}

public protocol Cancellable {

    var isCancelled: Bool { get }
    func cancel()

}
