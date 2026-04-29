根因：MMKV 2.4.0 的 swift-tools-version: 6.2 触发了整个工作区使用 Xcode 26 的 Explicit Modules，而 SDImageWebPCoder.m 的三级 fallback 在此模式下全部失效：


1. 关 Xcode → rm -rf ~/Library/Developer/Xcode/DerivedData/nexus-* → 重开 → File → Packages → Reset Package Caches → Resolve。
2. 仍报错的话，在 App target 加 User-Defined Setting：_EXPERIMENTAL_SWIFT_EXPLICIT_MODULES = NO 和 CLANG_ENABLE_EXPLICIT_MODULES = NO（或改用 CLANG_ENABLE_MODULES = YES 搭配禁用显式模块）。
3. 根治方案：fork libwebp-Xcode，在 include/ 里放一个 libwebp.h umbrella header 并改 modulemap 为 umbrella header "libwebp.h"；或把 SDWebImageWebPCoder 改回 CocoaPods 集成。