//
//  NSMetadataProtocol.swift
//  xxf_ios
//
//  Created by xxf on 6/12.
//

import Foundation

public protocol NSMetadataOperationProtocol: NSMetadataProtocol {
    func value<T>(forMetadataItem key: String) -> T?
}

/// 文件元数据协议（包含所有 Spotlight 支持的元数据）
/// 目前实现类有MDItem, URL, NSMetadataItem, NSMetadataQueryResult(字典方式),NSMetadataItemResult(纯字段方式)
/**
 | 特性                       | `MDItem`                        | `URL.resourceValues` | `NSMetadataItem`       |
 | --------------------- | --------------------------------- | --------------------------- | ---------------------------------------- |
 | 是否异步                | 否（同步）                             | 否（同步）                     | 是（异步查询结果）                         |
 | 数据源                    | Spotlight 索引                        | 文件系统原始属性          | Spotlight 查询结果                            |
 | 属性丰富度             | ⭐️⭐️⭐️⭐️⭐️（非常丰富） | ⭐️⭐️（基础属性）        | ⭐️⭐️⭐️⭐️⭐️（等同于 MDItem） |
 | 是否依赖 Spotlight | ✅ 是                                     | ❌ 否                              | ✅ 是                                                |
 | 准确度（索引前）   | ❌ 低（可能为空）              | ✅ 高                               | ❌ 低（需匹配结果）                      |
 | 准确度（索引后）   | ✅ 高                                    | ✅ 高                               | ✅ 高                                               |
 | 性能                         | ✅ 快                                    | ✅ 一般（少量访问快）  | ❌ 慢（首次返回慢）                     |
 | 实时监听                  | ❌ 无                                    | ❌ 无                               | ✅ 有                                              |
 | 适合场景                  | 元数据提取                           | 扫描真实属性                   | 搜索与监听,有严重内存缓存问题    |
 */
/**
 官方文献
 https://developer.apple.com/documentation/coreservices/file_metadata/mditem
 https://developer.apple.com/documentation/coreservices/file_metadata/mditem/common_metadata_attribute_keys
 https://developer.apple.com/library/archive/documentation/CoreServices/Reference/MetadataAttributesRef/Reference/CommonAttrs.html
 */
public protocol NSMetadataProtocol {
    // MARK: - 通用基础属性

    // 对应 st_ctimespec (ctime)
    var mdItemAttributeChangeDate: Date? { get } // 属性变更日期
    var mdItemAudiences: [String]? { get } // 受众群体
    var mdItemAuthors: [String]? { get } // 作者列表
    var mdItemAuthorAddresses: [String]? { get } // 作者地址
    var mdItemAuthorEmailAddresses: [String]? { get } // 作者邮箱
    var mdItemCity: String? { get } // 城市
    var mdItemComment: String? { get } // 注释
    var mdItemContactKeywords: [String]? { get } // 联系关键词
    var mdItemContentCreationDate: Date? { get } // 内容创建日期
    var mdItemContentModificationDate: Date? { get } // 内容修改日期
    var mdItemContentType: String? { get } // 内容类型 (UTI),eg. public.jpeg,public.folder,public.zip-archive
    /**
     ["public.jpeg","public.image", "public.data", "public.item","public.content"]
     ["com.apple.application", "com.apple.bundle", "public.directory", "public.item", "public.content"]
     ["public.plain-text", "public.text", "public.data", "public.item", "public.content"]
     */
    var mdItemContentTypeTree: [String]? { get } // 内容类型树,文件类型所“继承”的所有更通用的 Uniform Type Identifier（UTI）。
    var mdItemContributors: [String]? { get } // 贡献者
    var mdItemCopyright: String? { get } // 版权信息
    var mdItemCountry: String? { get } // 国家
    var mdItemCoverage: String? { get } // 覆盖范围
    var mdItemCreator: String? { get } // 创建者
    var mdItemDateAdded: Date? { get } // 添加日期
    var mdItemDescription: String? { get } // 描述
    var mdItemDisplayName: String? { get } // 显示名称
    var mdItemDownloadedDate: Date? { get } // 下载日期
    var mdItemDueDate: Date? { get } // 到期日期
    var mdItemDurationSeconds: Double? { get } // 持续时间(秒)
    var mdItemEditors: [String]? { get } // 编辑者
    var mdItemEmailAddresses: [String]? { get } // 电子邮件地址
    var mdItemEncodingApplications: [String]? { get } // 编码应用程序
    var mdItemFinderComment: String? { get } // Finder注释
    var mdItemFonts: [String]? { get } // 字体列表
    var mdItemHeadline: String? { get } // 标题
    var mdItemIdentifier: String? { get } // 标识符
    var mdItemInformation: String? { get } // 信息
    var mdItemInstantMessageAddresses: [String]? { get } // 即时消息地址
    var mdItemInstructions: String? { get } // 说明
    var mdItemKeywords: [String]? { get } // 关键词
    var mdItemKind: String? { get } // 种类,kMDItemKind 是本地化字段，不同语言系统中值不同。eg.JPEG 图像,文件夹
    var mdItemLanguages: [String]? { get } // 语言
    var mdItemLastUsedDate: Date? { get } // 最后使用日期
    var mdItemNamedLocation: String? { get } // 命名位置
    var mdItemOrganizations: [String]? { get } // 组织
    var mdItemParticipants: [String]? { get } // 参与者
    var mdItemPhoneNumbers: [String]? { get } // 电话号码
    var mdItemProjects: [String]? { get } // 项目
    var mdItemPublishers: [String]? { get } // 出版商
    var mdItemRecipients: [String]? { get } // 收件人
    var mdItemRecipientAddresses: [String]? { get } // 收件人地址
    var mdItemRecipientEmailAddresses: [String]? { get } // 收件人邮箱
    var mdItemRights: String? { get } // 权限
    var mdItemSecurityMethod: String? { get } // 安全方法
    var mdItemStarRating: Double? { get } // 星级评分
    var mdItemStateOrProvince: String? { get } // 州/省
    var mdItemSubject: String? { get } // 主题
    var mdItemTextContent: String? { get } // 文本内容
    var mdItemTheme: String? { get } // 主题
    var mdItemTitle: String? { get } // 标题
    var mdItemUrl: URL? { get } // URL,官方spotlight可能为空,请用fsPath
    var mdItemVersion: String? { get } // 版本
    var mdItemWhereFroms: [String]? { get } // 来源

    // MARK: - 文件系统属性

    var mdItemFSContentChangeDate: Date? { get } // 文件内容变更日期,对应st_mtimespec (mtime)
    var mdItemFSCreationDate: Date? { get } // 文件创建日期,对应st_birthtimespec (创建)
    var mdItemFSHasCustomIcon: Bool? { get } // 是否有自定义图标
    var mdItemFSInvisible: Bool { get } // 是否隐藏
    var mdItemFSIsExtensionHidden: Bool? { get } // 是否隐藏扩展名
    var mdItemFSIsStationery: Bool? { get } // 是否为模板文件
    var mdItemFSLabel: Int? { get } // Finder标签
    var mdItemFSName: String { get } // 文件名,非空
    var mdItemFSNodeCount: Int? { get } // 节点数量
    var mdItemFSOwnerGroupID: Int? { get } // 所有者组ID
    var mdItemFSOwnerUserID: Int? { get } // 所有者用户ID
    var mdItemFSPath: String { get } // 文件路径，非空
    var mdItemFSSize: Int64? { get } // 文件大小

    // MARK: - 图像属性

    var mdItemAcquisitionMake: String? { get } // 相机品牌
    var mdItemAcquisitionModel: String? { get } // 相机型号
    var mdItemAlbum: String? { get } // 相册名称
    var mdItemAltitude: Double? { get } // 海拔高度
    var mdItemAperture: Double? { get } // 光圈值
    var mdItemBitsPerSample: Int? { get } // 每样本位数
    var mdItemCameraOwner: String? { get } // 相机所有者
    var mdItemColorSpace: String? { get } // 色彩空间
    var mdItemExifVersion: String? { get } // EXIF版本
    var mdItemExposureMode: Int? { get } // 曝光模式
    var mdItemExposureProgram: Int? { get } // 曝光程序
    var mdItemExposureTimeSeconds: Double? { get } // 曝光时间(秒)
    var mdItemExposureTimeString: String? { get } // 曝光时间字符串
    var mdItemFNumber: Double? { get } // 光圈值
    var mdItemFlashOnOff: Int? { get } // 闪光灯状态
    var mdItemFocalLength: Double? { get } // 焦距
    var mdItemFocalLength35mm: Double? { get } // 35mm等效焦距
    var mdItemGPSAreaInformation: String? { get } // GPS区域信息
    var mdItemGPSDateStamp: String? { get } // GPS日期戳
    var mdItemGPSDestBearing: Double? { get } // GPS目标方位
    var mdItemGPSDestDistance: Double? { get } // GPS目标距离
    var mdItemGPSDestLatitude: Double? { get } // GPS目标纬度
    var mdItemGPSDestLongitude: Double? { get } // GPS目标经度
    var mdItemGPSDifferental: Int? { get } // GPS差分校正
    var mdItemGPSDop: Double? { get } // GPS精度
    var mdItemGPSMapDatum: String? { get } // GPS地图基准
    var mdItemGPSMeasureMode: String? { get } // GPS测量模式
    var mdItemGPSProcessingMethod: String? { get } // GPS处理方法
    var mdItemGPSStatus: String? { get } // GPS状态
    var mdItemGPSTrack: Double? { get } // GPS轨迹
    var mdItemHasAlphaChannel: Bool? { get } // 是否有Alpha通道
    var mdItemImageDirection: Double? { get } // 图像方向
    var mdItemISOSpeed: Int? { get } // ISO感光度
    var mdItemLatitude: Double? { get } // 纬度
    var mdItemLayerNames: [String]? { get } // 图层名称
    var mdItemLensModel: String? { get } // 镜头型号
    var mdItemLongitude: Double? { get } // 经度
    var mdItemMaxAperture: Double? { get } // 最大光圈
    var mdItemMeteringMode: Int? { get } // 测光模式
    var mdItemOrientation: Int? { get } // 方向
    var mdItemPixelCount: Int? { get } // 像素总数
    var mdItemPixelHeight: Int? { get } // 像素高度
    var mdItemPixelWidth: Int? { get } // 像素宽度
    var mdItemProfileName: String? { get } // 色彩配置文件名
    var mdItemRedEyeOnOff: Int? { get } // 红眼校正状态
    var mdItemResolutionHeightDpi: Int? { get } // 垂直分辨率(DPI)
    var mdItemResolutionWidthDpi: Int? { get } // 水平分辨率(DPI)
    var mdItemSpeed: Double? { get } // 速度
    var mdItemTimestamp: Date? { get } // 时间戳
    var mdItemWhiteBalance: Int? { get } // 白平衡
    var mdItemXMPCredit: String? { get } // XMP信用信息
    var mdItemXMPDigitalSourceType: String? { get } // XMP数字来源类型

    // MARK: - 音频/视频属性

    var mdItemAudioBitRate: Int? { get } // 音频比特率
    var mdItemAudioChannelCount: Int? { get } // 音频通道数
    var mdItemAudioSampleRate: Int? { get } // 音频采样率
    var mdItemAudioTrackNumber: Int? { get } // 音轨编号
    var mdItemCodecs: [String]? { get } // 编解码器
    var mdItemComposer: String? { get } // 作曲家
    var mdItemDeliveryType: String? { get } // 交付类型
    var mdItemDirector: String? { get } // 导演
    var mdItemGenre: String? { get } // 流派
    var mdItemIsGeneralMIDISequence: Bool? { get } // 是否为通用MIDI序列
    var mdItemKeySignature: String? { get } // 调号
    var mdItemLyricist: String? { get } // 作词者
    var mdItemMediaTypes: [String]? { get } // 媒体类型
    var mdItemMusicalGenre: String? { get } // 音乐流派
    var mdItemOriginalFormat: String? { get } // 原始格式
    var mdItemOriginalSource: String? { get } // 原始来源
    var mdItemPerformers: [String]? { get } // 表演者
    var mdItemProducer: String? { get } // 制作人
    var mdItemRecordingDate: Date? { get } // 录制日期
    var mdItemRecordingYear: Int? { get } // 录制年份
    var mdItemStreamable: Bool? { get } // 是否可流式传输
    var mdItemTempo: Double? { get } // 速度
    var mdItemTimeSignature: String? { get } // 拍号
    var mdItemTotalBitRate: Int? { get } // 总比特率
    var mdItemVideoBitRate: Int? { get } // 视频比特率

    // MARK: - 应用相关属性

    var mdItemApplicationCategories: [String]? { get } // 应用类别
    var mdItemCFBundleIdentifier: String? { get } // 应用包标识符
    var mdItemExecutableArchitectures: [String]? { get } // 可执行架构
    var mdItemExecutablePlatform: String? { get } // 可执行平台
    var mdItemIsApplicationManaged: Bool? { get } // 是否由应用管理
    var mdItemIsLikelyJunk: Bool? { get } // 可能是垃圾文件

    // MARK: - 媒体制作属性

    var mdItemAppleLoopDescriptors: [String]? { get } // Apple Loop描述符
    var mdItemAppleLoopsKeyFilterType: String? { get } // Apple Loop键过滤器类型
    var mdItemAppleLoopsLoopMode: String? { get } // Apple Loop循环模式
    var mdItemAppleLoopsRootKey: String? { get } // Apple Loop根键
    var mdItemAudioEncodingApplication: String? { get } // 音频编码应用
    var mdItemEXIFGPSVersion: String? { get } // EXIF GPS版本
    var mdItemGPSVersion: String? { get } // GPS版本
    var mdItemMediaExtensions: [String]? { get } // 媒体扩展
    var mdItemMusicalInstrumentCategory: String? { get } // 乐器类别
    var mdItemMusicalInstrumentName: String? { get } // 乐器名称

    // MARK: - 页面/文档属性

    var mdItemHTMLContent: String? { get } // HTML内容
    var mdItemNumberOfPages: Int? { get } // 页数
    var mdItemPageHeight: Double? { get } // 页面高度
    var mdItemPageWidth: Double? { get } // 页面宽度

    // MARK: - 其他

    var mdItemUserTags: [String]? { get } // 文件tags,本地化（localized）后的用户可见字符串
}
