//
//  BridgeWebView+Ext.swift
//  xxf_ios
//
//  Created by xxf on 5/14.
//

public extension BridgeWebView {
    /// 检查 H5 是否已注入 dsBridge SDK（仅检查 JS 包装对象）
    func checkBridgeSDKInjected(completion: @escaping (Bool) -> Void) {
        let js = """
        typeof window !== 'undefined' &&
        typeof window.dsBridge !== 'undefined' &&
        typeof window.dsBridge.call === 'function'
        """

        self.evaluateJavaScript(js) { result, error in
            guard error == nil else {
                completion(false)
                return
            }
            completion(result as? Bool ?? false)
        }
    }
}
