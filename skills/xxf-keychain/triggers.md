## 应该触发
- "token 存哪里"
- "XXFKeychain 保存密码"
- "设备唯一标识跨卸载"

## 不应该触发
- "UserDefaults 用法" → `xxf-cache`
- "生物识别 / Face ID 怎么做" → Apple API（可能需新建 skill）

## 边界用例
- "refresh token 续期存哪"
  - 期望：触发，Keychain + 合适 access 策略
