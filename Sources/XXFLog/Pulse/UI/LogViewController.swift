//
//  LogViewController.swift
//  xxf_ios
//  日志界面
//  Created by xxfon 5/30.
//
#if os(macOS)
import Pulse
import PulseUI
import SwiftUI

public class LogViewController: NSHostingController<ConsoleView> {
    public init(store: LoggerStore = .shared,
                mode: ConsoleMode = .all)
    {
        super.init(rootView: ConsoleView(store: store, mode: mode))
    }

    @available(*, unavailable)
    @MainActor @preconcurrency public dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
