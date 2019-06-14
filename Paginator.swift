import Foundation

public class Paginator<Delegate: PaginatorDelegate> {

	private let firstPage = 0
	private var loadedPages: Int = 0
	private var lastPage: Int = Int.max

	public private(set) var state: PaginatorState = .empty {
		didSet {
			delegate?.paginator(self, didChangeState: state, items: items)
		}
	}
	public private(set) var items: [Delegate.ItemType] = []

	private var request: Cancelable?

	public weak var delegate: Delegate?

	public init() { }

	private func loadData(at page: Int) {
		request?.cancel()
		request = delegate?.paginator(
			self,
			itemsAtPage: page,
			resultBlock: { [weak self] lastPage, data in
				self?.lastPage = lastPage
				self?.didLoadNewData(data)
			}, errorBlock: { [weak self] error in
				self?.didFailFetchData(error)
			}
		)
	}

	public func apply(command: PaginatorCommand) {
		if delegate == nil {
			return
		}

		switch command {
		case .refresh:
			refresh()
		case .loadNextPage:
			loadNextPage()
		}
	}

	private func refresh() {
		switch state {
		case .empty, .emptyError, .emptyData:
			loadData(at: firstPage)
			state = .emptyProgress
		case .emptyProgress, .refresh:
			break
		case .data, .dataProgress, .dataAll, .dataError:
			loadData(at: firstPage)
			state = .refresh
		}
	}

	private func loadNextPage() {
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

	private func didLoadNewData(_ data: [Delegate.ItemType]) {
		switch state {
		case .empty, .emptyError, .emptyData, .data, .dataAll, .dataError:
			break
		case .emptyProgress, .dataProgress:
			loadedPages += 1

			if data.isEmpty || loadedPages == lastPage {
				items.append(contentsOf: data)
				state = .dataAll
			} else {
				items.append(contentsOf: data)
				state = .data
			}
		case .refresh:
			if data.isEmpty {
				state = .emptyData
			} else {
				loadedPages = firstPage + 1
				items.removeAll()
				items.append(contentsOf: data)
				state = .data
			}
		}
	}

	private func didFailFetchData(_ error: Error) {
		switch state {
		case .empty, .emptyError, .emptyData:
			break
		case .emptyProgress:
			state = .emptyError
		case .data, .dataAll, .dataError:
			break
		case .dataProgress:
			state = .dataError
		case .refresh:
			break
		}
	}

}

public enum PaginatorCommand {
	case refresh, loadNextPage
}

public enum PaginatorState {
	case empty, emptyProgress, emptyError, emptyData
	case data, dataProgress, dataError, dataAll
	case refresh
}

public protocol PaginatorDelegate: class {

	associatedtype ItemType

	func paginator(
		_ paginator: Paginator<Self>,
		itemsAtPage page: Int,
		resultBlock: @escaping ((_ lastPage: Int, _ items: [ItemType]) -> Void),
		errorBlock: @escaping ((Error) -> Void)
	) -> Cancelable

	func paginator(
		_ paginator: Paginator<Self>,
		didChangeState state: PaginatorState,
		items: [ItemType]
	)

}

public protocol Cancelable {

    func cancel()

}
