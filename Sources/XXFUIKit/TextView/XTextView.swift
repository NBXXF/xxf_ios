//
//  XTextView.swift
//  xxf_ios
//
//  Created by xxf
//

#if canImport(UIKit)
import SnapKit
import UIKit

/// 带 placeholder 的 `UITextView`。
///
/// 设计为可继承组件(`open class`),业务方可子类化扩展工具栏、字符计数、IME 钩子等行为。
///
/// ## 特性一览
/// - **纯文本 / 富文本占位**:`placeholder` 和 `attributedPlaceholder`,后者优先
/// - **跟随系统的占位色**:iOS 13+ 自动用 `UIColor.placeholderText`,正确适配 dark mode
/// - **IME 组合态不闪占位**:通过 `markedTextRange` 过滤拼音/假名/谚文候选态
/// - **VoiceOver 空态能读占位**:通过 `accessibilityValue` 而非独立 a11y 元素
/// - **空态 `intrinsicContentSize`**:按 placeholder 高度参与 AutoLayout,不再塌缩成一行
/// - **允许获焦开关**:`allowsFirstResponder = false` 做纯展示 / 权限未开场景
///
/// ## 对比参考实现
/// - `RSKPlaceholderTextView`:draw(_:) 直绘 + TextKit 2 caret 适配,代码量约 3x
/// - `KMPlaceholderTextView`:UILabel 子视图,缺 IME / a11y / RTL
/// - `devxoul/UITextView-Placeholder`:ObjC Category + dealloc swizzle 全局猴子补丁,
///   优势是不改类型、能给任意 `UITextView` 实例加占位
open class XTextView: UITextView {
    // MARK: - Public Config

    /// 控制该 TextView 是否允许成为 first responder。
    /// 设 `false` 可以让 textView 变成纯展示态,点击不拉起键盘。
    public var allowsFirstResponder: Bool = true

    /// 占位文案(纯文本路径)。
    ///
    /// 与 `attributedPlaceholder` 互斥:若 `attributedPlaceholder` 非空,以它为准;
    /// 此处只作为 `attributedPlaceholder == nil` 时的默认渲染文案。
    public var placeholder: String? {
        didSet {
            guard placeholder != oldValue else { return }
            refreshPlaceholderContent()
        }
    }

    /// 占位的富文本版本。非空时**优先**于纯文本 `placeholder` 渲染。
    ///
    /// 典型场景:红色星号 + 灰色提示词混排、字号/下划线/阴影等混排。
    /// 注意:富文本模式下颜色由 attributed string 自带的 `.foregroundColor` 属性决定,
    /// `placeholderColor` 不再生效。
    public var attributedPlaceholder: NSAttributedString? {
        didSet {
            refreshPlaceholderContent()
        }
    }

    /// 占位颜色(仅对 `placeholder` 纯文本路径生效)。
    ///
    /// 默认值 = `XTextView.defaultPlaceholderColor`,iOS 13+ 跟随系统
    /// `UIColor.placeholderText`,保证 dark mode 下对比度达到 WCAG 要求。
    ///
    /// 注意:这里用 `XTextView.` 而非 `Self.` —— `open class` 里 `Self` 是 covariant,
    /// 存储属性初始化表达式禁止引用(Swift: "Covariant 'Self' type cannot be
    /// referenced from a stored property initializer")。
    public var placeholderColor: UIColor = XTextView.defaultPlaceholderColor {
        didSet {
            // 只给纯文本 label 设 color;富文本的颜色由 AttributedString 自带,不覆盖。
            placeholderLabel.textColor = placeholderColor
        }
    }

    /// 占位行数(默认 1 行,保持与 Android EditText 类似的一行占位体验)。
    /// 设为 0 则按宽度自动换行、不限制行数。
    public var placeholderNumberOfLines: Int = 1 {
        didSet {
            placeholderLabel.numberOfLines = placeholderNumberOfLines
            invalidateIntrinsicContentSize()
        }
    }

    // MARK: - Self-Sizing Config

    /// 最小行数(含 placeholder 态)。设 > 1 会开启 growing,让视图按 minLines 撑高。
    ///
    /// 默认 1,不改变现有表现。
    public var minNumberOfLines: Int = 1 {
        didSet {
            guard minNumberOfLines != oldValue else { return }
            cachedSimulationWidth = -1
            refreshSizing()
        }
    }

    /// 最大行数。`0` 表示无上限。
    ///
    /// - `minNumberOfLines > 1 || maxNumberOfLines > 0` 时启用 growing:
    ///   - 文本未超过 max → `intrinsicContentSize` 按实际内容撑开,同时 `isScrollEnabled = false`
    ///   - 文本超过 max → 高度锁定在 max,`isScrollEnabled = true` 供内滚
    /// - 两者保持默认值则彻底不干预 `UITextView` 原生行为。
    public var maxNumberOfLines: Int = 0 {
        didSet {
            guard maxNumberOfLines != oldValue else { return }
            cachedSimulationWidth = -1
            if !isGrowingEnabled {
                // 关闭 growing 时恢复 UITextView 默认滚动能力
                isScrollEnabled = true
            }
            refreshSizing()
        }
    }

    /// `intrinsicContentSize.height` 变化时回调。
    ///
    /// 典型用法:外部父容器用此回调包一次 `UIView.animate { self.view.layoutIfNeeded() }`,
    /// 拿到高度变化的过渡动画。不用此回调也能正常工作(AutoLayout 已经会自动 relayout)。
    public var onHeightChange: ((CGFloat) -> Void)?

    /// 默认占位颜色:iOS 13+ 跟随系统 `UIColor.placeholderText`(自动深浅色);
    /// 更早版本退回 iOS 12 常见的 lightGray 等效值。
    ///
    /// 思路参考自 `devxoul/UITextView-Placeholder`。
    public static var defaultPlaceholderColor: UIColor {
        if #available(iOS 13.0, *) { return .placeholderText }
        return UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
    }

    // MARK: - Private Internals

    private let placeholderLabel = UILabel()
    private var placeholderLeadingConstraint: Constraint?
    private var placeholderTopConstraint: Constraint?
    private var placeholderTrailingConstraint: Constraint?
    private var lastPlaceholderInsets: (leading: CGFloat, top: CGFloat, trailing: CGFloat)?

    // MARK: - Self-Sizing Private State

    /// 仅当 `minNumberOfLines > 1` 或 `maxNumberOfLines > 0` 时启用 growing 逻辑,
    /// 默认保持 `UITextView` 原生表现。
    private var isGrowingEnabled: Bool { minNumberOfLines > 1 || maxNumberOfLines > 0 }

    /// 按当前 font / textContainerInset 预模拟 minNumberOfLines / maxNumberOfLines
    /// 对应的像素高度,绑定在一个特定宽度下,宽度没变则跳过重算。
    private var cachedResolvedMinHeight: CGFloat = 0
    private var cachedResolvedMaxHeight: CGFloat = .greatestFiniteMagnitude
    private var cachedSimulationWidth: CGFloat = -1

    /// 最近一次对外通报的高度,变化 > 0.5pt 才触发 `onHeightChange`。
    private var lastReportedHeight: CGFloat = -1

    // MARK: - UITextView Overrides

    override public var text: String! {
        didSet {
            updatePlaceholder()
            invalidateIntrinsicContentSize()
        }
    }

    override public var attributedText: NSAttributedString! {
        didSet {
            updatePlaceholder()
            invalidateIntrinsicContentSize()
        }
    }

    override public var font: UIFont? {
        didSet {
            // 富文本占位自带字号,不要用本 textView 的 font 覆盖;
            // 纯文本占位需要同步字号。
            if attributedPlaceholder == nil {
                placeholderLabel.font = font
            }
            // font 变化会影响单行 / min / max 高度,清缓存让下次 layout 重算
            cachedSimulationWidth = -1
            invalidateIntrinsicContentSize()
        }
    }

    override public var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }

    override public var textContainerInset: UIEdgeInsets {
        didSet {
            updatePlaceholderInsets()
            // 垂直 inset 变化影响空态 intrinsic 高度;也影响 simulateHeight
            cachedSimulationWidth = -1
            invalidateIntrinsicContentSize()
        }
    }

    /// 允许子类进一步定制"能否成为 first responder"的决策。
    override open var canBecomeFirstResponder: Bool {
        allowsFirstResponder && super.canBecomeFirstResponder
    }

    /// 空态 `intrinsicContentSize` 按 placeholder 尺寸计算。
    ///
    /// UITextView 原生 `intrinsicContentSize` 只考虑 `text`:空态下会塌缩到一行高甚至
    /// `noIntrinsicMetric`(取决于 `isScrollEnabled`),导致多行 placeholder 在
    /// AutoLayout 里撑不开、被截断。
    ///
    /// 处理策略(参考 `devxoul` 的空态撑高思路,但**只返回正确的 intrinsic size**,
    /// 不像它那样直接改 `self.frame` 或自加 height 约束 —— 那会侵入业务布局):
    /// - growing 开(min>1 或 max>0):`sizeThatFits` 实测内容高,与空态 placeholder 高取 max,
    ///   再 clamp 到 `[resolvedMin, resolvedMax]`
    /// - growing 关 + 有文本 → 走父类实现
    /// - growing 关 + 无文本 + 无占位 → 走父类实现
    /// - growing 关 + 无文本 + 有占位 → 按 placeholder 实际需要的高度返回
    override open var intrinsicContentSize: CGSize {
        // growing 开启且已首次 layout:统一走 clamp 路径,兼顾有文本 / 空态 placeholder
        if isGrowingEnabled, bounds.width > 0 {
            refreshResolvedHeightsIfNeeded()
            let contentH = sizeThatFits(
                CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
            ).height
            let candidate = max(contentH, emptyPlaceholderFittedHeight())
            let clamped = min(max(candidate, cachedResolvedMinHeight), cachedResolvedMaxHeight)
            return CGSize(width: UIView.noIntrinsicMetric, height: clamped)
        }

        // 原有 legacy 路径:仅处理空态 placeholder 撑高
        if hasText { return super.intrinsicContentSize }
        let placeholderHeight = emptyPlaceholderFittedHeight()
        if placeholderHeight <= 0 { return super.intrinsicContentSize }
        return CGSize(width: UIView.noIntrinsicMetric, height: placeholderHeight)
    }

    // MARK: - Init

    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPlaceholder()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlaceholder()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Layout

    /// 宽度变化会导致 placeholder 换行行数变化,进而影响空态 intrinsic 高度。
    /// 在 `layoutSubviews` 主动失效一次,让外层 AutoLayout 重新询问。
    ///
    /// 同时:growing 开启时,宽度变化也会影响 `resolvedMin/MaxHeight`,清缓存并再测一次。
    override open func layoutSubviews() {
        super.layoutSubviews()
        updatePlaceholderInsets()

        // 宽度变化 → 清 growing 缓存
        if isGrowingEnabled, abs(cachedSimulationWidth - bounds.width) > 0.5 {
            cachedSimulationWidth = -1
            refreshSizing()
            return
        }

        if !hasText { invalidateIntrinsicContentSize() }
    }

    // MARK: - Setup

    private func setupPlaceholder() {
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.font = font
        placeholderLabel.textAlignment = textAlignment
        placeholderLabel.numberOfLines = placeholderNumberOfLines
        // 屏蔽 hit-test,避免 placeholder 抢占 UITextView 的输入手势。
        placeholderLabel.isUserInteractionEnabled = false
        // 屏蔽独立 a11y 元素;placeholder 的可访问性通过 self.accessibilityValue 暴露
        // (见 updatePlaceholder)—— 这是 UITextField 的系统行为,保持一致性。
        placeholderLabel.isAccessibilityElement = false

        addSubview(placeholderLabel)
        // 用 leading/trailing 而非 left/right:RTL 环境下 AutoLayout 原生镜像,
        // 阿拉伯 / 希伯来 UI 中 placeholder 自动贴右侧 —— 零代码拿到 RTL 正确性。
        placeholderLabel.snp.makeConstraints { make in
            placeholderLeadingConstraint = make.leading.equalToSuperview().offset(0).constraint
            placeholderTopConstraint = make.top.equalToSuperview().offset(0).constraint
            placeholderTrailingConstraint = make.trailing.lessThanOrEqualToSuperview().offset(0).constraint
        }

        // 观察三类事件:
        // - textDidChange     : 敲字时刷新可见性
        // - textDidBeginEditing / textDidEndEditing : 焦点切换时兜底,
        //   某些粘贴/编程式 setText 场景 textDidChange 不一定触发
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePlaceholder),
            name: UITextView.textDidChangeNotification,
            object: self
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePlaceholder),
            name: UITextView.textDidBeginEditingNotification,
            object: self
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePlaceholder),
            name: UITextView.textDidEndEditingNotification,
            object: self
        )

        updatePlaceholderInsets()
        updatePlaceholder()
    }

    /// 同步 placeholder 内容到 label。
    ///
    /// 优先级:`attributedPlaceholder` > `placeholder`。切回纯文本模式时重置 color / font /
    /// alignment,避免富文本属性残留污染下次渲染。
    private func refreshPlaceholderContent() {
        if let attr = attributedPlaceholder {
            placeholderLabel.attributedText = attr
        } else {
            // 清空 attributedText 否则 `text` 赋值不会生效
            placeholderLabel.attributedText = nil
            placeholderLabel.text = placeholder
            // 富文本 → 纯文本切换时,恢复本组件配置的样式
            placeholderLabel.textColor = placeholderColor
            placeholderLabel.font = font
            placeholderLabel.textAlignment = textAlignment
        }
        updatePlaceholder()
        invalidateIntrinsicContentSize()
    }

    private func updatePlaceholderInsets() {
        // placeholder 起点需对齐 UITextView 文本的实际起点:
        //   水平:textContainerInset.left/right + textContainer.lineFragmentPadding
        //   垂直:textContainerInset.top
        // lineFragmentPadding 默认 5pt,不加上会比真实文字起点左偏 5pt,肉眼可见错位。
        let leading = textContainerInset.left + textContainer.lineFragmentPadding
        let top = textContainerInset.top
        let trailing = -(textContainerInset.right + textContainer.lineFragmentPadding)

        // 0.5pt 阈值去抖:layoutSubviews 可能高频触发,同值的 constraint.update 会引
        // 起多余的一次 AutoLayout pass;略过避免无谓开销。
        if let last = lastPlaceholderInsets,
           abs(last.leading - leading) < 0.5,
           abs(last.top - top) < 0.5,
           abs(last.trailing - trailing) < 0.5
        {
            return
        }
        lastPlaceholderInsets = (leading, top, trailing)

        placeholderLeadingConstraint?.update(offset: leading)
        placeholderTopConstraint?.update(offset: top)
        placeholderTrailingConstraint?.update(offset: trailing)
    }

    /// 刷新 placeholder 可见性 + 无障碍值。
    ///
    /// ### 可见性
    /// 隐藏条件(**同时满足才显示占位**):
    /// - `hasText == false`:没有已确认文本
    /// - `markedTextRange == nil`:**IME 组合态也算有内容**,避免候选区后面透出 placeholder。
    ///   这一条 RSK / KMPlaceholderTextView / devxoul 都漏了,中日韩用户敲拼音 /
    ///   假名 / 谚文时 placeholder 会和候选字叠加显示。
    ///
    /// ### 无障碍
    /// 把 placeholder 作为 `self.accessibilityValue`(VoiceOver 的"值"字段),而不是单纯
    /// 屏蔽 label —— 与 `UITextField` 系统行为一致。让盲人用户在空表单时也能听到提示:
    /// - 空态:读 placeholder(优先富文本的 .string)
    /// - 有内容:读真实 text
    @objc
    private func updatePlaceholder() {
        let hasMarkedText = markedTextRange != nil
        let hasContent = hasText || hasMarkedText
        placeholderLabel.isHidden = hasContent

        if hasContent {
            accessibilityValue = text
        } else {
            accessibilityValue = attributedPlaceholder?.string ?? placeholder
        }

        // 敲字 / begin / end editing 都会触发;growing 启用时顺带刷新高度 + scroll 状态
        refreshSizing()
    }

    // MARK: - Self-Sizing Helpers

    /// 空态下 placeholder 实际需要的总高度(含 `textContainerInset` 上下 inset)。
    /// 从旧版 `intrinsicContentSize` 抽出,growing / legacy 两条路径共用。
    ///
    /// - 有文本时返回 0,让 caller 走 "max(contentH, 0)" 天然失效。
    private func emptyPlaceholderFittedHeight() -> CGFloat {
        guard !hasText else { return 0 }
        let displayed = placeholderLabel.text ?? placeholderLabel.attributedText?.string ?? ""
        guard !displayed.isEmpty else { return 0 }

        let horizontalChrome = textContainerInset.left + textContainerInset.right
            + textContainer.lineFragmentPadding * 2
        let availableWidth = bounds.width > 0
            ? max(bounds.width - horizontalChrome, 0)
            : .greatestFiniteMagnitude

        let fitted = placeholderLabel.sizeThatFits(
            CGSize(width: availableWidth, height: .greatestFiniteMagnitude)
        )
        return fitted.height + textContainerInset.top + textContainerInset.bottom
    }

    /// 按指定行数,用临时 `UITextView` 实测所需高度。
    /// 比手算 `font.lineHeight * n + inset` 精确,因为一次性计入了:
    /// `textContainerInset` / `lineFragmentPadding` / 行距 / font baseline。
    ///
    /// 思路来自 `FluidGroup/NextGrowingTextView` 的 `simulateHeight(_:)`。
    private func simulateHeight(lines: Int, width: CGFloat) -> CGFloat {
        let n = max(lines, 1)
        let sizing = UITextView()
        sizing.font = font
        sizing.textContainerInset = textContainerInset
        sizing.textContainer.lineFragmentPadding = textContainer.lineFragmentPadding
        sizing.isScrollEnabled = false
        // 末尾补 "A" 避免尾随空行被 layoutManager 忽略高度
        sizing.text = String(repeating: "\n", count: n - 1) + "A"
        return sizing.sizeThatFits(
            CGSize(width: width, height: .greatestFiniteMagnitude)
        ).height
    }

    /// 按当前 `bounds.width` 更新 `cachedResolvedMinHeight` / `cachedResolvedMaxHeight`。
    /// 宽度与上次相同则跳过,避免每次 layoutSubviews 都重测。
    private func refreshResolvedHeightsIfNeeded() {
        let width = bounds.width
        guard width > 0, abs(cachedSimulationWidth - width) > 0.5 else { return }
        cachedSimulationWidth = width

        cachedResolvedMinHeight = simulateHeight(lines: max(minNumberOfLines, 1), width: width)
        cachedResolvedMaxHeight = maxNumberOfLines > 0
            ? simulateHeight(lines: maxNumberOfLines, width: width)
            : .greatestFiniteMagnitude
    }

    /// growing 开启时:内容高度超过 max 才允许内滚,否则关滚动避免无意义 rubber-band。
    private func updateScrollEnabledForGrowing() {
        guard isGrowingEnabled, bounds.width > 0 else { return }
        let contentH = sizeThatFits(
            CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
        ).height
        let shouldScroll = contentH > cachedResolvedMaxHeight + 0.5
        if isScrollEnabled != shouldScroll {
            isScrollEnabled = shouldScroll
        }
    }

    /// 文本 / 布局变化后的统一入口:
    /// 1. invalidate 自身 + 父级的 intrinsic,确保 AutoLayout / cell self-sizing 重算
    /// 2. growing 启用时:按当前内容切 `isScrollEnabled`
    /// 3. 通过 `intrinsicContentSize` 拿到新高,若较上次变化 > 0.5pt,回调 `onHeightChange`
    private func refreshSizing() {
        invalidateIntrinsicContentSize()
        superview?.invalidateIntrinsicContentSize()

        if isGrowingEnabled, bounds.width > 0 {
            refreshResolvedHeightsIfNeeded()
            updateScrollEnabledForGrowing()
        }

        let newHeight = intrinsicContentSize.height
        guard newHeight != UIView.noIntrinsicMetric else { return }
        if abs(newHeight - lastReportedHeight) > 0.5 {
            lastReportedHeight = newHeight
            onHeightChange?(newHeight)
        }
    }
}
#endif
