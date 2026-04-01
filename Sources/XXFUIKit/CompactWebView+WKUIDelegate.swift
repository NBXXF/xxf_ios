//
//  CompactWebView+WKUIDelegate.swift
//

#if canImport(UIKit)
import AVFoundation
import WebKit

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

    /// 处理网页权限请求,这种方式避免多次弹窗,代理到宿主, 但是h5 再其他浏览器依旧不行,是js用法问题
    public func webView(_ webView: WKWebView,
                        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                        initiatedByFrame frame: WKFrameInfo,
                        type: WKMediaCaptureType,
                        decisionHandler: @escaping (WKPermissionDecision) -> Void)
    {
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
}
#endif
