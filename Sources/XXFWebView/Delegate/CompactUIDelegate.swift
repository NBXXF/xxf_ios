//
//  CompactUIDelegate.swift
//  xxf_ios
//
//  Created by xxf on 5/13.
//
#if canImport(UIKit)
import AVFoundation
import UIKit
import WebKit

/// CompactWebView 的默认 WKUIDelegate 实现。
///
/// 设计目标：
/// - 提供「开箱可用」的 Web UI 兜底行为，避免调用方每次重复实现。
/// - 把 H5 常见交互（弹窗 / 新窗口 / 媒体权限）收敛在一处，减少分散逻辑。
///
/// 主要覆盖的问题：
/// 1) JS 弹窗丢失或脚本阻塞
///    - H5 调用 alert / confirm / prompt 时，如果 delegate 没处理，常见现象是：
///      不弹窗、逻辑停在等待返回值、页面交互异常。
///    - 本类保证三种回调都有 completion，避免「等待不返回」导致的挂起。
///
/// 2) target=_blank / window.open 无响应
///    - 默认 WKWebView 对新窗口请求可能不自动打开，用户看起来像“点了没反应”。
///    - 这里把请求回灌到当前 webView.load(...)，保证主流程可继续。
///
/// 3) getUserMedia 权限决策不一致
///    - 相机/麦克风请求需要明确 grant / prompt（必要时 deny）。
///    - 这里统一按系统授权状态返回，避免页面拿到不稳定结果。
///
/// 4) 设备方向/运动权限
///    - WebKit 在 iOS 15+ 会触发该回调；统一返回 prompt，让系统按标准流程处理。
///
/// 备注：
/// - 若业务需要自定义 UI（例如品牌化弹窗），可继承本类并 override 对应方法。
/// - presenter 获取优先使用 SwifterSwift 的 `parentViewController`，行为更可预期。
open class CompactUIDelegate: NSObject, WKUIDelegate {
    override public init() {
        super.init()
    }

    /// 处理 H5 的 `window.open` / `target=_blank`。
    ///
    /// 作用：
    /// - 把“新窗口请求”回灌到当前 webView，避免点击后无响应。
    open func webView(
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

    /// 处理 H5 的 `alert(...)`。
    ///
    /// 作用：
    /// - 保证 JS 弹窗可见并正确回调 completion，避免脚本挂住。
    open func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping @Sendable () -> Void
    ) {
        guard let presenter = webView.parentViewController else {
            completionHandler()
            return
        }

        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })
        presenter.present(alert, animated: true)
    }

    /// 处理 H5 的 `confirm(...)`。
    ///
    /// 作用：
    /// - 返回 true / false 给 JS，保证页面条件分支能继续执行。
    open func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping @Sendable (Bool) -> Void
    ) {
        guard let presenter = webView.parentViewController else {
            completionHandler(false)
            return
        }

        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        })
        presenter.present(alert, animated: true)
    }

    /// 处理 H5 的 `prompt(...)`。
    ///
    /// 作用：
    /// - 给 JS 返回输入字符串（或 nil），避免输入型流程异常。
    open func webView(
        _ webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping @Sendable (String?) -> Void
    ) {
        guard let presenter = webView.parentViewController else {
            completionHandler(defaultText)
            return
        }

        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(nil)
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(alert.textFields?.first?.text)
        })
        presenter.present(alert, animated: true)
    }

    /// iOS 15+ 媒体采集权限（相机/麦克风）。
    ///
    /// 作用：
    /// - 给 WebKit 明确权限决策，避免 getUserMedia 结果不稳定。
    /// - 已授权返回 grant；未授权返回 prompt，由系统走标准授权弹窗。
    @available(iOS 15.0, *)
    open func webView(
        _ webView: WKWebView,
        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        type: WKMediaCaptureType,
        decisionHandler: @escaping (WKPermissionDecision) -> Void
    ) {
        switch type {
        case .camera:
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            decisionHandler(status == .authorized ? .grant : .prompt)
        case .microphone:
            let status = AVCaptureDevice.authorizationStatus(for: .audio)
            decisionHandler(status == .authorized ? .grant : .prompt)
        case .cameraAndMicrophone:
            let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
            let micStatus = AVCaptureDevice.authorizationStatus(for: .audio)
            decisionHandler((cameraStatus == .authorized && micStatus == .authorized) ? .grant : .prompt)
        @unknown default:
            decisionHandler(.prompt)
        }
    }

    /// iOS 15+ 设备方向与运动权限。
    ///
    /// 作用：
    /// - 统一返回 prompt，让系统决定是否展示权限流程。
    @available(iOS 15.0, *)
    open func webView(
        _ webView: WKWebView,
        requestDeviceOrientationAndMotionPermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        decisionHandler: @escaping (WKPermissionDecision) -> Void
    ) {
        decisionHandler(.prompt)
    }
}
#endif
