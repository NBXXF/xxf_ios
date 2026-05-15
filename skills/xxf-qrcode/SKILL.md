---
name: xxf-qrcode
description: 使用 XXFQRCode 生成二维码（文本、链接、样式化二维码、导出图片）。当用户提到“二维码生成”“带 logo 的二维码”“二维码尺寸/容错等级”等场景时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFQRCode 使用指南

## 适用场景

- 生成文本/URL 二维码
- 自定义前景色、背景色、尺寸
- 二维码中间叠加 logo
- 导出 UIImage/NSImage 用于分享或保存

## 工作流

1. 先确认当前仓库真实 API（不要凭记忆）：

```bash
Glob Sources/XXFQRCode/**/*.swift
Grep "QRCode|errorCorrection|image|logo|color|size" Sources/XXFQRCode/
```

2. 明确输出要求：
- 内容：文本、URL、业务短码
- 尺寸：用于列表缩略图还是全屏展示
- 容错等级：是否需要 logo 覆盖
- 平台：iOS / macOS

3. 给出实现代码并说明参数选择理由。

## 设计建议

- 默认使用中等容错等级，兼顾容量和识别率。
- 叠加 logo 时提高容错等级，并控制 logo 面积。
- 导出前做最小尺寸校验，避免不可识别。
- 颜色对比度保持高，避免浅色二维码。

## 常见反模式

- 在低分辨率下强行放大位图，导致扫描失败。
- logo 过大但未提高容错等级。
- 二维码颜色与背景对比不足。
- 业务内容过长但未做短码压缩。
