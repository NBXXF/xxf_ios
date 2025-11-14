//
//  LogViewController.swift
//  xxf_ios
//  日志界面
//  Created by xxfon 5/30.
//
import Pulse
import SwiftUI
#if os(macOS)
import AppKit
import PulseUI

public typealias BaseHostingController = NSHostingController<ConsoleView>
#else
import PulseUI
import UIKit

public typealias BaseHostingController = UIHostingController<ConsoleView>
#endif

public class LogViewController: BaseHostingController {
    public init(store: LoggerStore = .shared,
                mode: ConsoleMode = .all)
    {
        super.init(rootView: ConsoleView(store: store, mode: mode))
    }

    @available(*, unavailable)
    @MainActor @preconcurrency public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
