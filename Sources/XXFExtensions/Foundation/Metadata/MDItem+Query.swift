
//
//  MDItem+Query.swift
//  xxf_ios
//
//  Created by xxf on 6/12.
//

import CoreServices
import Foundation

// 所有支持的 MDItem 字段
extension MDItem: NSMetadataProtocol, NSMetadataOperationProtocol {
    public func value<T>(forMetadataItem key: String) -> T? {
        MDItemCopyAttribute(self, key as CFString) as? T
    }

    // MARK: - 通用基础属性

    /// 属性变更日期 (格式: Date) - 文件元数据最后修改的日期
    public var mdItemAttributeChangeDate: Date? { value(forMetadataItem: MDKey.attributeChangeDate) }

    /// 受众群体 (格式: [String]) - 文件的目标受众列表
    public var mdItemAudiences: [String]? { value(forMetadataItem: MDKey.audiences) }

    /// 作者列表 (格式: [String]) - 文件的作者姓名列表
    public var mdItemAuthors: [String]? { value(forMetadataItem: MDKey.authors) }

    /// 作者地址 (格式: [String]) - 作者的邮政地址列表
    public var mdItemAuthorAddresses: [String]? { value(forMetadataItem: MDKey.authorAddresses) }

    /// 作者邮箱 (格式: [String]) - 作者的电子邮件地址列表
    public var mdItemAuthorEmailAddresses: [String]? { value(forMetadataItem: MDKey.authorEmailAddresses) }

    /// 城市 (格式: String) - 与文件关联的城市名称
    public var mdItemCity: String? { value(forMetadataItem: MDKey.city) }

    /// 注释 (格式: String) - 用户提供的文件注释
    public var mdItemComment: String? { value(forMetadataItem: MDKey.comment) }

    /// 联系关键词 (格式: [String]) - 与联系人相关的关键词
    public var mdItemContactKeywords: [String]? { value(forMetadataItem: MDKey.contactKeywords) }

    /// 内容创建日期 (格式: Date) - 文件内容最初创建的日期
    public var mdItemContentCreationDate: Date? { value(forMetadataItem: MDKey.contentCreationDate) }

    /// 内容修改日期 (格式: Date) - 文件内容最后修改的日期
    public var mdItemContentModificationDate: Date? { value(forMetadataItem: MDKey.contentModificationDate) }

    /// 内容类型 (格式: String) - 文件的统一类型标识符 (UTI)，如 "public.jpeg"
    public var mdItemContentType: String? { value(forMetadataItem: MDKey.contentType) }

    /// 内容类型树 (格式: [String]) - 文件的所有UTI层次结构
    public var mdItemContentTypeTree: [String]? { value(forMetadataItem: MDKey.contentTypeTree) }

    /// 贡献者 (格式: [String]) - 为文件内容做出贡献的人员列表
    public var mdItemContributors: [String]? { value(forMetadataItem: MDKey.contributors) }

    /// 版权信息 (格式: String) - 文件的版权声明
    public var mdItemCopyright: String? { value(forMetadataItem: MDKey.copyright) }

    /// 国家 (格式: String) - 与文件关联的国家名称
    public var mdItemCountry: String? { value(forMetadataItem: MDKey.country) }

    /// 覆盖范围 (格式: String) - 文件内容的时空覆盖范围
    public var mdItemCoverage: String? { value(forMetadataItem: MDKey.coverage) }

    /// 创建者 (格式: String) - 创建文件的应用程序名称
    public var mdItemCreator: String? { value(forMetadataItem: MDKey.creator) }

    /// 添加日期 (格式: Date) - 文件添加到当前位置的日期
    public var mdItemDateAdded: Date? { value(forMetadataItem: MDKey.dateAdded) }

    /// 描述 (格式: String) - 文件内容的文本描述
    public var mdItemDescription: String? { value(forMetadataItem: MDKey.description) }

    /// 显示名称 (格式: String) - 文件的用户可见名称
    public var mdItemDisplayName: String? { value(forMetadataItem: MDKey.displayName) }

    /// 下载日期 (格式: Date) - 文件从互联网下载的日期
    public var mdItemDownloadedDate: Date? { value(forMetadataItem: MDKey.downloadedDate) }

    /// 到期日期 (格式: Date) - 文件到期的日期
    public var mdItemDueDate: Date? { value(forMetadataItem: MDKey.dueDate) }

    /// 持续时间(秒) (格式: Double) - 媒体文件的持续时间(以秒为单位)
    public var mdItemDurationSeconds: Double? { value(forMetadataItem: MDKey.durationSeconds) }

    /// 编辑者 (格式: [String]) - 编辑过文件的人员列表
    public var mdItemEditors: [String]? { value(forMetadataItem: MDKey.editors) }

    /// 电子邮件地址 (格式: [String]) - 与文件关联的电子邮件地址
    public var mdItemEmailAddresses: [String]? { value(forMetadataItem: MDKey.emailAddresses) }

    /// 编码应用程序 (格式: [String]) - 用于编码文件的应用程序列表
    public var mdItemEncodingApplications: [String]? { value(forMetadataItem: MDKey.encodingApplications) }

    /// Finder注释 (格式: String) - Finder中显示的注释
    public var mdItemFinderComment: String? { value(forMetadataItem: MDKey.finderComment) }

    /// 字体列表 (格式: [String]) - 文档中使用的字体名称列表
    public var mdItemFonts: [String]? { value(forMetadataItem: MDKey.fonts) }

    /// 标题 (格式: String) - 文件的标题或标题行
    public var mdItemHeadline: String? { value(forMetadataItem: MDKey.headline) }

    /// 标识符 (格式: String) - 文件的唯一标识符
    public var mdItemIdentifier: String? { value(forMetadataItem: MDKey.identifier) }

    /// 信息 (格式: String) - 关于文件的其他信息
    public var mdItemInformation: String? { value(forMetadataItem: MDKey.information) }

    /// 即时消息地址 (格式: [String]) - 与文件关联的即时消息地址
    public var mdItemInstantMessageAddresses: [String]? { value(forMetadataItem: MDKey.instantMessageAddresses) }

    /// 说明 (格式: String) - 如何使用文件的说明
    public var mdItemInstructions: String? { value(forMetadataItem: MDKey.instructions) }

    /// 关键词 (格式: [String]) - 描述文件内容的关键词
    public var mdItemKeywords: [String]? { value(forMetadataItem: MDKey.keywords) }

    /// 种类 (格式: String) - 用户可见的文件类型描述，如 "JPEG图像"
    public var mdItemKind: String? { value(forMetadataItem: MDKey.kind) }

    /// 语言 (格式: [String]) - 文件内容的语言代码列表，如 ["en", "zh"]
    public var mdItemLanguages: [String]? { value(forMetadataItem: MDKey.languages) }

    /// 最后使用日期 (格式: Date) - 文件最后一次被访问的日期
    public var mdItemLastUsedDate: Date? { value(forMetadataItem: MDKey.lastUsedDate) }

    /// 命名位置 (格式: String) - 与文件关联的命名位置
    public var mdItemNamedLocation: String? { value(forMetadataItem: MDKey.namedLocation) }

    /// 组织 (格式: [String]) - 与文件关联的组织名称列表
    public var mdItemOrganizations: [String]? { value(forMetadataItem: MDKey.organizations) }

    /// 参与者 (格式: [String]) - 文件内容中的参与者列表
    public var mdItemParticipants: [String]? { value(forMetadataItem: MDKey.participants) }

    /// 电话号码 (格式: [String]) - 与文件关联的电话号码
    public var mdItemPhoneNumbers: [String]? { value(forMetadataItem: MDKey.phoneNumbers) }

    /// 项目 (格式: [String]) - 与文件关联的项目名称列表
    public var mdItemProjects: [String]? { value(forMetadataItem: MDKey.projects) }

    /// 出版商 (格式: [String]) - 文件内容的出版商列表
    public var mdItemPublishers: [String]? { value(forMetadataItem: MDKey.publishers) }

    /// 收件人 (格式: [String]) - 文件的目标收件人列表
    public var mdItemRecipients: [String]? { value(forMetadataItem: MDKey.recipients) }

    /// 收件人地址 (格式: [String]) - 收件人的邮政地址列表
    public var mdItemRecipientAddresses: [String]? { value(forMetadataItem: MDKey.recipientAddresses) }

    /// 收件人邮箱 (格式: [String]) - 收件人的电子邮件地址列表
    public var mdItemRecipientEmailAddresses: [String]? { value(forMetadataItem: MDKey.recipientEmailAddresses) }

    /// 权限 (格式: String) - 文件的使用权限信息
    public var mdItemRights: String? { value(forMetadataItem: MDKey.rights) }

    /// 安全方法 (格式: String) - 文件使用的安全方法
    public var mdItemSecurityMethod: String? { value(forMetadataItem: MDKey.securityMethod) }

    /// 星级评分 (格式: Double) - 用户对文件的评分(通常0-5)
    public var mdItemStarRating: Double? { value(forMetadataItem: MDKey.starRating) }

    /// 州/省 (格式: String) - 与文件关联的州或省名称
    public var mdItemStateOrProvince: String? { value(forMetadataItem: MDKey.stateOrProvince) }

    /// 主题 (格式: String) - 文件内容的主题
    public var mdItemSubject: String? { value(forMetadataItem: MDKey.subject) }

    /// 文本内容 (格式: String) - 文件的原始文本内容
    public var mdItemTextContent: String? { value(forMetadataItem: MDKey.textContent) }

    /// 主题 (格式: String) - 文件内容的主题或类别
    public var mdItemTheme: String? { value(forMetadataItem: MDKey.theme) }

    /// 标题 (格式: String) - 文件的标题
    public var mdItemTitle: String? { value(forMetadataItem: MDKey.title) }

    /// URL (格式: String) - 与文件关联的URL
    public var mdItemUrl: String? { value(forMetadataItem: MDKey.url) }

    /// 版本 (格式: String) - 文件的版本号
    public var mdItemVersion: String? { value(forMetadataItem: MDKey.version) }

    /// 来源 (格式: [String]) - 文件下载来源的URL列表
    public var mdItemWhereFroms: [String]? { value(forMetadataItem: MDKey.whereFroms) }

    // MARK: - 文件系统属性

    /// 文件内容变更日期 (格式: Date) - 文件内容最后修改的日期
    public var mdItemFSContentChangeDate: Date? { value(forMetadataItem: MDKey.fsContentChangeDate) }

    /// 文件创建日期 (格式: Date) - 文件在文件系统中创建的日期
    public var mdItemFSCreationDate: Date? { value(forMetadataItem: MDKey.fsCreationDate) }

    /// 是否有自定义图标 (格式: Bool) - 文件是否有自定义图标
    public var mdItemFSHasCustomIcon: Bool? { value(forMetadataItem: MDKey.fsHasCustomIcon) }

    /// 是否隐藏 (格式: Bool) - 文件是否在Finder中隐藏
    public var mdItemFSInvisible: Bool? { value(forMetadataItem: MDKey.fsInvisible) }

    /// 是否隐藏扩展名 (格式: Bool) - 文件扩展名是否隐藏
    public var mdItemFSIsExtensionHidden: Bool? { value(forMetadataItem: MDKey.fsIsExtensionHidden) }

    /// 是否为模板文件 (格式: Bool) - 文件是否为模板文件
    public var mdItemFSIsStationery: Bool? { value(forMetadataItem: MDKey.fsIsStationery) }

    /// Finder标签 (格式: Int) - Finder标签颜色索引(0-7)
    public var mdItemFSLabel: Int? { value(forMetadataItem: MDKey.fsLabel) }

    /// 文件名 (格式: String) - 文件的名称(包括扩展名)
    public var mdItemFSName: String? { value(forMetadataItem: MDKey.fsName) }

    /// 节点数量 (格式: Int) - 目录包含的项目数(仅目录有效)
    public var mdItemFSNodeCount: Int? { value(forMetadataItem: MDKey.fsNodeCount) }

    /// 所有者组ID (格式: Int) - 文件所有者组的ID
    public var mdItemFSOwnerGroupID: Int? { value(forMetadataItem: MDKey.fsOwnerGroupID) }

    /// 所有者用户ID (格式: Int) - 文件所有者的用户ID
    public var mdItemFSOwnerUserID: Int? { value(forMetadataItem: MDKey.fsOwnerUserID) }

    /// 文件路径 (格式: String) - 文件的完整路径
    public var mdItemFSPath: String? { value(forMetadataItem: MDKey.fsPath) }

    /// 文件大小 (格式: Int) - 文件大小(以字节为单位)
    public var mdItemFSSize: Int? { value(forMetadataItem: MDKey.fsSize) }

    // MARK: - 图像属性

    /// 相机品牌 (格式: String) - 拍摄照片的相机品牌
    public var mdItemAcquisitionMake: String? { value(forMetadataItem: MDKey.acquisitionMake) }

    /// 相机型号 (格式: String) - 拍摄照片的相机型号
    public var mdItemAcquisitionModel: String? { value(forMetadataItem: MDKey.acquisitionModel) }

    /// 相册名称 (格式: String) - 照片所属的相册名称
    public var mdItemAlbum: String? { value(forMetadataItem: MDKey.album) }

    /// 海拔高度 (格式: Double) - 拍摄地点的海拔高度(米)
    public var mdItemAltitude: Double? { value(forMetadataItem: MDKey.altitude) }

    /// 光圈值 (格式: Double) - 拍摄时的光圈值(f-number)
    public var mdItemAperture: Double? { value(forMetadataItem: MDKey.aperture) }

    /// 每样本位数 (格式: Int) - 图像每个颜色分量的位数
    public var mdItemBitsPerSample: Int? { value(forMetadataItem: MDKey.bitsPerSample) }

    /// 相机所有者 (格式: String) - 相机所有者的姓名
    public var mdItemCameraOwner: String? { value(forMetadataItem: MDKey.cameraOwner) }

    /// 色彩空间 (格式: String) - 图像使用的色彩空间，如 "RGB", "CMYK"
    public var mdItemColorSpace: String? { value(forMetadataItem: MDKey.colorSpace) }

    /// EXIF版本 (格式: String) - EXIF元数据的版本
    public var mdItemExifVersion: String? { value(forMetadataItem: MDKey.exifVersion) }

    /// 曝光模式 (格式: Int) - 相机曝光模式(1=手动,2=自动,3=自动包围)
    public var mdItemExposureMode: Int? { value(forMetadataItem: MDKey.exposureMode) }

    /// 曝光程序 (格式: Int) - 相机使用的曝光程序(1=手动,2=正常,3=光圈优先等)
    public var mdItemExposureProgram: Int? { value(forMetadataItem: MDKey.exposureProgram) }

    /// 曝光时间(秒) (格式: Double) - 快门速度(以秒为单位)
    public var mdItemExposureTimeSeconds: Double? { value(forMetadataItem: MDKey.exposureTimeSeconds) }

    /// 曝光时间字符串 (格式: String) - 人类可读的曝光时间，如 "1/125"
    public var mdItemExposureTimeString: String? { value(forMetadataItem: MDKey.exposureTimeString) }

    /// 光圈值 (格式: Double) - 拍摄时的光圈值(f-number)
    public var mdItemFNumber: Double? { value(forMetadataItem: MDKey.fNumber) }

    /// 闪光灯状态 (格式: Int) - 闪光灯是否触发(0=关闭,1=开启)
    public var mdItemFlashOnOff: Int? { value(forMetadataItem: MDKey.flashOnOff) }

    /// 焦距 (格式: Double) - 拍摄时的实际焦距(毫米)
    public var mdItemFocalLength: Double? { value(forMetadataItem: MDKey.focalLength) }

    /// 35mm等效焦距 (格式: Double) - 35mm胶片等效焦距(毫米)
    public var mdItemFocalLength35mm: Double? { value(forMetadataItem: MDKey.focalLength35mm) }

    /// GPS区域信息 (格式: String) - GPS区域描述
    public var mdItemGPSAreaInformation: String? { value(forMetadataItem: MDKey.gpsAreaInformation) }

    /// GPS日期戳 (格式: String) - GPS日期记录(格式: "YYYY:MM:DD")
    public var mdItemGPSDateStamp: String? { value(forMetadataItem: MDKey.gpsDateStamp) }

    /// GPS目标方位 (格式: Double) - 相对于真北的目标方位角(度数)
    public var mdItemGPSDestBearing: Double? { value(forMetadataItem: MDKey.gpsDestBearing) }

    /// GPS目标距离 (格式: Double) - 到目标的距离(米)
    public var mdItemGPSDestDistance: Double? { value(forMetadataItem: MDKey.gpsDestDistance) }

    /// GPS目标纬度 (格式: Double) - 目标地点的纬度
    public var mdItemGPSDestLatitude: Double? { value(forMetadataItem: MDKey.gpsDestLatitude) }

    /// GPS目标经度 (格式: Double) - 目标地点的经度
    public var mdItemGPSDestLongitude: Double? { value(forMetadataItem: MDKey.gpsDestLongitude) }

    /// GPS差分校正 (格式: Int) - 是否应用差分GPS校正(0=无,1=已应用)
    public var mdItemGPSDifferental: Int? { value(forMetadataItem: MDKey.gpsDifferental) }

    /// GPS精度 (格式: Double) - GPS精度(0-100)
    public var mdItemGPSDop: Double? { value(forMetadataItem: MDKey.gpsDop) }

    /// GPS地图基准 (格式: String) - GPS使用的地图基准
    public var mdItemGPSMapDatum: String? { value(forMetadataItem: MDKey.gpsMapDatum) }

    /// GPS测量模式 (格式: String) - GPS测量模式，如 "2-dimensional"
    public var mdItemGPSMeasureMode: String? { value(forMetadataItem: MDKey.gpsMeasureMode) }

    /// GPS处理方法 (格式: String) - GPS位置计算方法
    public var mdItemGPSProcessingMethod: String? { value(forMetadataItem: MDKey.gpsProcessingMethod) }

    /// GPS状态 (格式: String) - GPS接收器状态，如 "A"(活动)或 "V"(无效)
    public var mdItemGPSStatus: String? { value(forMetadataItem: MDKey.gpsStatus) }

    /// GPS轨迹 (格式: Double) - 相对于真北的运动方向(度数)
    public var mdItemGPSTrack: Double? { value(forMetadataItem: MDKey.gpsTrack) }

    /// 是否有Alpha通道 (格式: Bool) - 图像是否包含Alpha通道
    public var mdItemHasAlphaChannel: Bool? { value(forMetadataItem: MDKey.hasAlphaChannel) }

    /// 图像方向 (格式: Double) - 拍摄时相机相对于真北的方向(度数)
    public var mdItemImageDirection: Double? { value(forMetadataItem: MDKey.imageDirection) }

    /// ISO感光度 (格式: Int) - 相机ISO感光度设置
    public var mdItemISOSpeed: Int? { value(forMetadataItem: MDKey.isoSpeed) }

    /// 纬度 (格式: Double) - 拍摄地点的纬度
    public var mdItemLatitude: Double? { value(forMetadataItem: MDKey.latitude) }

    /// 图层名称 (格式: [String]) - 图像中图层的名称列表
    public var mdItemLayerNames: [String]? { value(forMetadataItem: MDKey.layerNames) }

    /// 镜头型号 (格式: String) - 相机镜头的型号
    public var mdItemLensModel: String? { value(forMetadataItem: MDKey.lensModel) }

    /// 经度 (格式: Double) - 拍摄地点的经度
    public var mdItemLongitude: Double? { value(forMetadataItem: MDKey.longitude) }

    /// 最大光圈 (格式: Double) - 镜头的最大光圈值
    public var mdItemMaxAperture: Double? { value(forMetadataItem: MDKey.maxAperture) }

    /// 测光模式 (格式: Int) - 相机使用的测光模式
    public var mdItemMeteringMode: Int? { value(forMetadataItem: MDKey.meteringMode) }

    /// 方向 (格式: Int) - 图像方向(1=正常,3=180度,6=90度顺时针,8=270度顺时针)
    public var mdItemOrientation: Int? { value(forMetadataItem: MDKey.orientation) }

    /// 像素总数 (格式: Int) - 图像中的总像素数
    public var mdItemPixelCount: Int? { value(forMetadataItem: MDKey.pixelCount) }

    /// 像素高度 (格式: Int) - 图像高度(像素)
    public var mdItemPixelHeight: Int? { value(forMetadataItem: MDKey.pixelHeight) }

    /// 像素宽度 (格式: Int) - 图像宽度(像素)
    public var mdItemPixelWidth: Int? { value(forMetadataItem: MDKey.pixelWidth) }

    /// 色彩配置文件名 (格式: String) - 图像使用的色彩配置文件名
    public var mdItemProfileName: String? { value(forMetadataItem: MDKey.profileName) }

    /// 红眼校正状态 (格式: Int) - 是否应用红眼校正(0=否,1=是)
    public var mdItemRedEyeOnOff: Int? { value(forMetadataItem: MDKey.redEyeOnOff) }

    /// 垂直分辨率 (DPI) (格式: Int) - 图像的垂直分辨率(每英寸点数)
    public var mdItemResolutionHeightDpi: Int? { value(forMetadataItem: MDKey.resolutionHeightDpi) }

    /// 水平分辨率 (DPI) (格式: Int) - 图像的水平分辨率(每英寸点数)
    public var mdItemResolutionWidthDpi: Int? { value(forMetadataItem: MDKey.resolutionWidthDpi) }

    /// 速度 (格式: Double) - 拍摄时相机的移动速度(km/h)
    public var mdItemSpeed: Double? { value(forMetadataItem: MDKey.speed) }

    /// 时间戳 (格式: Date) - 图像创建的时间戳
    public var mdItemTimestamp: Date? { value(forMetadataItem: MDKey.timestamp) }

    /// 白平衡 (格式: Int) - 相机白平衡设置(0=自动,1=手动)
    public var mdItemWhiteBalance: Int? { value(forMetadataItem: MDKey.whiteBalance) }

    /// XMP信用信息 (格式: String) - XMP元数据中的信用信息
    public var mdItemXMPCredit: String? { value(forMetadataItem: MDKey.xmpCredit) }

    /// XMP数字来源类型 (格式: String) - XMP元数据中的数字来源类型
    public var mdItemXMPDigitalSourceType: String? { value(forMetadataItem: MDKey.xmpDigitalSourceType) }

    // MARK: - 音频/视频属性

    /// 音频比特率 (格式: Int) - 音频流的比特率(比特/秒)
    public var mdItemAudioBitRate: Int? { value(forMetadataItem: MDKey.audioBitRate) }

    /// 音频通道数 (格式: Int) - 音频通道数量(1=单声道,2=立体声等)
    public var mdItemAudioChannelCount: Int? { value(forMetadataItem: MDKey.audioChannelCount) }

    /// 音频采样率 (格式: Int) - 音频采样率(Hz)
    public var mdItemAudioSampleRate: Int? { value(forMetadataItem: MDKey.audioSampleRate) }

    /// 音轨编号 (格式: Int) - 音轨在专辑中的编号
    public var mdItemAudioTrackNumber: Int? { value(forMetadataItem: MDKey.audioTrackNumber) }

    /// 编解码器 (格式: [String]) - 媒体使用的编解码器列表
    public var mdItemCodecs: [String]? { value(forMetadataItem: MDKey.codecs) }

    /// 作曲家 (格式: String) - 音频内容的作曲家
    public var mdItemComposer: String? { value(forMetadataItem: MDKey.composer) }

    /// 交付类型 (格式: String) - 媒体交付类型，如 "streaming"
    public var mdItemDeliveryType: String? { value(forMetadataItem: MDKey.deliveryType) }

    /// 导演 (格式: String) - 视频内容的导演
    public var mdItemDirector: String? { value(forMetadataItem: MDKey.director) }

    /// 流派 (格式: String) - 媒体内容的流派
    public var mdItemGenre: String? { value(forMetadataItem: MDKey.genre) }

    /// 是否为通用MIDI序列 (格式: Bool) - 是否是通用MIDI序列文件
    public var mdItemIsGeneralMIDISequence: Bool? { value(forMetadataItem: MDKey.isGeneralMIDISequence) }

    /// 调号 (格式: String) - 音频的调号，如 "C major"
    public var mdItemKeySignature: String? { value(forMetadataItem: MDKey.keySignature) }

    /// 作词者 (格式: String) - 音频歌词的作者
    public var mdItemLyricist: String? { value(forMetadataItem: MDKey.lyricist) }

    /// 媒体类型 (格式: [String]) - 媒体包含的内容类型列表，如 ["audio", "video"]
    public var mdItemMediaTypes: [String]? { value(forMetadataItem: MDKey.mediaTypes) }

    /// 音乐流派 (格式: String) - 音频内容的音乐流派
    public var mdItemMusicalGenre: String? { value(forMetadataItem: MDKey.musicalGenre) }

    /// 原始格式 (格式: String) - 媒体原始格式
    public var mdItemOriginalFormat: String? { value(forMetadataItem: MDKey.originalFormat) }

    /// 原始来源 (格式: String) - 媒体的原始来源
    public var mdItemOriginalSource: String? { value(forMetadataItem: MDKey.originalSource) }

    /// 表演者 (格式: [String]) - 媒体内容的表演者列表
    public var mdItemPerformers: [String]? { value(forMetadataItem: MDKey.performers) }

    /// 制作人 (格式: String) - 媒体内容的制作人
    public var mdItemProducer: String? { value(forMetadataItem: MDKey.producer) }

    /// 录制日期 (格式: Date) - 媒体内容的录制日期
    public var mdItemRecordingDate: Date? { value(forMetadataItem: MDKey.recordingDate) }

    /// 录制年份 (格式: Int) - 媒体内容的录制年份
    public var mdItemRecordingYear: Int? { value(forMetadataItem: MDKey.recordingYear) }

    /// 是否可流式传输 (格式: Bool) - 媒体是否适合流式传输
    public var mdItemStreamable: Bool? { value(forMetadataItem: MDKey.streamable) }

    /// 速度 (格式: Double) - 音频的速度(每分钟节拍数)
    public var mdItemTempo: Double? { value(forMetadataItem: MDKey.tempo) }

    /// 拍号 (格式: String) - 音频的拍号，如 "4/4"
    public var mdItemTimeSignature: String? { value(forMetadataItem: MDKey.timeSignature) }

    /// 总比特率 (格式: Int) - 媒体的总比特率(音频+视频，比特/秒)
    public var mdItemTotalBitRate: Int? { value(forMetadataItem: MDKey.totalBitRate) }

    /// 视频比特率 (格式: Int) - 视频流的比特率(比特/秒)
    public var mdItemVideoBitRate: Int? { value(forMetadataItem: MDKey.videoBitRate) }

    // MARK: - 应用相关属性

    /// 应用类别 (格式: [String]) - 应用的类别列表，如 ["Games", "Entertainment"]
    public var mdItemApplicationCategories: [String]? { value(forMetadataItem: MDKey.applicationCategories) }

    /// 应用包标识符 (格式: String) - 应用的Bundle Identifier，如 "com.apple.Safari"
    public var mdItemCFBundleIdentifier: String? { value(forMetadataItem: MDKey.cfBundleIdentifier) }

    /// 可执行架构 (格式: [String]) - 应用支持的CPU架构列表，如 ["x86_64", "arm64"]
    public var mdItemExecutableArchitectures: [String]? { value(forMetadataItem: MDKey.executableArchitectures) }

    /// 可执行平台 (格式: String) - 应用的目标平台，如 "macosx"
    public var mdItemExecutablePlatform: String? { value(forMetadataItem: MDKey.executablePlatform) }

    /// 是否由应用管理 (格式: Bool) - 文件是否由特定应用管理
    public var mdItemIsApplicationManaged: Bool? { value(forMetadataItem: MDKey.isApplicationManaged) }

    /// 可能是垃圾文件 (格式: Bool) - 文件是否可能是不需要的文件
    public var mdItemIsLikelyJunk: Bool? { value(forMetadataItem: MDKey.isLikelyJunk) }

    // MARK: - 媒体制作属性

    /// Apple Loop描述符 (格式: [String]) - Apple Loop音频文件的描述符
    public var mdItemAppleLoopDescriptors: [String]? { value(forMetadataItem: MDKey.appleLoopDescriptors) }

    /// Apple Loop键过滤器类型 (格式: String) - Apple Loop的键过滤器类型
    public var mdItemAppleLoopsKeyFilterType: String? { value(forMetadataItem: MDKey.appleLoopsKeyFilterType) }

    /// Apple Loop循环模式 (格式: String) - Apple Loop的循环模式
    public var mdItemAppleLoopsLoopMode: String? { value(forMetadataItem: MDKey.appleLoopsLoopMode) }

    /// Apple Loop根键 (格式: String) - Apple Loop的根音键
    public var mdItemAppleLoopsRootKey: String? { value(forMetadataItem: MDKey.appleLoopsRootKey) }

    /// 音频编码应用 (格式: String) - 用于编码音频的应用程序
    public var mdItemAudioEncodingApplication: String? { value(forMetadataItem: MDKey.audioEncodingApplication) }

    /// EXIF GPS版本 (格式: String) - EXIF中GPS信息的版本
    public var mdItemEXIFGPSVersion: String? { value(forMetadataItem: MDKey.exifGpsVersion) }

    /// GPS版本 (格式: String) - GPS信息的版本
    public var mdItemGPSVersion: String? { value(forMetadataItem: MDKey.gpsVersion) }

    /// 媒体扩展 (格式: [String]) - 媒体文件支持的扩展名列表
    public var mdItemMediaExtensions: [String]? {
        if #available(macOS 15.0, *) {
            return value(forMetadataItem: MDKey.mediaExtensions)
        } else {
            return nil
        }
    }

    /// 乐器类别 (格式: String) - 音乐乐器的类别
    public var mdItemMusicalInstrumentCategory: String? { value(forMetadataItem: MDKey.musicalInstrumentCategory) }

    /// 乐器名称 (格式: String) - 音乐乐器的名称
    public var mdItemMusicalInstrumentName: String? { value(forMetadataItem: MDKey.musicalInstrumentName) }

    // MARK: - 页面/文档属性

    /// HTML内容 (格式: String) - 文档的HTML内容
    public var mdItemHTMLContent: String? { value(forMetadataItem: MDKey.htmlContent) }

    /// 页数 (格式: Int) - 文档的总页数
    public var mdItemNumberOfPages: Int? { value(forMetadataItem: MDKey.numberOfPages) }

    /// 页面高度 (格式: Double) - 文档页面的高度(点)
    public var mdItemPageHeight: Double? { value(forMetadataItem: MDKey.pageHeight) }

    /// 页面宽度 (格式: Double) - 文档页面的宽度(点)
    public var mdItemPageWidth: Double? { value(forMetadataItem: MDKey.pageWidth) }
}
