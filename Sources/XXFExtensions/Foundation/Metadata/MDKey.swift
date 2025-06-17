
//
//  MDKey.swift
//  xxf_ios
//  文件源信息对应的key
//  Created by xxf on 6/12.
//
/**
 官方文献
 https://developer.apple.com/documentation/coreservices/file_metadata/mditem
 https://developer.apple.com/documentation/coreservices/file_metadata/mditem/common_metadata_attribute_keys
 https://developer.apple.com/library/archive/documentation/CoreServices/Reference/MetadataAttributesRef/Reference/CommonAttrs.html
 */
import CoreServices

public enum MDKey {
    // MARK: - 通用基础属性

    /// 文件元数据属性最后修改时间 (CFDate)
    /// 当任何元数据属性变更时更新的时间戳
    /// 用法示例: value(forAttribute: MDKey.attributeChangeDate) as? Date
    public static let attributeChangeDate = kMDItemAttributeChangeDate as String

    /// 内容的目标受众 (CFArray[CFString])
    /// 例如: ["开发者", "设计师", "教育工作者"]
    /// 用法示例: value(forAttribute: MDKey.audiences) as? [String]
    public static let audiences = kMDItemAudiences as String

    /// 内容作者列表 (CFArray[CFString])
    /// 例如: ["J.K. Rowling", "Stephen King"]
    /// 用法示例: value(forAttribute: MDKey.authors) as? [String]
    public static let authors = kMDItemAuthors as String

    /// 作者物理地址 (CFArray[CFString])
    /// 例如: ["123 Main St, New York", "456 Park Ave, London"]
    /// 用法示例: value(forAttribute: MDKey.authorAddresses) as? [String]
    public static let authorAddresses = kMDItemAuthorAddresses as String

    /// 作者电子邮箱 (CFArray[CFString])
    /// 例如: ["author@example.com", "writer@domain.com"]
    /// 用法示例: value(forAttribute: MDKey.authorEmailAddresses) as? [String]
    public static let authorEmailAddresses = kMDItemAuthorEmailAddresses as String

    /// 内容关联的城市 (CFString)
    /// 例如: "San Francisco", "Tokyo"
    /// 用法示例: value(forAttribute: MDKey.city) as? String ?? ""
    public static let city = kMDItemCity as String

    /// 用户添加的文件注释 (CFString)
    /// 例如: "项目最终版本 - 2023年审核"
    /// 用法示例: value(forAttribute: MDKey.comment) as? String ?? ""
    public static let comment = kMDItemComment as String

    /// 关联的联系人关键词 (CFArray[CFString])
    /// 例如: ["客户:张三", "供应商:李四公司"]
    /// 用法示例: value(forAttribute: MDKey.contactKeywords) as? [String]
    public static let contactKeywords = kMDItemContactKeywords as String

    /// 内容创作时间 (CFDate)
    /// 例如: 照片拍摄时间、文档创建时间
    /// 用法示例: value(forAttribute: MDKey.contentCreationDate) as? Date
    public static let contentCreationDate = kMDItemContentCreationDate as String

    /// 内容最后修改时间 (CFDate)
    /// 例如: 文档最后编辑时间
    /// 用法示例: value(forAttribute: MDKey.contentModificationDate) as? Date
    public static let contentModificationDate = kMDItemContentModificationDate as String

    /// 统一类型标识符 (UTI) (CFString)
    /// 例如: "public.jpeg", "com.adobe.pdf"
    /// 用法示例: value(forAttribute: MDKey.contentType) as? String ?? ""
    public static let contentType = kMDItemContentType as String

    /// UTI类型继承树 (CFArray[CFString])
    /// 例如: ["public.jpeg", "public.image", "public.data"]
    /// 用法示例: value(forAttribute: MDKey.contentTypeTree) as? [String]
    public static let contentTypeTree = kMDItemContentTypeTree as String

    /// 内容贡献者列表 (CFArray[CFString])
    /// 例如: ["编辑: 王五", "技术审核: 赵六"]
    /// 用法示例: value(forAttribute: MDKey.contributors) as? [String]
    public static let contributors = kMDItemContributors as String

    /// 版权声明 (CFString)
    /// 例如: "© 2023 Apple Inc. 保留所有权利"
    /// 用法示例: value(forAttribute: MDKey.copyright) as? String ?? ""
    public static let copyright = kMDItemCopyright as String

    /// 内容关联的国家 (CFString)
    /// 例如: "United States", "日本"
    /// 用法示例: value(forAttribute: MDKey.country) as? String ?? ""
    public static let country = kMDItemCountry as String

    /// 内容覆盖范围（地理/时间） (CFString)
    /// 例如: "2020-2023 全球销售数据"
    /// 用法示例: value(forAttribute: MDKey.coverage) as? String ?? ""
    public static let coverage = kMDItemCoverage as String

    /// 创建内容的应用程序 (CFString)
    /// 例如: "Adobe Photoshop CC 2023"
    /// 用法示例: value(forAttribute: MDKey.creator) as? String ?? ""
    public static let creator = kMDItemCreator as String

    /// 文件添加到当前位置的时间 (CFDate)
    /// 例如: 文件下载或移动到文件夹的时间
    /// 用法示例: value(forAttribute: MDKey.dateAdded) as? Date
    public static let dateAdded = kMDItemDateAdded as String

    /// 内容描述 (CFString)
    /// 例如: "公司年度财报 - 包含所有部门数据"
    /// 用法示例: value(forAttribute: MDKey.description) as? String ?? ""
    public static let description = kMDItemDescription as String

    /// 文件显示名称 (CFString)
    /// 例如: "季度报告.pdf" (可能不同于实际文件名)
    /// 用法示例: value(forAttribute: MDKey.displayName) as? String ?? ""
    public static let displayName = kMDItemDisplayName as String

    /// 文件下载时间 (CFDate)
    /// 例如: 从互联网下载文件的时间
    /// 用法示例: value(forAttribute: MDKey.downloadedDate) as? Date
    public static let downloadedDate = kMDItemDownloadedDate as String

    /// 任务截止日期 (CFDate)
    /// 例如: 项目提交截止日
    /// 用法示例: value(forAttribute: MDKey.dueDate) as? Date
    public static let dueDate = kMDItemDueDate as String

    /// 媒体持续时间（秒） (CFNumber)
    /// 例如: 音频长度 245.5 秒
    /// 用法示例: value(forAttribute: MDKey.durationSeconds) as? Double ?? 0.0
    public static let durationSeconds = kMDItemDurationSeconds as String

    /// 内容编辑者列表 (CFArray[CFString])
    /// 例如: ["技术编辑: 张三", "文案编辑: 李四"]
    /// 用法示例: value(forAttribute: MDKey.editors) as? [String]
    public static let editors = kMDItemEditors as String

    /// 关联的电子邮箱地址 (CFArray[CFString])
    /// 例如: ["contact@company.com", "support@domain.com"]
    /// 用法示例: value(forAttribute: MDKey.emailAddresses) as? [String]
    public static let emailAddresses = kMDItemEmailAddresses as String

    /// 编码内容的应用程序列表 (CFArray[CFString])
    /// 例如: ["Final Cut Pro", "HandBrake 1.6"]
    /// 用法示例: value(forAttribute: MDKey.encodingApplications) as? [String]
    public static let encodingApplications = kMDItemEncodingApplications as String

    /// Finder 注释 (CFString)
    /// 用户通过 Finder 添加的自定义注释
    /// 用法示例: value(forAttribute: MDKey.finderComment) as? String ?? ""
    public static let finderComment = kMDItemFinderComment as String

    /// 文档使用的字体列表 (CFArray[CFString])
    /// 例如: ["Helvetica", "Times New Roman"]
    /// 用法示例: value(forAttribute: MDKey.fonts) as? [String]
    public static let fonts = kMDItemFonts as String

    /// 内容标题/标题行 (CFString)
    /// 例如: "市场扩张计划 - 2024年度"
    /// 用法示例: value(forAttribute: MDKey.headline) as? String ?? ""
    public static let headline = kMDItemHeadline as String

    /// 内容唯一标识符 (CFString)
    /// 例如: ISBN "978-3-16-148410-0"
    /// 用法示例: value(forAttribute: MDKey.identifier) as? String ?? ""
    public static let identifier = kMDItemIdentifier as String

    /// 内容摘要信息 (CFString)
    /// 例如: "本报告包含机密财务数据"
    /// 用法示例: value(forAttribute: MDKey.information) as? String ?? ""
    public static let information = kMDItemInformation as String

    /// 即时消息地址 (CFArray[CFString])
    /// 例如: ["john@im.example.com", "sarah@chat.domain.com"]
    /// 用法示例: value(forAttribute: MDKey.instantMessageAddresses) as? [String]
    public static let instantMessageAddresses = kMDItemInstantMessageAddresses as String

    /// 使用说明 (CFString)
    /// 例如: "打印时使用A4纸，彩色模式"
    /// 用法示例: value(forAttribute: MDKey.instructions) as? String ?? ""
    public static let instructions = kMDItemInstructions as String

    /// 关键词列表 (CFArray[CFString])
    /// 例如: ["财务", "2023", "季度报告"]
    /// 用法示例: value(forAttribute: MDKey.keywords) as? [String]
    public static let keywords = kMDItemKeywords as String

    /// 文件类型描述 (CFString)
    /// 例如: "PDF 文档", "JPEG 图像"
    /// 用法示例: value(forAttribute: MDKey.kind) as? String ?? ""
    public static let kind = kMDItemKind as String

    /// 内容语言列表 (CFArray[CFString])
    /// 例如: ["zh-Hans", "en"]
    /// 用法示例: value(forAttribute: MDKey.languages) as? [String]
    public static let languages = kMDItemLanguages as String

    /// 文件最后使用时间 (CFDate)
    /// 例如: 文档最近打开时间
    /// 用法示例: value(forAttribute: MDKey.lastUsedDate) as? Date
    public static let lastUsedDate = kMDItemLastUsedDate as String

    /// 命名地理位置 (CFString)
    /// 例如: "金门大桥", "东京塔"
    /// 用法示例: value(forAttribute: MDKey.namedLocation) as? String ?? ""
    public static let namedLocation = kMDItemNamedLocation as String

    /// 关联的组织列表 (CFArray[CFString])
    /// 例如: ["Apple Inc.", "设计部"]
    /// 用法示例: value(forAttribute: MDKey.organizations) as? [String]
    public static let organizations = kMDItemOrganizations as String

    /// 内容参与者列表 (CFArray[CFString])
    /// 例如: 照片中的人物 ["张三", "李四"]
    /// 用法示例: value(forAttribute: MDKey.participants) as? [String]
    public static let participants = kMDItemParticipants as String

    /// 关联的电话号码 (CFArray[CFString])
    /// 例如: ["+1 (800) 123-4567", "+86 10 5678 1234"]
    /// 用法示例: value(forAttribute: MDKey.phoneNumbers) as? [String]
    public static let phoneNumbers = kMDItemPhoneNumbers as String

    /// 所属项目列表 (CFArray[CFString])
    /// 例如: ["火星计划", "年度财报"]
    /// 用法示例: value(forAttribute: MDKey.projects) as? [String]
    public static let projects = kMDItemProjects as String

    /// 出版商列表 (CFArray[CFString])
    /// 例如: ["O'Reilly Media", "电子工业出版社"]
    /// 用法示例: value(forAttribute: MDKey.publishers) as? [String]
    public static let publishers = kMDItemPublishers as String

    /// 收件人列表 (CFArray[CFString])
    /// 例如: 邮件接收人 ["ceo@company.com", "board@domain.com"]
    /// 用法示例: value(forAttribute: MDKey.recipients) as? [String]
    public static let recipients = kMDItemRecipients as String

    /// 收件人物理地址 (CFArray[CFString])
    /// 例如: ["456 Oak St, San Francisco", "789 Pine Ave, London"]
    /// 用法示例: value(forAttribute: MDKey.recipientAddresses) as? [String]
    public static let recipientAddresses = kMDItemRecipientAddresses as String

    /// 收件人电子邮箱 (CFArray[CFString])
    /// 例如: ["recipient@domain.com", "client@example.com"]
    /// 用法示例: value(forAttribute: MDKey.recipientEmailAddresses) as? [String]
    public static let recipientEmailAddresses = kMDItemRecipientEmailAddresses as String

    /// 权限声明 (CFString)
    /// 例如: "仅限内部使用", "知识共享署名许可"
    /// 用法示例: value(forAttribute: MDKey.rights) as? String ?? ""
    public static let rights = kMDItemRights as String

    /// 安全加密方法 (CFString)
    /// 例如: "密码保护", "AES-256"
    /// 用法示例: value(forAttribute: MDKey.securityMethod) as? String ?? ""
    public static let securityMethod = kMDItemSecurityMethod as String

    /// 用户星级评分 (CFNumber)
    /// 范围: 0-5 (例如: 4.5)
    /// 用法示例: value(forAttribute: MDKey.starRating) as? Double ?? 0.0
    public static let starRating = kMDItemStarRating as String

    /// 州/省名称 (CFString)
    /// 例如: "加利福尼亚州", "东京都"
    /// 用法示例: value(forAttribute: MDKey.stateOrProvince) as? String ?? ""
    public static let stateOrProvince = kMDItemStateOrProvince as String

    /// 内容主题 (CFString)
    /// 例如: "可持续发展", "人工智能伦理"
    /// 用法示例: value(forAttribute: MDKey.subject) as? String ?? ""
    public static let subject = kMDItemSubject as String

    /// 文本内容 (CFString)
    /// 文档的完整文本（适用于全文搜索）
    /// 用法示例: value(forAttribute: MDKey.textContent) as? String ?? ""
    public static let textContent = kMDItemTextContent as String

    /// 内容主题分类 (CFString)
    /// 例如: "科技", "环境"
    /// 用法示例: value(forAttribute: MDKey.theme) as? String ?? ""
    public static let theme = kMDItemTheme as String

    /// 内容标题 (CFString)
    /// 例如: "2024年度预算计划"
    /// 用法示例: value(forAttribute: MDKey.title) as? String ?? ""
    public static let title = kMDItemTitle as String

    /// 关联的URL (CFString)
    /// 例如: "https://www.apple.com"
    /// 用法示例: value(forAttribute: MDKey.url) as? String ?? ""
    public static let url = kMDItemURL as String

    /// 版本标识符 (CFString)
    /// 例如: "v2.1.0", "修订版3"
    /// 用法示例: value(forAttribute: MDKey.version) as? String ?? ""
    public static let version = kMDItemVersion as String

    /// 来源URL列表 (CFArray[CFString])
    /// 例如: ["https://example.com/source", "邮件附件"]
    /// 用法示例: value(forAttribute: MDKey.whereFroms) as? [String]
    public static let whereFroms = kMDItemWhereFroms as String

    // MARK: - 文件系统属性

    /// 文件内容最后修改时间 (CFDate)
    /// 文件数据实际变更的时间
    /// 用法示例: value(forAttribute: MDKey.fsContentChangeDate) as? Date
    public static let fsContentChangeDate = kMDItemFSContentChangeDate as String

    /// 文件创建时间 (CFDate)
    /// 用法示例: value(forAttribute: MDKey.fsCreationDate) as? Date
    public static let fsCreationDate = kMDItemFSCreationDate as String

    /// 文件是否有自定义图标 (CFBoolean)
    /// 用法示例: value(forAttribute: MDKey.fsHasCustomIcon) as? Bool ?? false
    public static let fsHasCustomIcon = kMDItemFSHasCustomIcon as String

    /// 文件是否隐藏 (CFBoolean)
    /// 用法示例: value(forAttribute: MDKey.fsInvisible) as? Bool ?? false
    public static let fsInvisible = kMDItemFSInvisible as String

    /// 文件扩展名是否隐藏 (CFBoolean)
    /// 用法示例: value(forAttribute: MDKey.fsIsExtensionHidden) as? Bool ?? false
    public static let fsIsExtensionHidden = kMDItemFSIsExtensionHidden as String

    /// 文件是否为模板 (CFBoolean)
    /// 用法示例: value(forAttribute: MDKey.fsIsStationery) as? Bool ?? false
    public static let fsIsStationery = kMDItemFSIsStationery as String

    /// Finder标签颜色索引 (CFNumber)
    /// 范围: 0-7 (0=无标签)
    /// 用法示例: value(forAttribute: MDKey.fsLabel) as? Int ?? 0
    public static let fsLabel = kMDItemFSLabel as String

    /// 文件名 (CFString)
    /// 包含扩展名（例如: "报告.pdf"）
    /// 用法示例: value(forAttribute: MDKey.fsName) as? String ?? ""
    public static let fsName = kMDItemFSName as String

    /// 目录中的项目数 (CFNumber)
    /// 仅适用于文件夹
    /// 用法示例: value(forAttribute: MDKey.fsNodeCount) as? Int ?? 0
    public static let fsNodeCount = kMDItemFSNodeCount as String

    /// 文件所属组ID (CFNumber)
    /// 用法示例: value(forAttribute: MDKey.fsOwnerGroupID) as? Int ?? 0
    public static let fsOwnerGroupID = kMDItemFSOwnerGroupID as String

    /// 文件所有者用户ID (CFNumber)
    /// 用法示例: value(forAttribute: MDKey.fsOwnerUserID) as? Int ?? 0
    public static let fsOwnerUserID = kMDItemFSOwnerUserID as String

    /// 文件完整路径 (CFString)
    /// 例如: "/Users/username/Documents/Report.pdf"
    /// 用法示例: value(forAttribute: MDKey.fsPath) as? String ?? ""
    public static let fsPath = kMDItemPath as String

    /// 文件大小（字节） (CFNumber)
    /// 用法示例: value(forAttribute: MDKey.fsSize) as? Int64 ?? 0
    public static let fsSize = kMDItemFSSize as String

    // MARK: - 图像属性

    /// 相机制造商 (CFString)
    /// 例如: "Canon", "Sony"
    /// 用法示例: value(forAttribute: MDKey.acquisitionMake) as? String ?? ""
    public static let acquisitionMake = kMDItemAcquisitionMake as String

    /// 相机型号 (CFString)
    /// 例如: "Canon EOS R5", "iPhone 14 Pro"
    /// 用法示例: value(forAttribute: MDKey.acquisitionModel) as? String ?? ""
    public static let acquisitionModel = kMDItemAcquisitionModel as String

    /// 相册名称 (CFString)
    /// 例如: "夏威夷度假", "生日派对"
    /// 用法示例: value(forAttribute: MDKey.album) as? String ?? ""
    public static let album = kMDItemAlbum as String

    /// 海拔高度（米） (CFNumber)
    /// 负值表示海平面以下
    /// 用法示例: value(forAttribute: MDKey.altitude) as? Double ?? 0.0
    public static let altitude = kMDItemAltitude as String

    /// 光圈值 (APEX) (CFNumber)
    /// 例如: 2.8, 5.6
    /// 用法示例: value(forAttribute: MDKey.aperture) as? Double ?? 0.0
    public static let aperture = kMDItemAperture as String

    /// 每采样位数 (CFNumber)
    /// 例如: 8 (位), 16 (位)
    /// 用法示例: value(forAttribute: MDKey.bitsPerSample) as? Int ?? 0
    public static let bitsPerSample = kMDItemBitsPerSample as String

    /// 相机所有者 (CFString)
    /// 用法示例: value(forAttribute: MDKey.cameraOwner) as? String ?? ""
    public static let cameraOwner = kMDItemCameraOwner as String

    /// 色彩空间模型 (CFString)
    /// 例如: "RGB", "CMYK"
    /// 用法示例: value(forAttribute: MDKey.colorSpace) as? String ?? ""
    public static let colorSpace = kMDItemColorSpace as String

    /// EXIF版本 (CFString)
    /// 例如: "0231"
    /// 用法示例: value(forAttribute: MDKey.exifVersion) as? String ?? ""
    public static let exifVersion = kMDItemEXIFVersion as String

    /// 曝光模式 (CFNumber)
    /// 0=自动, 1=手动, 2=自动包围曝光
    /// 用法示例: value(forAttribute: MDKey.exposureMode) as? Int ?? 0
    public static let exposureMode = kMDItemExposureMode as String

    /// 曝光程序 (CFNumber)
    /// 0=未定义, 1=手动, 2=标准, 3=光圈优先, 4=快门优先
    /// 用法示例: value(forAttribute: MDKey.exposureProgram) as? Int ?? 0
    public static let exposureProgram = kMDItemExposureProgram as String

    /// 曝光时间（秒） (CFNumber)
    /// 例如: 1/250 = 0.004
    /// 用法示例: value(forAttribute: MDKey.exposureTimeSeconds) as? Double ?? 0.0
    public static let exposureTimeSeconds = kMDItemExposureTimeSeconds as String

    /// 曝光时间（可读字符串） (CFString)
    /// 例如: "1/250", "2秒"
    /// 用法示例: value(forAttribute: MDKey.exposureTimeString) as? String ?? ""
    public static let exposureTimeString = kMDItemExposureTimeString as String

    /// 光圈值（F数） (CFNumber)
    /// 例如: 1.8, 4.0
    /// 用法示例: value(forAttribute: MDKey.fNumber) as? Double ?? 0.0
    public static let fNumber = kMDItemFNumber as String

    /// 闪光灯状态 (CFNumber)
    /// 0=未闪光, 1=闪光
    /// 用法示例: value(forAttribute: MDKey.flashOnOff) as? Int ?? 0
    public static let flashOnOff = kMDItemFlashOnOff as String

    /// 焦距（毫米） (CFNumber)
    /// 例如: 35.0, 200.0
    /// 用法示例: value(forAttribute: MDKey.focalLength) as? Double ?? 0.0
    public static let focalLength = kMDItemFocalLength as String

    /// 35mm等效焦距 (CFNumber)
    /// 例如: 50.0 (全画幅等效)
    /// 用法示例: value(forAttribute: MDKey.focalLength35mm) as? Double ?? 0.0
    public static let focalLength35mm = kMDItemFocalLength35mm as String

    /// GPS区域信息 (CFString)
    /// 用法示例: value(forAttribute: MDKey.gpsAreaInformation) as? String ?? ""
    public static let gpsAreaInformation = kMDItemGPSAreaInformation as String

    /// GPS日期标记 (CFString)
    /// 格式: "YYYY:MM:DD"
    /// 用法示例: value(forAttribute: MDKey.gpsDateStamp) as? String ?? ""
    public static let gpsDateStamp = kMDItemGPSDateStamp as String

    /// 目的地方位角（度） (CFNumber)
    /// 用法示例: value(forAttribute: MDKey.gpsDestBearing) as? Double ?? 0.0
    public static let gpsDestBearing = kMDItemGPSDestBearing as String

    /// 目的地距离（米） (CFNumber)
    /// 用法示例: value(forAttribute: MDKey.gpsDestDistance) as? Double ?? 0.0
    public static let gpsDestDistance = kMDItemGPSDestDistance as String

    /// 目的地纬度 (CFNumber)
    /// 用法示例: value(forAttribute: MDKey.gpsDestLatitude) as? Double ?? 0.0
    public static let gpsDestLatitude = kMDItemGPSDestLatitude as String

    /// 目的地经度 (CFNumber)
    /// 用法示例: value(forAttribute: MDKey.gpsDestLongitude) as? Double ?? 0.0
    public static let gpsDestLongitude = kMDItemGPSDestLongitude as String

    /// GPS差分校正 (CFNumber)
    /// 0=未应用, 1=已应用
    /// 用法示例: value(forAttribute: MDKey.gpsDifferental) as? Int ?? 0
    public static let gpsDifferental = kMDItemGPSDifferental as String

    /// GPS精度因子 (CFNumber)
    /// 例如: 2.5
    /// 用法示例: value(forAttribute: MDKey.gpsDop) as? Double ?? 0.0
    public static let gpsDop = kMDItemGPSDOP as String

    /// GPS大地基准 (CFString)
    /// 例如: "WGS-84"
    /// 用法示例: value(forAttribute: MDKey.gpsMapDatum) as? String ?? ""
    public static let gpsMapDatum = kMDItemGPSMapDatum as String

    /// GPS测量模式 (CFString)
    /// "2D" 或 "3D"
    /// 用法示例: value(forAttribute: MDKey.gpsMeasureMode) as? String ?? ""
    public static let gpsMeasureMode = kMDItemGPSMeasureMode as String

    /// GPS处理方法 (CFString)
    /// 用法示例: value(forAttribute: MDKey.gpsProcessingMethod) as? String ?? ""
    public static let gpsProcessingMethod = kMDItemGPSProcessingMethod as String

    /// GPS状态 (CFString)
    /// "A"=有效, "V"=无效
    /// 用法示例: value(forAttribute: MDKey.gpsStatus) as? String ?? ""
    public static let gpsStatus = kMDItemGPSStatus as String

    /// GPS运动方向（度） (CFNumber)
    /// 0-359.9（正北为0）
    /// 用法示例: value(forAttribute: MDKey.gpsTrack) as? Double ?? 0.0
    public static let gpsTrack = kMDItemGPSTrack as String

    /// 是否包含Alpha通道 (CFBoolean)
    /// 用法示例: value(forAttribute: MDKey.hasAlphaChannel) as? Bool ?? false
    public static let hasAlphaChannel = kMDItemHasAlphaChannel as String

    /// 图像方向（度） (CFNumber)
    /// 相对于正北方向
    /// 用法示例: value(forAttribute: MDKey.imageDirection) as? Double ?? 0.0
    public static let imageDirection = kMDItemImageDirection as String

    /// ISO感光度 (CFNumber)
    /// 例如: 100, 800, 3200
    /// 用法示例: value(forAttribute: MDKey.isoSpeed) as? Int ?? 0
    public static let isoSpeed = kMDItemISOSpeed as String

    /// 纬度（度） (CFNumber)
    /// 正值表示北纬
    /// 用法示例: value(forAttribute: MDKey.latitude) as? Double ?? 0.0
    public static let latitude = kMDItemLatitude as String

    /// 图层名称列表 (CFArray[CFString])
    /// 例如: ["背景层", "文本层"]
    /// 用法示例: value(forAttribute: MDKey.layerNames) as? [String]
    public static let layerNames = kMDItemLayerNames as String

    /// 镜头型号 (CFString)
    /// 例如: "EF 24-70mm f/2.8L II USM"
    /// 用法示例: value(forAttribute: MDKey.lensModel) as? String ?? ""
    public static let lensModel = kMDItemLensModel as String

    /// 经度（度） (CFNumber)
    /// 正值表示东经
    /// 用法示例: value(forAttribute: MDKey.longitude) as? Double ?? 0.0
    public static let longitude = kMDItemLongitude as String

    /// 最大光圈值 (CFNumber)
    /// 例如: 1.4, 2.8
    /// 用法示例: value(forAttribute: MDKey.maxAperture) as? Double ?? 0.0
    public static let maxAperture = kMDItemMaxAperture as String

    /// 测光模式 (CFNumber)
    /// 1=平均, 2=中央重点, 3=点测, 4=多点, 5=模式
    /// 用法示例: value(forAttribute: MDKey.meteringMode) as? Int ?? 0
    public static let meteringMode = kMDItemMeteringMode as String

    /// 图像方向 (CFNumber)
    /// 0=横向, 1=纵向
    /// 用法示例: value(forAttribute: MDKey.orientation) as? Int ?? 0
    public static let orientation = kMDItemOrientation as String

    /// 像素总数 (CFNumber)
    /// 例如: 12000000 (12MP)
    /// 用法示例: value(forAttribute: MDKey.pixelCount) as? Int ?? 0
    public static let pixelCount = kMDItemPixelCount as String

    /// 像素高度 (CFNumber)
    /// 例如: 3024 (像素)
    /// 用法示例: value(forAttribute: MDKey.pixelHeight) as? Int ?? 0
    public static let pixelHeight = kMDItemPixelHeight as String

    /// 像素宽度 (CFNumber)
    /// 例如: 4032 (像素)
    /// 用法示例: value(forAttribute: MDKey.pixelWidth) as? Int ?? 0
    public static let pixelWidth = kMDItemPixelWidth as String

    /// 色彩配置文件名 (CFString)
    /// 例如: "sRGB IEC61966-2.1"
    /// 用法示例: value(forAttribute: MDKey.profileName) as? String ?? ""
    public static let profileName = kMDItemProfileName as String

    /// 红眼校正状态 (CFNumber)
    /// 0=未校正, 1=已校正
    /// 用法示例: value(forAttribute: MDKey.redEyeOnOff) as? Int ?? 0
    public static let redEyeOnOff = kMDItemRedEyeOnOff as String

    /// 垂直分辨率（DPI） (CFNumber)
    /// 用法示例: value(forAttribute: MDKey.resolutionHeightDpi) as? Int ?? 0
    public static let resolutionHeightDpi = kMDItemResolutionHeightDPI as String

    /// 水平分辨率（DPI） (CFNumber)
    /// 用法示例: value(forAttribute: MDKey.resolutionWidthDpi) as? Int ?? 0
    public static let resolutionWidthDpi = kMDItemResolutionWidthDPI as String

    /// 移动速度（公里/小时） (CFNumber)
    /// 用法示例: value(forAttribute: MDKey.speed) as? Double ?? 0.0
    public static let speed = kMDItemSpeed as String

    /// 时间戳 (CFDate)
    /// 内容捕获的精确时间
    /// 用法示例: value(forAttribute: MDKey.timestamp) as? Date
    public static let timestamp = kMDItemTimestamp as String

    /// 白平衡设置 (CFNumber)
    /// 0=自动, 1=手动
    /// 用法示例: value(forAttribute: MDKey.whiteBalance) as? Int ?? 0
    public static let whiteBalance = kMDItemWhiteBalance as String

    /// XMP作者署名 (CFString)
    /// 用法示例: value(forAttribute: MDKey.xmpCredit) as? String ?? ""
    public static let xmpCredit = kMDItemXMPCredit as String

    /// XMP数字来源类型 (CFString)
    /// 用法示例: value(forAttribute: MDKey.xmpDigitalSourceType) as? String ?? ""
    public static let xmpDigitalSourceType = kMDItemXMPDigitalSourceType as String

    // MARK: - 音频/视频属性

    /// 音频比特率（bps） (CFNumber)
    /// 例如: 256000 (256 kbps)
    /// 用法示例: value(forAttribute: MDKey.audioBitRate) as? Int ?? 0
    public static let audioBitRate = kMDItemAudioBitRate as String

    /// 音频通道数 (CFNumber)
    /// 例如: 2 (立体声), 6 (5.1环绕声)
    /// 用法示例: value(forAttribute: MDKey.audioChannelCount) as? Int ?? 0
    public static let audioChannelCount = kMDItemAudioChannelCount as String

    /// 音频采样率（Hz） (CFNumber)
    /// 例如: 44100, 48000
    /// 用法示例: value(forAttribute: MDKey.audioSampleRate) as? Int ?? 0
    public static let audioSampleRate = kMDItemAudioSampleRate as String

    /// 音轨编号 (CFNumber)
    /// 例如: 3 (专辑中的第三首曲目)
    /// 用法示例: value(forAttribute: MDKey.audioTrackNumber) as? Int ?? 0
    public static let audioTrackNumber = kMDItemAudioTrackNumber as String

    /// 编解码器列表 (CFArray[CFString])
    /// 例如: ["H.264", "AAC"]
    /// 用法示例: value(forAttribute: MDKey.codecs) as? [String]
    public static let codecs = kMDItemCodecs as String

    /// 作曲者 (CFString)
    /// 例如: "Hans Zimmer", "久石让"
    /// 用法示例: value(forAttribute: MDKey.composer) as? String ?? ""
    public static let composer = kMDItemComposer as String

    /// 媒体传输类型 (CFString)
    /// 例如: "快速启动", "实时流"
    /// 用法示例: value(forAttribute: MDKey.deliveryType) as? String ?? ""
    public static let deliveryType = kMDItemDeliveryType as String

    /// 导演 (CFString)
    /// 例如: "Christopher Nolan", "宫崎骏"
    /// 用法示例: value(forAttribute: MDKey.director) as? String ?? ""
    public static let director = kMDItemDirector as String

    /// 流派 (CFString)
    /// 例如: "科幻", "纪录片"
    /// 用法示例: value(forAttribute: MDKey.genre) as? String ?? ""
    public static let genre = kMDItemGenre as String

    /// 是否为通用MIDI序列 (CFBoolean)
    /// 用法示例: value(forAttribute: MDKey.isGeneralMIDISequence) as? Bool ?? false
    public static let isGeneralMIDISequence = kMDItemIsGeneralMIDISequence as String

    /// 音乐调号 (CFString)
    /// 例如: "C大调", "D小调"
    /// 用法示例: value(forAttribute: MDKey.keySignature) as? String ?? ""
    public static let keySignature = kMDItemKeySignature as String

    /// 作词者 (CFString)
    /// 用法示例: value(forAttribute: MDKey.lyricist) as? String ?? ""
    public static let lyricist = kMDItemLyricist as String

    /// 媒体类型列表 (CFArray[CFString])
    /// 例如: ["视频", "音频"]
    /// 用法示例: value(forAttribute: MDKey.mediaTypes) as? [String]
    public static let mediaTypes = kMDItemMediaTypes as String

    /// 音乐流派 (CFString)
    /// 例如: "古典", "摇滚", "爵士"
    /// 用法示例: value(forAttribute: MDKey.musicalGenre) as? String ?? ""
    public static let musicalGenre = kMDItemMusicalGenre as String

    /// 原始格式 (CFString)
    /// 例如: "35mm胶片", "数字母带"
    /// 用法示例: value(forAttribute: MDKey.originalFormat) as? String ?? ""
    public static let originalFormat = kMDItemOriginalFormat as String

    /// 原始来源 (CFString)
    /// 例如: "电影摄影机", "现场录音"
    /// 用法示例: value(forAttribute: MDKey.originalSource) as? String ?? ""
    public static let originalSource = kMDItemOriginalSource as String

    /// 表演者列表 (CFArray[CFString])
    /// 例如: ["Tom Hanks", "Meryl Streep"]
    /// 用法示例: value(forAttribute: MDKey.performers) as? [String]
    public static let performers = kMDItemPerformers as String

    /// 制片人 (CFString)
    /// 用法示例: value(forAttribute: MDKey.producer) as? String ?? ""
    public static let producer = kMDItemProducer as String

    /// 录制日期 (CFDate)
    /// 用法示例: value(forAttribute: MDKey.recordingDate) as? Date
    public static let recordingDate = kMDItemRecordingDate as String

    /// 录制年份 (CFNumber)
    /// 例如: 2023
    /// 用法示例: value(forAttribute: MDKey.recordingYear) as? Int ?? 0
    public static let recordingYear = kMDItemRecordingYear as String

    /// 是否支持流媒体 (CFBoolean)
    /// 用法示例: value(forAttribute: MDKey.streamable) as? Bool ?? false
    public static let streamable = kMDItemStreamable as String

    /// 音乐速度（BPM） (CFNumber)
    /// 例如: 120.0
    /// 用法示例: value(forAttribute: MDKey.tempo) as? Double ?? 0.0
    public static let tempo = kMDItemTempo as String

    /// 音乐拍号 (CFString)
    /// 例如: "4/4", "6/8"
    /// 用法示例: value(forAttribute: MDKey.timeSignature) as? String ?? ""
    public static let timeSignature = kMDItemTimeSignature as String

    /// 总比特率（bps） (CFNumber)
    /// 音频+视频组合比特率
    /// 用法示例: value(forAttribute: MDKey.totalBitRate) as? Int ?? 0
    public static let totalBitRate = kMDItemTotalBitRate as String

    /// 视频比特率（bps） (CFNumber)
    /// 例如: 5000000 (5 Mbps)
    /// 用法示例: value(forAttribute: MDKey.videoBitRate) as? Int ?? 0
    public static let videoBitRate = kMDItemVideoBitRate as String

    // MARK: - 应用相关属性

    /// 应用分类列表 (CFArray[CFString])
    /// 例如: ["工具", "效率"]
    /// 用法示例: value(forAttribute: MDKey.applicationCategories) as? [String]
    public static let applicationCategories = kMDItemApplicationCategories as String

    /// 应用Bundle标识符 (CFString)
    /// 例如: "com.apple.Keynote"
    /// 用法示例: value(forAttribute: MDKey.cfBundleIdentifier) as? String ?? ""
    public static let cfBundleIdentifier = kMDItemCFBundleIdentifier as String

    /// 可执行文件支持的架构 (CFArray[CFString])
    /// 例如: ["x86_64", "arm64"]
    /// 用法示例: value(forAttribute: MDKey.executableArchitectures) as? [String]
    public static let executableArchitectures = kMDItemExecutableArchitectures as String

    /// 可执行平台要求 (CFString)
    /// 例如: "macOS"
    /// 用法示例: value(forAttribute: MDKey.executablePlatform) as? String ?? ""
    public static let executablePlatform = kMDItemExecutablePlatform as String

    /// 是否由应用管理 (CFBoolean)
    /// 例如: iCloud 托管文件
    /// 用法示例: value(forAttribute: MDKey.isApplicationManaged) as? Bool ?? false
    public static let isApplicationManaged = kMDItemIsApplicationManaged as String

    /// 是否可能为垃圾内容 (CFBoolean)
    /// 主要应用于邮件判断
    /// 用法示例: value(forAttribute: MDKey.isLikelyJunk) as? Bool ?? false
    public static let isLikelyJunk = kMDItemIsLikelyJunk as String

    // MARK: - 媒体制作属性

    /// Apple Loop描述符列表 (CFArray[CFString])
    /// 例如: ["原声", "电子"]
    /// 用法示例: value(forAttribute: MDKey.appleLoopDescriptors) as? [String]
    public static let appleLoopDescriptors = kMDItemAppleLoopDescriptors as String

    /// Apple Loop键筛选类型 (CFString)
    /// 值: "AnyKey", "Minor", "Major", "NeitherKey", "BothKeys"
    /// 用法示例: value(forAttribute: MDKey.appleLoopsKeyFilterType) as? String ?? ""
    public static let appleLoopsKeyFilterType = kMDItemAppleLoopsKeyFilterType as String

    /// Apple Loop循环模式 (CFString)
    /// 值: "Looping", "Non-looping"
    /// 用法示例: value(forAttribute: MDKey.appleLoopsLoopMode) as? String ?? ""
    public static let appleLoopsLoopMode = kMDItemAppleLoopsLoopMode as String

    /// Apple Loop根键 (CFString)
    /// 值: "C", "C#/Db", "D", "D#/Eb", ..., "NoKey"
    /// 用法示例: value(forAttribute: MDKey.appleLoopsRootKey) as? String ?? ""
    public static let appleLoopsRootKey = kMDItemAppleLoopsRootKey as String

    /// 音频编码应用程序 (CFString)
    /// 例如: "Logic Pro", "GarageBand"
    /// 用法示例: value(forAttribute: MDKey.audioEncodingApplication) as? String ?? ""
    public static let audioEncodingApplication = kMDItemAudioEncodingApplication as String

    /// EXIF GPS版本 (CFString)
    /// 用法示例: value(forAttribute: MDKey.exifGpsVersion) as? String ?? ""
    public static let exifGpsVersion = kMDItemEXIFGPSVersion as String

    /// GPS版本 (CFString)
    /// 与 exifGpsVersion 相同，提供别名
    /// 用法示例: value(forAttribute: MDKey.gpsVersion) as? String ?? ""
    public static let gpsVersion = kMDItemEXIFGPSVersion as String

    /// 媒体文件扩展名 (CFArray[CFString])
    /// 例如: ["mov", "mp4"] (macOS 15.0+)
    /// 用法示例: value(forAttribute: MDKey.mediaExtensions) as? [String]
    @available(macOS 15.0, *)
    public static let mediaExtensions = kMDItemMediaExtensions as String

    /// 乐器类别 (CFString)
    /// 例如: "弦乐器", "键盘乐器"
    /// 用法示例: value(forAttribute: MDKey.musicalInstrumentCategory) as? String ?? ""
    public static let musicalInstrumentCategory = kMDItemMusicalInstrumentCategory as String

    /// 乐器名称 (CFString)
    /// 例如: "钢琴", "小提琴"
    /// 用法示例: value(forAttribute: MDKey.musicalInstrumentName) as? String ?? ""
    public static let musicalInstrumentName = kMDItemMusicalInstrumentName as String

    // MARK: - 页面/文档属性

    /// HTML内容 (CFString)
    /// 文档的完整HTML内容
    /// 用法示例: value(forAttribute: MDKey.htmlContent) as? String ?? ""
    public static let htmlContent = kMDItemHTMLContent as String

    /// 总页数 (CFNumber)
    /// 例如: 24
    /// 用法示例: value(forAttribute: MDKey.numberOfPages) as? Int ?? 0
    public static let numberOfPages = kMDItemNumberOfPages as String

    /// 页面高度（点） (CFNumber)
    /// 1点 = 1/72英寸
    /// 用法示例: value(forAttribute: MDKey.pageHeight) as? Double ?? 0.0
    public static let pageHeight = kMDItemPageHeight as String

    /// 页面宽度（点） (CFNumber)
    /// 1点 = 1/72英寸
    /// 用法示例: value(forAttribute: MDKey.pageWidth) as? Double ?? 0.0
    public static let pageWidth = kMDItemPageWidth as String
}
