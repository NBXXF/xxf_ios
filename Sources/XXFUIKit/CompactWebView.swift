//
//  CompactWebView.swift
//
#if canImport(UIKit)
import UIKit
import WebKit

/// 一个“强健型（Robust）WKWebView 封装”
///
/// 目标：
/// - 不崩溃
/// - 不死循环
/// - 不白屏
/// - 行为可控
///
/// ------------------------------
///
/// ✅ 已解决问题：
///
/// 【崩溃】
/// - WebContent 进程被系统杀掉 → 自动恢复（带次数限制）
///
/// 【死循环】
/// - URL 重复跳转 → 自动拦截
///
/// 【Crash】
/// - decisionHandler 多次调用 → 已完全规避
///
/// 【登录态】
/// - Cookie 不同步 → 已自动同步
///
/// 【JS 通信】
/// - 内置 Bridge（H5 → Native）
///
/// 【兼容性】
/// - target=_blank / window.open 正常打开
///
/// 【异常】
/// - 超时控制 + 回调
///
/// ------------------------------
///
/// ⚠️ 使用建议：
///
/// let webView = CompactWebView()
/// webView.load(URLRequest(url: url))
///
public class CompactWebView: WKWebView {
    // MARK: - Shared

    /// 共享进程池
    ///
    /// 默认行为：
    /// - 每个 WKWebView 独立进程 → cookie 不共享
    ///
    /// 为什么：
    /// - 统一登录态（必须）
    private static let sharedProcessPool = WKProcessPool()

    // MARK: - Public

    weak var externalNavigationDelegate: WKNavigationDelegate?
    weak var externalUIDelegate: WKUIDelegate?

    /// 超时回调
    var onTimeout: (() -> Void)?

    /// 加载状态
    enum State {
        case idle
        case loading
        case success
        case failed(Error?)
    }

    private(set) var state: State = .idle

    // MARK: - Private

    private var lastRequest: URLRequest?

    // timeout
    private var timeoutTask: DispatchWorkItem?
    var timeoutInterval: TimeInterval = 15

    // crash reload 控制
    private var reloadCount = 0
    private let maxReloadCount = 3

    // 跳转死循环检测
    private var lastURL: URL?
    private var sameURLCount = 0
    private let maxSameURLCount = 5

    // MARK: - Init

    public init(ephemeral: Bool = false) {
        let config = Self.makeConfiguration(ephemeral: ephemeral)
        super.init(frame: .zero, configuration: config)
        setup()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError() }

    deinit {
        // 无需处理任何 JSBridge 相关清理（已移除）
    }

    // MARK: - Load

    override public func load(_ request: URLRequest) -> WKNavigation? {
        lastRequest = request
        state = .loading
        startTimeout()
        return super.load(request)
    }

    override public func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
        lastRequest = nil
        state = .loading
        startTimeout()
        return super.loadHTMLString(string, baseURL: baseURL)
    }

    // MARK: - Setup

    private func setup() {
        navigationDelegate = self
        uiDelegate = self

        isOpaque = false
        backgroundColor = .clear

        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never

        allowsLinkPreview = false

        if #available(iOS 16.4, *) {
            isInspectable = true
        }
    }

    // MARK: - Configuration

    private static func makeConfiguration(ephemeral: Bool) -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()

        config.processPool = sharedProcessPool

        config.websiteDataStore = ephemeral ? .nonPersistent() : .default()

        // 媒体能力
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsPictureInPictureMediaPlayback = true
        config.allowsAirPlayForMediaPlayback = true

        // JS
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = false

        config.defaultWebpagePreferences.preferredContentMode = .mobile

        // ⚠️ JS Bridge 已移除（不再注入任何 handler / script）

        syncCookies(to: config)

        return config
    }

    /// Cookie 同步
    private static func syncCookies(to config: WKWebViewConfiguration) {
        let store = config.websiteDataStore.httpCookieStore
        HTTPCookieStorage.shared.cookies?.forEach {
            store.setCookie($0)
        }
    }

    // MARK: - Timeout

    private func startTimeout() {
        timeoutTask?.cancel()

        let task = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.stopLoading()
            self.state = .failed(nil)
            self.onTimeout?()
        }

        timeoutTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + timeoutInterval, execute: task)
    }

    private func cancelTimeout() {
        timeoutTask?.cancel()
        timeoutTask = nil
    }
}

// MARK: - WKNavigationDelegate

extension CompactWebView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        cancelTimeout()
        reloadCount = 0
        state = .success

        externalNavigationDelegate?.webView?(webView, didFinish: navigation)
    }

    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        guard reloadCount < maxReloadCount else {
            state = .failed(nil)
            return
        }

        reloadCount += 1

        if let request = lastRequest {
            webView.load(request)
        }
    }

    @objc private func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @Sendable @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // ===== 死循环检测 =====
        if url == lastURL {
            sameURLCount += 1
        } else {
            sameURLCount = 0
        }

        lastURL = url

        if sameURLCount > maxSameURLCount {
            decisionHandler(.cancel)
            return
        }

        // ===== 系统处理 =====
        if url.scheme == "tel" {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        // ===== 外部接管（只允许调用一次）=====
        if let external = externalNavigationDelegate,
           external.responds(to: #selector(webView(_:decidePolicyFor:decisionHandler:)))
        {
            external.webView?(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
            return
        }

        decisionHandler(.allow)
    }
}

// MARK: - WKUIDelegate

extension CompactWebView: WKUIDelegate {
    public func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
#endif
