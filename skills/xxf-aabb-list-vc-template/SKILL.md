---
name: xxf-aabb-list-vc-template
description: 创建 XXF iOS 列表页模板（DiffableDataSource + BaseCollectionViewCell + StatefulView + 分页 ViewModel）
---

# XXF 列表页模板 Skill

## 适用场景

- 新建列表类 `ViewController`
- 使用 `UICollectionViewDiffableDataSource`
- Cell 继承 `BaseCollectionViewCell<Model>`
- 需要 `StatefulView`（loading / empty / error / content）
- 需要下拉刷新 + 上滑分页

## 强制约束

- `ViewController` 继承 `BaseViewController`
- `ViewModel` 继承 `NSObject, ViewModel`
- 数据源统一用 `UICollectionViewDiffableDataSource<SingleSection, Item>`
- Cell 统一用 `dequeueReusableCell(for:cellType:)`，并调用 `configure(with:payloads:)`
- 状态统一使用 `ViewState<[Item]>`
- 列表分页触发优先使用 `willDisplay`，不要和 `scrollViewDidScroll` 双触发
- `DiffableDataSource` 首次创建后应 `ensureSection(.main, animatingDifferences: false)`

## ViewController 模板

```swift
final class XxxListViewController: BaseViewController {
    private lazy var viewModel: XxxListViewModel = ViewModelProvider(owner: self).of(XxxListViewModel.self)
    private var statefulView: StatefulView!

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        return cv
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<SingleSection, ItemDTO> = {
        let ds = UICollectionViewDiffableDataSource<SingleSection, ItemDTO>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueReusableCell(for: indexPath, cellType: XxxCell.self).apply { cell in
                cell.configure(with: item, payloads: nil)
            }
        }
        ds.ensureSection(.main, animatingDifferences: false)
        return ds
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadData(isRefresh: true)
    }

    private func setupUI() {
        setupStatefulView()
        collectionView.addRefreshing { [weak self] in
            self?.viewModel.loadData(isRefresh: true)
        }
        collectionView.addLoadingMore { [weak self] in
            self?.viewModel.loadData(isRefresh: false)
        }
        view.addSubview(statefulView)
        statefulView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func setupStatefulView() {
        statefulView = StatefulView(contentView: collectionView) { [weak self] in
            self?.viewModel.loadData(isRefresh: true)
        }
        let emptyView = CommonEmptyView(title: "No data", message: "Please check back later.", buttonTitle: "Refresh")
        emptyView.onRetry = { [weak self] in self?.viewModel.loadData(isRefresh: true) }
        statefulView.setStateView(emptyView, for: .empty)
        let errorView = DefaultErrorView(title: "Something went wrong", message: "Please try again", buttonTitle: "Retry")
        errorView.onRetry = { [weak self] in self?.viewModel.loadData(isRefresh: true) }
        statefulView.setStateView(errorView, for: .error)
    }

    private func bindViewModel() {
        _ = viewModel.items
            .bindLifecycle(of: self)
            .observeOnMainIfNeeded()
            .subscribe(onNext: { [weak self] items in
                self?.dataSource.replaceItems(items, in: .main)
            })

        _ = viewModel.viewState
            .bindLifecycle(of: self)
            .observeOnMain()
            .subscribe(onNext: { [weak self] state in
                guard let self else { return }
                switch state {
                case .idle:
                    break
                case .loading:
                    // 仅首屏无数据时展示整页 loading，避免分页时闪回 loading 页
                    if self.dataSource.snapshot().numberOfItems == 0 {
                        self.statefulView.update(state: .loading)
                    }
                case .success(let items):
                    self.statefulView.update(state: items.isEmpty ? .empty : .content)
                case .error:
                    // 有历史数据时保留 content，仅依赖 toast/局部提示；无数据才切 error 页
                    if self.dataSource.snapshot().numberOfItems == 0 {
                        self.statefulView.update(state: .error)
                    }
                case .completed:
                    break
                }
            })

        _ = viewModel.refreshableState
            .bindLifecycle(of: self)
            .bind(to: collectionView.rx.refreshableState)
    }
}

extension XxxListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let total = dataSource.snapshot().numberOfItems
        guard total > 0, indexPath.item >= total - 3 else { return }
        viewModel.loadData(isRefresh: false)
    }
}
```

## Cell 模板

```swift
final class XxxCell: BaseCollectionViewCell<ItemDTO> {
    override func configure(with model: ItemDTO, payloads: [Any]?) {
        super.configure(with: model, payloads: payloads)
        // bind UI
    }
}
```

## ViewModel 模板

```swift
final class XxxListViewModel: NSObject, ViewModel {
    @LazyInjected(\\.xxxService) private var service

    let refreshableState = RefreshableState().obs
    let viewState: Obs<ViewState<[ItemDTO]>> = .init(value: .idle)
    let items: Obs<[ItemDTO]> = .init(value: [])

    private var page = 1
    private let limit = 20
    private var hasMore = true

    func loadData(isRefresh: Bool) {
        if case .loading = viewState.state { return }

        if isRefresh {
            page = 1
            hasMore = true
            viewState.state = .loading
        } else if !hasMore {
            return
        }

        _ = service.fetchList(page: page, limit: limit, cacheType: isRefresh ? .firstCache() : .onlyRemote)
            .bindRefreshableState(of: refreshableState, isRefresh: isRefresh)
            .bindErrorNotice()
            .observeOnMain()
            .bindUntilDeallocated(of: self)
            .doOnCompleted { [weak self] in
                self?.page += 1
            }
            .subscribe(onNext: { [weak self] response in
                guard let self else { return }
                self.hasMore = response.pagination.hasMore
                if isRefresh {
                    // 服务端偶发重复 ID，refresh / loadMore 都统一去重，避免 diffable crash
                    self.items.state = response.list.distinctBy(\\.id)
                } else {
                    self.items.state = (self.items.state + response.list).distinctBy(\\.id)
                }
                self.viewState.state = .success(self.items.state)
            }, onError: { [weak self] error in
                self?.viewState.state = .error(error)
            })
    }
}
```

## 反模式（禁止）

- 同时用 `scrollViewDidScroll` 和 `willDisplay` 触发分页
- 手动 `register(cellType:)` 后又使用 `dequeueReusableCell(for:cellType:)`
- 不绑定 `refreshableState`，导致刷新控件状态不同步
- 在 VC 里写分页状态机（`page/hasMore`），而不是放在 ViewModel
- refresh 路径不去重，导致 diffable 对重复 id 崩溃
