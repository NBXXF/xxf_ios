//
//  LogViewController.swift
//  xxf_ios
//  日志界面
//  Created by trl on 2025/5/30.
//

import PulseUI
import SwiftUI

public class LogViewController: NSHostingController<ConsoleView> {
    public init() {
        super.init(rootView: ConsoleView())
    }

    @available(*, unavailable)
    @MainActor @preconcurrency public dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
