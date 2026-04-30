# XXFHttp 进阶范式

本文档是 `xxf-http` skill 的**进阶参考**，仅在 AI 需要深度范式时加载，避免污染主 prompt。

## 1. 接口封装分层

```
ViewModel
   ↓  只依赖 Protocol
XxxApiProtocol
   ↓  实现
XxxApiImpl           ← 使用 XXFHttp
   ↓
XXFHttp (框架)
```

- `XxxApiProtocol` 让业务**可 mock**、可替换为假数据、可插桩。
- `XxxApiImpl` 是唯一 `import XXFHttp` 的地方。
- 禁止在 ViewModel 直接 `XXFHttp.request(...)`。

## 2. 错误统一处理

建议在 `XxxApiImpl` 的顶部用 `map / catchError` 把 XXFHttp 错误转换为业务错误：

```
enum BizError: Error {
    case needLogin
    case rateLimited
    case network(underlying: Error)
    case server(code: Int, message: String)
}
```

**规则**：
- `401` → `.needLogin`（并触发登出流，见 `xxf-router` 的登录拦截）
- `429` → `.rateLimited`
- `>=500` → `.server(...)`
- 其他 IO / 解析失败 → `.network(...)`

## 3. SSE 流式响应

要点：
- 返回 `Flow<SSEEvent>` 而非一次性结果
- 每个事件独立解析，失败事件丢弃或降级，**不要中断整个流**
- UI 侧增量渲染，避免整串 `String` 拼接触发频繁刷新

典型：

```
func chat(prompt: String) -> Flow<ChatDelta>
```

断流处理：业务层 `retry(max: 2)` 或提示用户手动重试。

## 4. 拦截器编排

**推荐顺序**（按请求方向）：

1. 日志（入站记录）
2. 签名 / 鉴权（加 token / sign）
3. 缓存命中（命中则短路返回，不发请求）
4. 网络发出
5. 响应解码
6. 缓存写入
7. 日志（出站记录）

**反模式**：
- 一个拦截器同时干签名、埋点、缓存（拆开）
- 拦截器里起新 `flow`（用框架提供的 pipeline 能力）

## 5. 上传下载

- 小文件（< 5MB）：直接 POST multipart
- 大文件：分片 + 断点续传（读 `Sources/XXFHttp/` 确认框架是否内置；若无，业务侧自建队列）
- 下载：用 `stream to disk`，**不要**全部读进内存

## 6. 测试策略

| 测试类型 | 工具 |
|:------|:------|
| 单测 API 解析 | Mock `XxxApiProtocol` |
| 集成测试 | `URLProtocol` 拦截真实请求 |
| 契约测试 | Swagger / OpenAPI 校验 |
| 弱网测试 | Network Link Conditioner |

## 7. 性能红线

- 单个响应 > 10MB：改分页或流式
- 单次并发请求数 > 10：前端做限流
- 列表页无分页：强制加 `page_size` 参数

## 8. Moya + RestApiService 定义接口(项目模板)

基于 Moya 的项目用 `enum + RestApiService` 封装接口,case 关联值传参。**请求首选 `request(_:type:)` 重载**,直接得到 `Observable<T>`,省掉样板 `.mapHttpResponse`。

### 骨架

```swift
import XXFArch

enum UserApiService {
    case getProfile(userId: String)
    case updateProfile(username: String, avatar: String?)
    case getUserList(page: Int, limit: Int, cacheType: CacheType)
}

extension UserApiService: RestApiService {
    static var interceptors: [any Interceptor] { [AppHttpInterceptor()] }
    static var callAdapter: (any RxCallAdapter)? { AuthRetryCallAdapter.shared }
    static var cacheInterceptor: any CacheInterceptor { AppCacheInterceptor() }

    var baseURL: URL { URLConfig.getApiURL() }

    var path: String {
        switch self {
            case let .getProfile(userId): return "/users/\(userId)"
            case .updateProfile: return "/users/profile"
            case .getUserList: return "/users"
        }
    }

    var method: Moya.Method {
        switch self {
            case .getProfile, .getUserList: return .get
            case .updateProfile: return .post
        }
    }

    var cachePolicy: CacheType {
        switch self {
            case let .getUserList(_, _, cache): return cache
            default: return .onlyRemote
        }
    }

    var task: Moya.Task {
        switch self {
            case .getProfile:
                return .Builder().build()
            case let .updateProfile(username, avatar):
                var params: [String: Any] = ["username": username]
                if let avatar { params["avatar"] = avatar }
                return .Builder().jsonBody(params).build()
            case let .getUserList(page, limit, _):
                return .Builder().query(["page": page, "limit": limit]).build()
        }
    }
}
```

### Repository 调用(首选 `request(_:type:)`)

```swift
func getProfile(userId: String) -> Observable<UserDTO> {
    UserApiService.apiService
        .request(.getProfile(userId: userId), type: BaseResponseDTO<UserDTO>.self)
        .mapDataField()
}

func getUserList(page: Int, limit: Int, cacheType: CacheType) -> Observable<[UserDTO]> {
    UserApiService.apiService
        .request(.getUserList(page: page, limit: limit, cacheType: cacheType),
                 type: BaseResponseDTO<BasePaginationDTO<UserDTO>>.self)
        .mapDataField()
        .map(\.list)
}
```

### SSE 流式

```swift
enum AiApiService {
    case generateStream(prompt: String)
}

extension AiApiService: RestApiService { /* ... */ }

func chat(prompt: String) -> Observable<String> {
    AiApiService.apiService
        .requestSSE(.generateStream(prompt: prompt))
        .mapSSEEventData()
        .compactMap { $0["content"] as? String }
}
```

### 约束

- 全程 **`Observable`**,不用 `Single`。需要一次性消费在调用端处理(`take(1)` / `subscribe(onNext:)`)
- ❌ 禁止 `.mapHttpResponse(...)` + 手动解包,除非真的需要原始 `Response`
- ❌ 禁止 `.asSingle()` 收口
- 命名:`{Feature}ApiService`,case 动词 + 名词
- 分页 `page` / `limit`;缓存 `cacheType: CacheType`
