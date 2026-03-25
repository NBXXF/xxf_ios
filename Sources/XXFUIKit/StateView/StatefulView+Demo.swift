////
////  StatefulView+Demo.swift
////  xxf_ios
////
////  Created by xxf on 2026/3/25.
////
//#if canImport(UIKit)
//import UIKit
//
//// MARK: - StatefulView Usage Examples
//
///*
// ============================================================
// StatefulView 用法示例
// ============================================================
//
// StatefulView 是一个状态管理容器，结构如下：
//
// StatefulView
//  ├── contentView          // 常驻内容视图（如 CollectionView）
//  └── overlayView          // 遮罩层，动态切换状态
//        ├── loadingView    // 加载中
//        ├── emptyView      // 空数据
//        └── errorView      // 错误/重试
//
// 关键特性：
// - contentView 常驻，保证视频/滑动状态不丢失
// - 状态之间互斥，避免同时显示多个状态
// - 支持自定义状态视图
// - 支持动画切换
// - 类型化访问 emptyView/errorView
// */
//
//// MARK: - 1. 基础用法
//
//class BasicUsageExample {
//    func example1() {
//        // 创建 StatefulView，传入你的内容视图（如 UICollectionView）
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
//        let statefulView = StatefulView(contentView: collectionView)
//
//        // 设置重试回调
//        statefulView.onRetry = {
//            print("用户点击重试")
//            // 重新加载数据...
//        }
//
//        // 切换状态
//        statefulView.update(state: .loading) // 显示加载中
//        statefulView.update(state: .empty) // 显示空数据
//        statefulView.update(state: .error) // 显示错误
//        statefulView.update(state: .content) // 显示内容（隐藏所有状态）
//
//        // 禁用动画
//        statefulView.update(state: .loading, animated: false)
//
//        // 调整动画时长
//        statefulView.animationDuration = 0.3
//    }
//}
//
//// MARK: - 2. 类型化访问 emptyView/errorView
//
//class TypedAccessExample {
//    func example2() {
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
//        let statefulView = StatefulView(contentView: collectionView)
//
//        // 直接获取类型化的 emptyView
//        statefulView.emptyView?.title = "新标题"
//        statefulView.emptyView?.message = "新描述"
//        statefulView.emptyView?.onRetry = {
//            print("Empty view retry")
//        }
//
//        // 直接获取类型化的 errorView
//        statefulView.errorView?.title = "错误标题"
//        statefulView.errorView?.message = "错误描述"
//        statefulView.errorView?.onRetry = {
//            print("Error view retry")
//        }
//
//        // 使用默认视图的具体属性
//        if let emptyView = statefulView.emptyView as? DefaultEmptyView {
//            emptyView.buttonTitle = "去逛逛"
//            emptyView.showsButton = true
//            emptyView.buttonBackgroundColor = .systemBlue
//        }
//
//        if let errorView = statefulView.errorView as? DefaultErrorView {
//            errorView.image = UIImage(systemName: "wifi.slash")
//            errorView.showsImage = true
//        }
//    }
//}
//
//// MARK: - 3. 在 ViewController 中使用
//
//class MyViewController: UIViewController {
//    private var statefulView: StatefulView!
//    private var collectionView: UICollectionView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // 1. 创建内容视图
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
//        collectionView.dataSource = self
//        collectionView.delegate = self
//
//        // 2. 创建 StatefulView
//        statefulView = StatefulView(contentView: collectionView)
//        statefulView.onRetry = { [weak self] in
//            self?.loadData()
//        }
//
//        // 3. 添加到视图层次
//        view.addSubview(statefulView)
//        statefulView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            statefulView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            statefulView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            statefulView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            statefulView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//        ])
//
//        // 4. 加载数据
//        loadData()
//    }
//
//    private func loadData() {
//        statefulView.update(state: .loading)
//
//        // 模拟网络请求
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
//            guard let self = self else { return }
//
//            let success = Bool.random()
//            if success {
//                // 有数据
//                self.statefulView.update(state: .content)
//                self.collectionView.reloadData()
//            } else {
//                // 空数据或错误
//                self.statefulView.update(state: .empty)
//            }
//        }
//    }
//}
//
//// MARK: - UICollectionView DataSource (Stub)
//
//extension MyViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        return UICollectionViewCell()
//    }
//}
//
//extension MyViewController: UICollectionViewDelegate {}
//#endif
