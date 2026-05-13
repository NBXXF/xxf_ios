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
