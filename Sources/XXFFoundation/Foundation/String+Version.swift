//
//  String+Version.swift
//  xxf_ios
//
//  Created by xxf on 2019/3/24.
//

public extension String {
    /// 将 App 版本号（字符串）转换为 Int，用于排序 / 上报（非严格语义版本比较）
    ///
    /// ## 🎯 设计目标
    /// - 提供一个稳定的“可排序版本号”
    /// - 用于埋点上报、简单版本对比（如 ABTest / 灰度）
    /// - 对异常格式具备容错能力（不会 crash）
    ///
    /// ## ✅ 支持的版本格式
    /// 以下格式都可以正确解析：
    ///
    /// - "1.2.3"            → 10203
    /// - "1.2"              → 10200（自动补 0）
    /// - "1"                → 10000
    /// - "1.2.3.4"          → 10203（只取前三段）
    /// - "1.2.3-beta"       → 10203（忽略非数字后缀）
    /// - "v1.2.3"           → 10203（忽略前缀字符）
    /// - "1..2"             → 10002（空段按 0 处理）
    /// - "1.02.003"         → 10203（自动转 Int）
    ///
    /// ## ⚠️ 设计约束（非常重要）
    ///
    /// - 仅支持前三段：major.minor.patch
    /// - 每一段最大为 99（超过会被 clamp）
    /// - 计算规则：
    ///
    ///     major * 10000 + minor * 100 + patch
    ///
    /// 示例：
    ///
    ///     1.2.3 → 1*10000 + 2*100 + 3 = 10203
    ///
    /// ## ❗ 注意事项（限制）
    ///
    /// - 不适用于严格语义版本比较（如 1.10 vs 1.2）
    ///   👉 请使用：
    ///
    ///     versionA.compare(versionB, options: .numeric)
    ///
    /// - 如果版本号某一段 >= 100：
    ///
    ///     "1.2.100" → 10299（被限制为 99）
    ///
    ///   👉 这是为了保证排序稳定性，避免数值冲突
    ///
    /// - 非数字字符只解析“前缀数字”：
    ///
    ///     "1.2.beta" → 10200
    ///
    /// - 超过三段的版本号会被截断：
    ///
    ///     "1.2.3.4" → 10203
    ///
    /// ## 🚀 推荐使用场景
    ///
    /// - Firebase / 埋点上报（数值字段）
    /// - 简单版本排序
    /// - 灰度发布判断（轻量级）
    ///
    /// ## ❌ 不推荐场景
    ///
    /// - 精确版本比较（请用 `.numeric compare`）
    /// - 复杂语义版本（如 pre-release / build metadata）
    ///
    /// ## 💡 最佳实践
    ///
    /// 建议同时上报：
    ///
    ///     "app_version": "1.2.3"
    ///     "app_version_int": 10203
    ///
    ///
    /// ---
    func toAppVersionInt() -> Int {
        // 1️⃣ 按 "." 拆分（保留空段）
        let parts = self.split(separator: ".", omittingEmptySubsequences: false)

        // 2️⃣ 提取每一段中的“第一个数字序列”
        let numbers: [Int] = parts.map { segment in
            let str = String(segment)

            // 用正则提取第一个数字（比 prefix 更强）
            let match = str.range(of: #"\d+"#, options: .regularExpression)
            if let match = match {
                return Int(str[match]) ?? 0
            }
            return 0
        }

        // 3️⃣ 取前三段（不足补 0）
        let major = numbers.count > 0 ? numbers[0] : 0
        let minor = numbers.count > 1 ? numbers[1] : 0
        let patch = numbers.count > 2 ? numbers[2] : 0

        // 4️⃣ clamp（避免破坏结构）
        let safeMajor = min(major, 99)
        let safeMinor = min(minor, 99)
        let safePatch = min(patch, 99)

        // 5️⃣ 转 Int
        return safeMajor * 10000 + safeMinor * 100 + safePatch
    }
}
