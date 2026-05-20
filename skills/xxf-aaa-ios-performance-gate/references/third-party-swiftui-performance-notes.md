# Third-Party SwiftUI Performance Notes

来源仓库：
- https://github.com/dpearson2699/swift-ios-skills/tree/main/skills/swiftui-performance

吸收文件：
- `SKILL.md`
- `references/demystify-swiftui-performance-wwdc23.md`
- `references/optimizing-swiftui-performance-instruments.md`
- `references/understanding-improving-swiftui-performance.md`
- `references/understanding-hangs-in-your-app.md`

沉淀到本地 skill 的关键能力：
1. Code-First → Profile → Analyze → Remediate → Verify 闭环
2. Long Updates 与 Frequent Updates 的分流诊断
3. identity/lifetime 稳定性规则
4. `Self._printChanges()` 调试辅助策略
5. Instruments 证据链（SwiftUI lanes + Time Profiler + Hangs）

本地优化项：
- 增加主动执行门禁（无需用户额外提示）
- 增加 Block/Warn/Pass 结论标准
- 扩展到 UIKit/启动链路/图片/并发等非 SwiftUI 场景
- 加入仓库可直接执行的最小验证命令
