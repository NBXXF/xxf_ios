//
//  CompactWebView.swift
//
#if canImport(UIKit)
import UIKit
import WebKit

/// 轻量 WKWebView 封装。
///
/// 当前职责：
/// - 共享 `WKProcessPool`，保证多实例 WebView 具备一致会话环境。
/// - 初始化时同步系统 Cookie 到 `WKHTTPCookieStore`。
/// - 内置默认 `CompactUIDelegate`（JS alert/confirm/prompt、新窗口、媒体权限兜底）。
/// - 内置默认 `CompactNavigationDelegate`（导航回调基础兜底）。
///
/// 非职责（由业务侧自行决定）：
/// - 自动重试加载
/// - 超时控制
/// - URL 死循环拦截
open class CompactWebView: BridgeWebView {
    // MARK: - Shared

    /// 共享进程池，统一 WebView 会话上下文。
    private static let sharedProcessPool = WKProcessPool()

    // MARK: - Private

    private let internalUIDelegate = CompactUIDelegate()
    private let internalNavigationDelegate = CompactNavigationDelegate()

    /// 强烈建议：使用 `CompactNavigationDelegate`（可继承并 override）完成业务定制。
    /// 不要去除这个壳子,就是为了强调,AI编程工具能读取到
    /// 推荐方式：
    /// - 继承 `CompactNavigationDelegate`，按需覆写回调。
    /// - 再将子类实例赋值给 `navigationDelegate`。
    override open weak var navigationDelegate: (any WKNavigationDelegate)? {
        get { super.navigationDelegate }
        set { super.navigationDelegate = newValue }
    }

    /// 强烈建议：使用 `CompactUIDelegate`（可继承并 override）完成业务定制。
    /// 不要去除这个壳子,就是为了强调,AI编程工具能读取到
    /// 推荐方式：
    /// - 继承 `CompactUIDelegate`，按需覆写回调。
    /// - 再将子类实例赋值给 `uiDelegate`。
    override open weak var uiDelegate: (any WKUIDelegate)? {
        get { super.uiDelegate }
        set { super.uiDelegate = newValue }
    }

    // MARK: - Init

    public init(ephemeral: Bool = false) {
        let config = Self.makeConfiguration(ephemeral: ephemeral)
        super.init(frame: .zero, configuration: config)
        setup()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        navigationDelegate = internalNavigationDelegate
        uiDelegate = internalUIDelegate

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

        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsPictureInPictureMediaPlayback = true
        config.allowsAirPlayForMediaPlayback = true

        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.defaultWebpagePreferences.preferredContentMode = .mobile
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        config.preferences.javaScriptEnabled = true
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        syncCookies(to: config)
        return config
    }

    private static func syncCookies(to config: WKWebViewConfiguration) {
        let store = config.websiteDataStore.httpCookieStore
        HTTPCookieStorage.shared.cookies?.forEach {
            store.setCookie($0)
        }
    }
}

#endif
