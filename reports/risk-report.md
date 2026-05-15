# Risk Scan Report

Generated from `xxf_ios`.

- Total findings: **191**
- HIGH: **21**
- MEDIUM: **167**
- LOW: **3**

## HIGH

| Rule | File | Line | Snippet |
|---|---|---:|---|
| R001 | `Sources/XXFPerformance/BlockWatcher.swift` | 20 | `fatalError(message)` |
| R001 | `Sources/XXFIdentifier/DeviceIDManager.swift` | 32 | `fatalError("Failed to initialize Keychain: \(error)")` |
| R001 | `Sources/XXFFlow/Lifecycle/LifecycleEvent.swift` | 71 | `fatalError("Not supported on AppKit")` |
| R001 | `Sources/XXFFlow/Schedulers/Queue/ConcurrentDispatchQueueScheduler+XXFExtension.swift` | 11 | `fatalError("storedQueue not init")` |
| R001 | `Sources/XXFAppkit/Menu/NSBeforeMenu.swift` | 21 | `required init(coder _: NSCoder) { fatalError() }` |
| R001 | `Sources/XXFHttp/Extensions/MoyaProvider+Stream.swift` | 77 | `fatalError("构造 URLRequest 失败: \(error)")` |
| R001 | `Sources/XXFViewModel/Core/Binding/WindowViewModelBinding.swift` | 32 | `fatalError("Window is not available yet when accessing ViewModel.")` |
| R001 | `Sources/XXFViewModel/Core/Binding/VCViewModelBinding.swift` | 33 | `fatalError("Owner not available yet.")` |
| R001 | `Sources/XXFDatabaseObjectBox/Query/OBQuery.swift` | 136 | `fatalError("OBQuery: empty conditions after guard")` |
| R001 | `Sources/XXFFoundation/Foundation/Collection/Concurrent/PriorityQueue.swift` | 67 | `fatalError("Fatal error: trying to pop from an empty PriorityQueue")` |
| R001 | `Sources/XXFFoundation/Foundation/Collection/Concurrent/PriorityQueue.swift` | 86 | `fatalError("Fatal error: trying to peek into an empty PriorityQueue")` |
| R001 | `Sources/XXFFoundation/Foundation/AssociatedObject/AssociatedObjectBinding.swift` | 50 | `get { fatalError("Should not be called directly") }` |
| R001 | `Sources/XXFFoundation/Foundation/AssociatedObject/AssociatedObjectBinding.swift` | 51 | `set { fatalError("Should not be called directly") }` |
| R001 | `Sources/XXFReusable/UICollectionView+Reusable.swift` | 60 | `fatalError(` |
| R001 | `Sources/XXFReusable/UICollectionView+Reusable.swift` | 139 | `fatalError(` |
| R001 | `Sources/XXFReusable/UITableView+Reusable.swift` | 58 | `fatalError(` |
| R001 | `Sources/XXFReusable/UITableView+Reusable.swift` | 118 | `fatalError(` |
| R001 | `Sources/XXFReusable/NibLoadable.swift` | 39 | `fatalError("The nib \(nib) expected its root view to be of type \(self)")` |
| R001 | `Sources/XXFServer/Core/ControllerRegister.swift` | 99 | `fatalError("The whole routePath contains leading or trailing whitespace: '\(routePath)'")` |
| R001 | `Sources/XXFServer/Core/ControllerRegister.swift` | 102 | `fatalError("The routePath contains consecutive slashes: '\(routePath)'")` |
| R001 | `Sources/XXFServer/Core/ControllerRegister.swift` | 112 | `fatalError("Path segment contains leading or trailing whitespace: '\(segment)' in routePath: '\(routePath)'")` |

## MEDIUM

| Rule | File | Line | Snippet |
|---|---|---:|---|
| R005 | `Sources/XXFIdentifier/DeviceIDManager.swift` | 22 | `private nonisolated(unsafe) static var cachedID: String?` |
| R005 | `Sources/XXFIdentifier/DeviceIDManager.swift` | 25 | `private nonisolated(unsafe) static let keychain: Keychain = {` |
| R005 | `Sources/XXFImage/platform/PlatformImage.swift` | 14 | `@usableFromInline nonisolated(unsafe) let kUTTypeJPEG = "public.jpeg" as CFString` |
| R005 | `Sources/XXFImage/platform/PlatformImage.swift` | 15 | `@usableFromInline nonisolated(unsafe) let kUTTypePNG = "public.png" as CFString` |
| R005 | `Sources/XXFImage/platform/PlatformImage.swift` | 16 | `@usableFromInline nonisolated(unsafe) let kUTTypeTIFF = "public.tiff" as CFString` |
| R005 | `Sources/XXFImage/platform/PlatformImage.swift` | 17 | `@usableFromInline nonisolated(unsafe) let kUTTypeGIF = "com.compuserve.gif" as CFString` |
| R005 | `Sources/XXFImage/platform/PlatformImage.swift` | 18 | `@usableFromInline nonisolated(unsafe) let kUTTypePDF = "com.adobe.pdf" as CFString` |
| R005 | `Sources/XXFImage/platform/PlatformImage.swift` | 22 | `@usableFromInline nonisolated(unsafe) let kUTTypeHEIC = "public.heic" as CFString` |
| R005 | `Sources/XXFImage/platform/PlatformImage.swift` | 23 | `@usableFromInline nonisolated(unsafe) let kUTTypeSVG = "public.svg-image" as CFString` |
| R005 | `Sources/XXFImage/platform/PlatformImage+PhotoLibrary.swift` | 215 | `private final class LocalIdentifierHolder: @unchecked Sendable {` |
| R005 | `Sources/XXFFlow/XXFFlow.swift` | 46 | `public nonisolated(unsafe) static var logEventLogger: LogEventLogger = { message, _, file, function, line in` |
| R005 | `Sources/XXFFlow/XXFFlow.swift` | 80 | `public nonisolated(unsafe) static var logTimingLogger: LogTimingLogger = { totalElapsed, identifier, warningTimeLimit, errorTimeLimit, file, function, line in` |
| R005 | `Sources/XXFFlow/Error/BlockingNoElementsError.swift` | 9 | `public class BlockingNoElementsError: AppError, @unchecked Sendable {` |
| R005 | `Sources/XXFFlow/Schedulers/Queue/MainCommonModeScheduler.swift` | 10 | `public final class MainCommonModeScheduler: ImmediateSchedulerType, @unchecked Sendable {` |
| R005 | `Sources/XXFFlow/Schedulers/Queue/ConcurrentDispatchQueueScheduler+XXFExtension.swift` | 5 | `private nonisolated(unsafe) var queueKey: UInt8 = 0` |
| R005 | `Sources/XXFCompress/Luban.swift` | 69 | `public enum CompressSource: @unchecked Sendable {` |
| R005 | `Sources/XXFCompress/Luban.swift` | 78 | `public final class Luban: @unchecked Sendable {` |
| R005 | `Sources/XXFUIKit/BadgeView.swift` | 244 | `nonisolated(unsafe) public static let standard = BadgeAnimation.spring(damping: 0.62, velocity: 0.8)` |
| R005 | `Sources/XXFUIKit/BadgeView.swift` | 505 | `private nonisolated(unsafe) var _badgeViewKey: UInt8 = 0` |
| R005 | `Sources/XXFUIKit/BadgeView.swift` | 506 | `private nonisolated(unsafe) var _anchorKey:    UInt8 = 0` |
| R005 | `Sources/XXFUIKit/BadgeView.swift` | 834 | `private nonisolated(unsafe) var _nsBadgeViewKey: UInt8 = 0` |
| R005 | `Sources/XXFUIKit/Gesture/ContinuousTapGestureDetection.swift` | 72 | `public class ContinuousTapGestureDetection: @unchecked Sendable {` |
| R005 | `Sources/XXFUIKit/Tips/ToolTipsTextStyle.swift` | 22 | `nonisolated(unsafe) public static let defaultFont: NSFont = .systemFont(ofSize: 12, weight: .regular)` |
| R005 | `Sources/XXFUIKit/Haptic/HapticFeedback.swift` | 39 | `public nonisolated(unsafe) static var isEnabled: Bool = true` |
| R005 | `Sources/XXFUIKit/Haptic/HapticFeedback.swift` | 84 | `private nonisolated(unsafe) static var impactGenerators: [UIImpactFeedbackGenerator.FeedbackStyle.RawValue: UIImpactFeedbackGenerator] = [:]` |
| R005 | `Sources/XXFUIKit/Haptic/HapticFeedback.swift` | 85 | `private nonisolated(unsafe) static let selectionGenerator = MainActor.assumeIsolated { UISelectionFeedbackGenerator() }` |
| R005 | `Sources/XXFUIKit/Haptic/HapticFeedback.swift` | 86 | `private nonisolated(unsafe) static let notificationGenerator = MainActor.assumeIsolated { UINotificationFeedbackGenerator() }` |
| R005 | `Sources/XXFAppkit/WindowController/NSWindowDelegateController.swift` | 13 | `nonisolated(unsafe) static var controllers: [NSWindowDelegateController] = []` |
| R005 | `Sources/XXFAppkit/Menu/NSWindow+Menu.swift` | 14 | `private nonisolated(unsafe) var keyMainMenu = 1` |
| R005 | `Sources/XXFAppkit/Menu/NSWindow+Menu.swift` | 15 | `private nonisolated(unsafe) var keyStatusMenu = 2` |
| R005 | `Sources/XXFAppkit/Menu/NSStatusBar+Extension.swift` | 10 | `private nonisolated(unsafe) var associatedStatusItemKey: UInt8 = 0` |
| R005 | `Sources/XXFAppkit/Views/NSView+ClickAction.swift` | 37 | `private nonisolated(unsafe) var gestureStoreKey: UInt8 = 0` |
| R005 | `Sources/XXFHudiOS/SwiftNotice.swift` | 87 | `nonisolated(unsafe) static var windows = [UIWindow?]()` |
| R005 | `Sources/XXFHudiOS/SwiftNotice.swift` | 89 | `nonisolated(unsafe) static var timer: DispatchSource!` |
| R005 | `Sources/XXFHudiOS/SwiftNotice.swift` | 90 | `nonisolated(unsafe) static var timerTimes = 0` |
| R005 | `Sources/XXFHudiOS/SwiftNotice.swift` | 342 | `nonisolated(unsafe) static var imageOfCheckmark: UIImage?` |
| R005 | `Sources/XXFHudiOS/SwiftNotice.swift` | 343 | `nonisolated(unsafe) static var imageOfCross: UIImage?` |
| R005 | `Sources/XXFHudiOS/SwiftNotice.swift` | 344 | `nonisolated(unsafe) static var imageOfInfo: UIImage?` |
| R005 | `Sources/XXFImageNukeLoader/ImageNukeLoaderAdapter.swift` | 111 | `nonisolated(unsafe) let progressHandler = progressHandler` |
| R005 | `Sources/XXFImageNukeLoader/ImageNukeLoaderAdapter.swift` | 112 | `nonisolated(unsafe) let completion = completion` |
| R005 | `Sources/XXFImageNukeLoader/ImageNukeLoaderAdapter.swift` | 113 | `nonisolated(unsafe) let errorImage = error` |
| R005 | `Sources/XXFImageNukeLoader/ImageNukeLoaderAdapter.swift` | 239 | `private final class AnimatedImageDecoder: ImageDecoding, @unchecked Sendable {` |
| R005 | `Sources/XXFImageNukeLoader/Core/PlatformImageView+Task.swift` | 17 | `private nonisolated(unsafe) static var kImageTaskKey: UInt8 = 0` |
| R005 | `Sources/XXFImageNukeLoader/Core/PlatformImageView+Task.swift` | 18 | `private nonisolated(unsafe) static var kImageTaskIdKey: UInt8 = 1` |
| R005 | `Sources/XXFImageNukeLoader/Cancellable/AnyCancellableWrapper.swift` | 12 | `final class AnyCancellableWrapper: XXFImageLoader.Cancellable, Nuke.Cancellable, @unchecked Sendable {` |
| R005 | `Sources/XXFDatabaseGrdb/Core/DatabasePool+Create.swift` | 17 | `private nonisolated(unsafe) static var cache = ConcurrentDictionary<String, DatabasePool>()` |
| R005 | `Sources/XXFDatabaseGrdb/Core/DatabaseQueue+Create.swift` | 14 | `private nonisolated(unsafe) static var cache = ConcurrentDictionary<String, DatabaseQueue>()` |
| R005 | `Sources/XXFBus/RxBus.swift` | 13 | `public nonisolated(unsafe) static let shared = RxBus()` |
| R005 | `Sources/XXFHttp/XXFHttp.swift` | 18 | `public final class XXFHttp: @unchecked Sendable {` |
| R005 | `Sources/XXFHttp/Logger/LoggerEventMonitor.swift` | 11 | `open class LoggerEventMonitor: EventMonitor, @unchecked Sendable {` |
| R005 | `Sources/XXFHttp/Cache/HttpCache.swift` | 42 | `public struct CacheEntry: @unchecked Sendable {` |
| R005 | `Sources/XXFHttp/Cache/HttpCache.swift` | 205 | `public final class HttpCache: @unchecked Sendable {` |
| R005 | `Sources/XXFHttp/Cache/HttpCache.swift` | 791 | `nonisolated(unsafe) static let scheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)` |
| R005 | `Sources/XXFHttp/Cache/CachingRxCallAdapter.swift` | 54 | `final class CachingRxCallAdapter: RxCallAdapter, @unchecked Sendable {` |
| R005 | `Sources/XXFHttp/Network/NetworkMonitor.swift` | 12 | `public final class NetworkMonitor: @unchecked Sendable {` |
| R005 | `Sources/XXFHttp/Error/ResponseError.swift` | 11 | `public class ResponseError: AppError, @unchecked Sendable {` |
| R005 | `Sources/XXFHttp/Session/HttpSession.swift` | 29 | `public final class HttpSession: @unchecked Sendable {` |
| R005 | `Sources/XXFCache/Memory/LRUCache.swift` | 44 | `public final class LRUCache<Key: Hashable, Value>: @unchecked Sendable {` |
| R005 | `Sources/XXFCache/Preference/PreferenceWrapper.swift` | 5 | `public class PreferenceWrapper<T: Sendable, Owner: PreferenceProvider>: NSObject, @unchecked Sendable {` |
| R005 | `Sources/XXFCache/Preference/PreferencesStorage.swift` | 18 | `extension UserDefaults: @unchecked Sendable {}` |
| R005 | `Sources/XXFCache/Disk/Impl/HyperosloDiskCache.swift` | 88 | `public final class HyperosloDiskCache<Value: Codable & Sendable>: DiskCache, @unchecked Sendable {` |
| R005 | `Sources/XXFEventReporter/Core/EventReporter.swift` | 18 | `public final class EventReporter: @unchecked Sendable {` |
| R005 | `Sources/XXFEventReporter/Core/EventReporter.swift` | 134 | `private final class ReportEventOperation: Operation, @unchecked Sendable {` |
| R005 | `Sources/XXFViewModel/Core/ViewModelProvider.swift` | 38 | `public final class ViewModelProvider: @unchecked Sendable {` |
| R005 | `Sources/XXFViewModel/Core/ViewModelStore.swift` | 9 | `public final class ViewModelStore: @unchecked Sendable {` |
| R005 | `Sources/XXFViewModel/Core/ViewModelStoreOwner/ViewModelStoreOwner.swift` | 14 | `private nonisolated(unsafe) var kViewModelStoreKey = 1024` |
| R005 | `Sources/XXFDatabaseObjectBox/Core/Store+Create.swift` | 22 | `private nonisolated(unsafe) static var cache = ConcurrentDictionary<String, Store>()` |
| R005 | `Sources/XXFRouter/Result/RouteResult.swift` | 14 | `public enum RouteResult: @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Result/RouteResult.swift` | 190 | `public final class RouteListenerManager: @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Result/RouteResult.swift` | 258 | `public final class ClosureRouteCallback: RouteCallback, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Result/RouteResult.swift` | 311 | `public final class LoggingRouteListener: RouteListener, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Core/RouteRegistry.swift` | 16 | `public struct RouteEntry: @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Core/RouteRegistry.swift` | 69 | `public final class RouteRegistry: @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Core/RouteRegistry.swift` | 410 | `public final class RouteRegistryBuilder: @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Core/Routable.swift` | 97 | `public final class ClosureRouteFactory: RouteFactory, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Core/Routable.swift` | 133 | `public final class TypeRouteFactory<T: Routable>: RouteFactory, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Core/Routable.swift` | 187 | `public final class ClosureRouteHandler: RouteHandler, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Core/Routable.swift` | 223 | `public final class AnyRoutableFactory: RouteFactory, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Core/RouteContext.swift` | 9 | `public struct RouteContext: @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Core/Router.swift` | 104 | `public final class Router: @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Core/Router.swift` | 965 | `public final class DebounceNavigator: @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Core/RouteOptions.swift` | 13 | `public struct RouteOptions: @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Extension/Routable+AutoRegister.swift` | 56 | `public final class RouteGroup: @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Degradation/DegradationHandler.swift` | 97 | `public enum DegradationResult: @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Degradation/DegradationHandler.swift` | 117 | `public final class DegradationManager: @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Degradation/Impl/RedirectDegradationHandler.swift` | 9 | `public final class RedirectDegradationHandler: DegradationHandler, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Degradation/Impl/URLPatternDegradationHandler.swift` | 13 | `public final class URLPatternDegradationHandler: DegradationHandler, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Degradation/Impl/ExternalLinkDegradationHandler.swift` | 16 | `public final class ExternalLinkDegradationHandler: DegradationHandler, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Degradation/Impl/NotFoundDegradationHandler.swift` | 9 | `public final class NotFoundDegradationHandler: DegradationHandler, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Navigator/RouteNavigator.swift` | 71 | `public final class DefaultRouteNavigator: RouteNavigator, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Navigator/RouteNavigator.swift` | 446 | `public final class DefaultRouteNavigator: RouteNavigator, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Service/ServiceProvider.swift` | 102 | `final class TypeServiceFactory<T: ServiceProtocol>: ServiceFactory, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Service/ServiceProvider.swift` | 128 | `final class ClosureServiceFactory: ServiceFactory, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Service/ServiceProvider.swift` | 161 | `public final class ServiceRegistry: @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Service/ServiceProvider.swift` | 469 | `public final class ServiceRegistryBuilder: @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Interceptor/BuiltinInterceptors.swift` | 25 | `public final class LoginCheckInterceptor: RouteInterceptor, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Interceptor/BuiltinInterceptors.swift` | 82 | `public final class RealNameCheckInterceptor: RouteInterceptor, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Interceptor/BuiltinInterceptors.swift` | 120 | `public final class VIPCheckInterceptor: RouteInterceptor, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Interceptor/BuiltinInterceptors.swift` | 164 | `public final class SingletonRouteInterceptor: RouteInterceptor, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Interceptor/BuiltinInterceptors.swift` | 262 | `public final class ParameterValidationInterceptor: RouteInterceptor, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Interceptor/BuiltinInterceptors.swift` | 342 | `public final class AnalyticsInterceptor: RouteInterceptor, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Interceptor/BuiltinInterceptors.swift` | 374 | `public final class URLFilterInterceptor: RouteInterceptor, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Interceptor/BuiltinInterceptors.swift` | 477 | `public final class RateLimitInterceptor: RouteInterceptor, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Interceptor/RouteInterceptor.swift` | 166 | `public final class InterceptorChain: @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Interceptor/RouteInterceptor.swift` | 320 | `public final class InterceptorManager: @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Interceptor/RouteInterceptor.swift` | 428 | `open class GlobalRouteInterceptor: RouteInterceptor, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Interceptor/RouteInterceptor.swift` | 445 | `open class FlagBasedRouteInterceptor: RouteInterceptor, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Interceptor/RouteInterceptor.swift` | 489 | `open class AsyncRouteInterceptor: RouteInterceptor, @unchecked Sendable {` |
| R005 | `Sources/XXFRouter/Interceptor/RouteInterceptor.swift` | 581 | `public final class ClosureRouteInterceptor: RouteInterceptor, @unchecked Sendable {` |
| R005 | `Sources/XXFCacheMMKV/MMKVPreferencesStorage.swift` | 5 | `open class MMKVPreferencesStorage: PreferencesStorage, @unchecked Sendable {` |
| R005 | `Sources/XXFJson/SwiftJSONDecoder.swift` | 13 | `open class JSONDecoder: SwiftJSONDecoder, @unchecked Sendable {}` |
| R005 | `Sources/XXFJson/Json.swift` | 16 | `nonisolated(unsafe) public static var useCache = false /// 暂时不要用缓存,有野指针崩溃风险` |
| R005 | `Sources/XXFJson/Json.swift` | 22 | `private nonisolated(unsafe) static var _defaultDecoder: Foundation.JSONDecoder = LoggingJSONDecoder()` |
| R005 | `Sources/XXFJson/Json.swift` | 23 | `private nonisolated(unsafe) static var _defaultEncoder: JSONEncoder = .init()` |
| R005 | `Sources/XXFJson/Json.swift` | 27 | `private nonisolated(unsafe) static var configVersion: Int = 0` |
| R005 | `Sources/XXFJson/Wrapper/Demo/Demo.swift` | 38 | `nonisolated(unsafe) public static let defaultValue: DemoOrderStatus = .unknown` |
| R005 | `Sources/XXFJson/Wrapper/Adapter/Impl/_DateParsing.swift` | 18 | `nonisolated(unsafe) static let encodeFormatter: ISO8601DateFormatter = {` |
| R005 | `Sources/XXFJson/Wrapper/Adapter/Impl/_DateParsing.swift` | 25 | `nonisolated(unsafe) static let plainFormatter: ISO8601DateFormatter = {` |
| R005 | `Sources/XXFJson/Logging/LoggingJSONDecoder.swift` | 10 | `open class LoggingJSONDecoder: Foundation.JSONDecoder, @unchecked Sendable {` |
| R005 | `Sources/XXFImageLoader/Core/Imageloader.swift` | 12 | `public nonisolated(unsafe) static var adapter: ImageLoaderAdapter?` |
| R005 | `Sources/XXFImageLoader/Fectcher/LocalFileCoverTool.swift` | 65 | `final class DataBox: @unchecked Sendable {` |
| R005 | `Sources/XXFImageLoader/Fectcher/LocalFileCoverTool.swift` | 69 | `final class VideoGenerationState: @unchecked Sendable {` |
| R005 | `Sources/XXFImageLoader/Fectcher/LocalResourceDataFetcher.swift` | 35 | `final class LocalReourceDataTask: Cancellable, @unchecked Sendable {` |
| R005 | `Sources/XXFImageLoader/Fectcher/LocalFileThumbnailDataFetcher.swift` | 37 | `final class LocalFileThumbnailDataTask: Cancellable, @unchecked Sendable {` |
| R005 | `Sources/XXFImageLoader/Common/RequestOptions.swift` | 11 | `public class RequestOptions: @unchecked Sendable {` |
| R005 | `Sources/XXFRefreshable/RefreshableState.swift` | 17 | `public struct RefreshableState: @unchecked Sendable, ObsConvertible, Hashable, Equatable {` |
| R005 | `Sources/XXFAdapter/DiffableDataSource/UniqueItem.swift` | 10 | `public final class UniqueItem<Value: Hashable>: Hashable, @unchecked Sendable {` |
| R005 | `Sources/XXFAdapter/DiffableDataSource/SingleSection.swift` | 9 | `public enum SingleSection: CaseIterable, Hashable, @unchecked Sendable {` |
| R005 | `Sources/XXFHud/core/Toast/ToastUtils.swift` | 13 | `public nonisolated(unsafe) static var toastDelegate: ToastDelegate? = DefaultToastDelegate()` |
| R005 | `Sources/XXFHud/core/Toast/ToastUtils.swift` | 15 | `public nonisolated(unsafe) static var toastDelegate: ToastDelegate?` |
| R005 | `Sources/XXFHud/core/Error/DefaultErrorHandler.swift` | 11 | `public nonisolated(unsafe) static var shared: ErrorHandler = DefaultErrorHandler()` |
| R005 | `Sources/XXFHud/core/Hud/ProgressHudUtils.swift` | 9 | `public nonisolated(unsafe) static var progressHudHandler: ProgressHudHandler = EmptyProgressHudHandler()` |
| R005 | `Sources/XXFTracker/Core/Tracker.swift` | 14 | `public final class Tracker: TrackerConverterChain, @unchecked Sendable {` |
| R005 | `Sources/XXFTracker/Core/Tracker.swift` | 128 | `private final class TrackOperation: Operation, @unchecked Sendable {` |
| R005 | `Sources/XXFLog/LogUtils.swift` | 20 | `public nonisolated(unsafe) static var config: Config = .init(logInterceptor: { _ in` |
| R005 | `Sources/XXFLog/LogUtils.swift` | 46 | `private nonisolated(unsafe) static var isInitialized = false` |
| R005 | `Sources/XXFLog/LogUtils.swift` | 48 | `private nonisolated(unsafe) static let streamLogHandlerCache = ConcurrentDictionary<String, StreamLogHandler>()` |
| R005 | `Sources/XXFLog/LogUtils.swift` | 49 | `private nonisolated(unsafe) static let persistentLogHandlerCache = ConcurrentDictionary<String, PersistentLogHandler>()` |
| R005 | `Sources/XXFLog/LogUtils.swift` | 50 | `private nonisolated(unsafe) static let fileLogHandlerCache = ConcurrentDictionary<String, FileLogHandler>()` |
| R005 | `Sources/XXFFoundation/Foundation/Once.swift` | 10 | `private final class OnceTracker: @unchecked Sendable {` |
| R005 | `Sources/XXFFoundation/Foundation/PerformanceTimer.swift` | 15 | `public final class PerformanceTimer: @unchecked Sendable {` |
| R005 | `Sources/XXFFoundation/Foundation/PerformanceTimer.swift` | 21 | `private nonisolated(unsafe) static var timebaseInfo: mach_timebase_info_data_t = {` |
| R005 | `Sources/XXFFoundation/Foundation/EventLimiter.swift` | 13 | `public nonisolated(unsafe) static let shared = EventLimiter()` |
| R005 | `Sources/XXFFoundation/Foundation/Lock/NSObject+Lock.swift` | 10 | `private nonisolated(unsafe) var syncLockKey: UInt8 = 0` |
| R005 | `Sources/XXFFoundation/Foundation/Lock/NSLocking+XXFExtension.swift` | 39 | `nonisolated(unsafe) var _typeLockDict = ConcurrentDictionary<ObjectIdentifier, NSLocking>()` |
| R004 | `Sources/XXFFoundation/Foundation/Density/Dimensions.swift` | 25 | `DispatchQueue.main.sync {` |
| R005 | `Sources/XXFFoundation/Foundation/Density/Dimensions.swift` | 33 | `private final class ScreenScaleCacheBox: @unchecked Sendable {` |
| R005 | `Sources/XXFFoundation/Foundation/Density/Dimensions.swift` | 90 | `public nonisolated(unsafe) static var scaleFactor: CGFloat = 1.0` |
| R005 | `Sources/XXFFoundation/Foundation/Density/Dimensions.swift` | 107 | `public nonisolated(unsafe) static var scaleFactor: CGFloat = 1.0` |
| R005 | `Sources/XXFFoundation/Foundation/Local/Locale+App.swift` | 11 | `private nonisolated(unsafe) var associatedAppLocaleKey: UInt8 = 0` |
| R005 | `Sources/XXFFoundation/Foundation/Local/Locale+App.swift` | 19 | `private nonisolated(unsafe) static var _appLocale: Locale = .current` |
| R005 | `Sources/XXFFoundation/Foundation/Local/TimeZone+App.swift` | 12 | `private nonisolated(unsafe) static var _appTimeZone: TimeZone = .current` |
| R005 | `Sources/XXFFoundation/Foundation/Task/Task+Sync.swift` | 10 | `private final class _TaskWaitBox<T: Sendable>: @unchecked Sendable {` |
| R005 | `Sources/XXFFoundation/Foundation/AssociatedObject/AssociatedObject.swift` | 12 | `private nonisolated(unsafe) static var associatedDictionaryKey: UInt8 = 0` |
| R005 | `Sources/XXFFoundation/Foundation/Metadata/MediaMetadata.swift` | 32 | `public struct MediaAsset: @unchecked Sendable {` |
| R005 | `Sources/XXFFoundation/Foundation/Metadata/MediaMetadata.swift` | 57 | `final class ResultBox: @unchecked Sendable {` |
| R005 | `Sources/XXFFoundation/Foundation/Metadata/URL+Query.swift` | 14 | `private nonisolated(unsafe) static var mdItemKey: UInt8 = 0` |
| R005 | `Sources/XXFFoundation/Error/IllegalArgumentError.swift` | 9 | `open class IllegalArgumentError: AppError, @unchecked Sendable {` |
| R005 | `Sources/XXFFoundation/Error/IllegalStateError.swift` | 9 | `open class IllegalStateError: AppError, @unchecked Sendable {` |
| R005 | `Sources/XXFFoundation/Error/AppError.swift` | 12 | `open class AppError: Error, CustomNSError, LocalizedError, CustomStringConvertible, @unchecked Sendable {` |
| R005 | `Sources/XXFServer/Core/DefaultControllerDispatcher.swift` | 10 | `public final class DefaultControllerDispatcher: ControllerDispatcher, @unchecked Sendable {` |
| R005 | `Sources/XXFServer/Core/ControllerRegister.swift` | 11 | `private nonisolated(unsafe) static var usedRouteGroups = Set<String>()` |
| R005 | `Sources/XXFServer/Web/LocalWebServer.swift` | 31 | `nonisolated(unsafe) public static let shared = LocalWebServer()` |
| R005 | `Sources/XXFServer/Pulse/PulseNetworkLoggerAdapter.swift` | 13 | `nonisolated(unsafe) static let shared = PulseNetworkLoggerAdapter()` |
| R005 | `Sources/XXFServer/Pulse/FakeURLSessionDataTask.swift` | 12 | `final class FakeURLSessionDataTask: URLSessionDataTask, @unchecked Sendable {` |
| R005 | `Sources/XXFServer/Interceptor/Impl/LoggerIntercetor.swift` | 12 | `open class LoggerIntercetor: Interceptor, @unchecked Sendable {` |
| R005 | `Sources/XXFKeyboard/XXFKeyboard.swift` | 111 | `public static nonisolated(unsafe) let instance = RxKeyboard.instance` |

## LOW

| Rule | File | Line | Snippet |
|---|---|---:|---|
| R006 | `Sources/XXFJson/Wrapper/Adapter/Impl/_DateParsing.swift` | 34 | `"yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX",   // 带微秒 + 时区` |
| R006 | `Sources/XXFJson/Wrapper/Adapter/Impl/_DateParsing.swift` | 35 | `"yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",      // 带毫秒 + 时区` |
| R006 | `Sources/XXFJson/Wrapper/Adapter/Impl/_DateParsing.swift` | 36 | `"yyyy-MM-dd'T'HH:mm:ssXXXXX",          // 无毫秒 + 时区` |

## Rule Notes

- `R001` (HIGH): Runtime crash path should be validated for release usage.
- `R002` (HIGH): Forced try can crash on recoverable failures.
- `R003` (MEDIUM): Forced cast may crash when type assumptions drift.
- `R004` (MEDIUM): Potential deadlock or UI stall risk.
- `R005` (MEDIUM): Concurrency safety bypass requires careful audit.
- `R006` (LOW): Unresolved marker in production code path.
