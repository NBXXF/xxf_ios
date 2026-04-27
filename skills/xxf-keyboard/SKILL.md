---
name: xxf-keyboard
description: XXFKeyboard 键盘适配。当用户要处理键盘弹出 / 收起、输入框避让、Return 切换、键盘类型配置，或询问"XXF 键盘避让"时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFKeyboard

统一的键盘事件监听与输入框避让封装。

## 触发场景

- 表单页面避免键盘遮挡输入框
- `Return` 键在多个输入框之间切换
- 键盘类型 / 工具栏定制

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFKeyboard/**/*.swift
   Grep "public|observe|avoid|keyboard" in Sources/XXFKeyboard/
   ```
2. 在 VC 绑定 XXFKeyboard 的监听，**不要自己监听 `UIResponder.keyboardWillShowNotification`**
3. 避让方式：ScrollView 的 `contentInset` 调整 > 修改 constraint > 改 frame（最后手段）

## 反模式

- 每个 VC 重写键盘监听（`XXFKeyboard` 就是为了消除这个重复）
- 键盘动画用固定 duration（必须用 system 回调里的 duration）
- 不在 `viewWillDisappear` 移除监听（iOS 9+ 不是必须，但仍建议）

## 相关 skill

- `xxf-uikit` — 表单基类
