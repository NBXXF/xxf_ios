/// 通用页面加载状态，用于驱动 UI 展示不同阶段的视图。
///
/// 用法示例：
/// ```swift
/// @Published var state: ViewState<[Item]> = .loading
///
/// func loadData() {
///     state = .loading
///     do {
///         let items = try await fetchItems()
///         state = .success(items)
///     } catch {
///         state = .error(error)
///     }
/// }
/// ```
///
/// 在视图层根据状态切换展示：
/// ```swift
/// switch viewModel.state {
/// case .loading:
///     showLoadingView()
/// case .success(let data):
///     showContent(data)
/// case .error(let error):
///     showErrorView(error)
/// case .completed:
///     showCompletedView()
/// }
/// ```
public enum ViewState<T>: ObsConvertible {
    /// 空闲中...
    case idle
    /// 加载中
    case loading
    /// 加载成功，携带数据
    case success(T)
    /// 加载失败，携带错误信息
    case error(Error)
    /// 流程已结束（如分页加载完毕、会话关闭等）
    case completed
}
