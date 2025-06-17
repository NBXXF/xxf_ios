import Foundation

//
//  URL+MetadataQuery.swift
//  xxf_ios
//
//  Created by xxf on 6/12.
//

import CoreServices
import Foundation

extension URL: NSMetadataProtocol, NSMetadataOperationProtocol {
    private nonisolated(unsafe) static var mdItemKey: UInt8 = 0

    // MARK: - 元数据查询方法

    /// 创建MDItem对象用于查询文件元数据 (格式: MDItem?) - 为当前URL路径创建MDItem对象
    /// 创建并缓存 MDItem 对象（只生成一次）
    public var mdItem: MDItem? {
        let bridge = self as NSURL

        // 直接用原始 objc_getAssociatedObject 获取缓存
        if let cached = objc_getAssociatedObject(bridge, &Self.mdItemKey) {
            return (cached as! MDItem) // 明确用强制转型，消除警告
        }

        // 只有是文件URL时创建
        guard isFileURL, let itemRef = MDItemCreate(nil, path as CFString) else {
            return nil
        }

        // 用原始 objc_setAssociatedObject 缓存起来
        objc_setAssociatedObject(bridge, &Self.mdItemKey, itemRef, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return itemRef
    }

    public func value<T>(forMetadataItem key: String) -> T? {
        return mdItem?.value(forMetadataItem: key)
    }

    // MARK: - 通用基础属性

    /// 属性变更日期 (格式: Date?) - 文件元数据最后修改的日期
    public var mdItemAttributeChangeDate: Date? { mdItem?.mdItemAttributeChangeDate }

    /// 受众群体 (格式: [String]?) - 文件的目标受众列表
    public var mdItemAudiences: [String]? { mdItem?.mdItemAudiences }

    /// 作者列表 (格式: [String]?) - 文件的作者姓名列表
    public var mdItemAuthors: [String]? { mdItem?.mdItemAuthors }

    /// 作者地址 (格式: [String]?) - 作者的邮政地址列表
    public var mdItemAuthorAddresses: [String]? { mdItem?.mdItemAuthorAddresses }

    /// 作者邮箱 (格式: [String]?) - 作者的电子邮件地址列表
    public var mdItemAuthorEmailAddresses: [String]? { mdItem?.mdItemAuthorEmailAddresses }

    /// 城市 (格式: String?) - 与文件关联的城市名称
    public var mdItemCity: String? { mdItem?.mdItemCity }

    /// 注释 (格式: String?) - 用户提供的文件注释
    public var mdItemComment: String? { mdItem?.mdItemComment }

    /// 联系关键词 (格式: [String]?) - 与联系人相关的关键词
    public var mdItemContactKeywords: [String]? { mdItem?.mdItemContactKeywords }

    /// 内容创建日期 (格式: Date?) - 文件内容最初创建的日期
    public var mdItemContentCreationDate: Date? { mdItem?.mdItemContentCreationDate }

    /// 内容修改日期 (格式: Date?) - 文件内容最后修改的日期
    public var mdItemContentModificationDate: Date? { mdItem?.mdItemContentModificationDate }

    /// 内容类型 (格式: String?) - 文件的统一类型标识符 (UTI)，如 "public.jpeg"
    public var mdItemContentType: String? { mdItem?.mdItemContentType }

    /// 内容类型树 (格式: [String]?) - 文件的所有UTI层次结构
    public var mdItemContentTypeTree: [String]? { mdItem?.mdItemContentTypeTree }

    /// 贡献者 (格式: [String]?) - 为文件内容做出贡献的人员列表
    public var mdItemContributors: [String]? { mdItem?.mdItemContributors }

    /// 版权信息 (格式: String?) - 文件的版权声明
    public var mdItemCopyright: String? { mdItem?.mdItemCopyright }

    /// 国家 (格式: String?) - 与文件关联的国家名称
    public var mdItemCountry: String? { mdItem?.mdItemCountry }

    /// 覆盖范围 (格式: String?) - 文件内容的时空覆盖范围
    public var mdItemCoverage: String? { mdItem?.mdItemCoverage }

    /// 创建者 (格式: String?) - 创建文件的应用程序名称
    public var mdItemCreator: String? { mdItem?.mdItemCreator }

    /// 添加日期 (格式: Date?) - 文件添加到当前位置的日期
    public var mdItemDateAdded: Date? { mdItem?.mdItemDateAdded }

    /// 描述 (格式: String?) - 文件内容的文本描述
    public var mdItemDescription: String? { mdItem?.mdItemDescription }

    /// 显示名称 (格式: String?) - 文件的用户可见名称
    public var mdItemDisplayName: String? { mdItem?.mdItemDisplayName }

    /// 下载日期 (格式: Date?) - 文件从互联网下载的日期
    public var mdItemDownloadedDate: Date? { mdItem?.mdItemDownloadedDate }

    /// 到期日期 (格式: Date?) - 文件到期的日期
    public var mdItemDueDate: Date? { mdItem?.mdItemDueDate }

    /// 持续时间(秒) (格式: Double?) - 媒体文件的持续时间(以秒为单位)
    public var mdItemDurationSeconds: Double? { mdItem?.mdItemDurationSeconds }

    /// 编辑者 (格式: [String]?) - 编辑过文件的人员列表
    public var mdItemEditors: [String]? { mdItem?.mdItemEditors }

    /// 电子邮件地址 (格式: [String]?) - 与文件关联的电子邮件地址
    public var mdItemEmailAddresses: [String]? { mdItem?.mdItemEmailAddresses }

    /// 编码应用程序 (格式: [String]?) - 用于编码文件的应用程序列表
    public var mdItemEncodingApplications: [String]? { mdItem?.mdItemEncodingApplications }

    /// Finder注释 (格式: String?) - Finder中显示的注释
    public var mdItemFinderComment: String? { mdItem?.mdItemFinderComment }

    /// 字体列表 (格式: [String]?) - 文档中使用的字体名称列表
    public var mdItemFonts: [String]? { mdItem?.mdItemFonts }

    /// 标题 (格式: String?) - 文件的标题或标题行
    public var mdItemHeadline: String? { mdItem?.mdItemHeadline }

    /// 标识符 (格式: String?) - 文件的唯一标识符
    public var mdItemIdentifier: String? { mdItem?.mdItemIdentifier }

    /// 信息 (格式: String?) - 关于文件的其他信息
    public var mdItemInformation: String? { mdItem?.mdItemInformation }

    /// 即时消息地址 (格式: [String]?) - 与文件关联的即时消息地址
    public var mdItemInstantMessageAddresses: [String]? { mdItem?.mdItemInstantMessageAddresses }

    /// 说明 (格式: String?) - 如何使用文件的说明
    public var mdItemInstructions: String? { mdItem?.mdItemInstructions }

    /// 关键词 (格式: [String]?) - 描述文件内容的关键词
    public var mdItemKeywords: [String]? { mdItem?.mdItemKeywords }

    /// 种类 (格式: String?) - 用户可见的文件类型描述，如 "JPEG图像"
    public var mdItemKind: String? { mdItem?.mdItemKind }

    /// 语言 (格式: [String]?) - 文件内容的语言代码列表，如 ["en", "zh"]
    public var mdItemLanguages: [String]? { mdItem?.mdItemLanguages }

    /// 最后使用日期 (格式: Date?) - 文件最后一次被访问的日期
    public var mdItemLastUsedDate: Date? { mdItem?.mdItemLastUsedDate }

    /// 命名位置 (格式: String?) - 与文件关联的命名位置
    public var mdItemNamedLocation: String? { mdItem?.mdItemNamedLocation }

    /// 组织 (格式: [String]?) - 与文件关联的组织名称列表
    public var mdItemOrganizations: [String]? { mdItem?.mdItemOrganizations }

    /// 参与者 (格式: [String]?) - 文件内容中的参与者列表
    public var mdItemParticipants: [String]? { mdItem?.mdItemParticipants }

    /// 电话号码 (格式: [String]?) - 与文件关联的电话号码
    public var mdItemPhoneNumbers: [String]? { mdItem?.mdItemPhoneNumbers }

    /// 项目 (格式: [String]?) - 与文件关联的项目名称列表
    public var mdItemProjects: [String]? { mdItem?.mdItemProjects }

    /// 出版商 (格式: [String]?) - 文件内容的出版商列表
    public var mdItemPublishers: [String]? { mdItem?.mdItemPublishers }

    /// 收件人 (格式: [String]?) - 文件的目标收件人列表
    public var mdItemRecipients: [String]? { mdItem?.mdItemRecipients }

    /// 收件人地址 (格式: [String]?) - 收件人的邮政地址列表
    public var mdItemRecipientAddresses: [String]? { mdItem?.mdItemRecipientAddresses }

    /// 收件人邮箱 (格式: [String]?) - 收件人的电子邮件地址列表
    public var mdItemRecipientEmailAddresses: [String]? { mdItem?.mdItemRecipientEmailAddresses }

    /// 权限 (格式: String?) - 文件的使用权限信息
    public var mdItemRights: String? { mdItem?.mdItemRights }

    /// 安全方法 (格式: String?) - 文件使用的安全方法
    public var mdItemSecurityMethod: String? { mdItem?.mdItemSecurityMethod }

    /// 星级评分 (格式: Double?) - 用户对文件的评分(通常0-5)
    public var mdItemStarRating: Double? { mdItem?.mdItemStarRating }

    /// 州/省 (格式: String?) - 与文件关联的州或省名称
    public var mdItemStateOrProvince: String? { mdItem?.mdItemStateOrProvince }

    /// 主题 (格式: String?) - 文件内容的主题
    public var mdItemSubject: String? { mdItem?.mdItemSubject }

    /// 文本内容 (格式: String?) - 文件的原始文本内容
    public var mdItemTextContent: String? { mdItem?.mdItemTextContent }

    /// 主题 (格式: String?) - 文件内容的主题或类别
    public var mdItemTheme: String? { mdItem?.mdItemTheme }

    /// 标题 (格式: String?) - 文件的标题
    public var mdItemTitle: String? { mdItem?.mdItemTitle }

    /// URL (格式: String?) - 与文件关联的URL
    public var mdItemUrl: String? { mdItem?.mdItemUrl }

    /// 版本 (格式: String?) - 文件的版本号
    public var mdItemVersion: String? { mdItem?.mdItemVersion }

    /// 来源 (格式: [String]?) - 文件下载来源的URL列表
    public var mdItemWhereFroms: [String]? { mdItem?.mdItemWhereFroms }

    // MARK: - 文件系统属性

    /// 文件内容变更日期 (格式: Date?) - 文件内容最后修改的日期
    public var mdItemFSContentChangeDate: Date? { mdItem?.mdItemFSContentChangeDate }

    /// 文件创建日期 (格式: Date?) - 文件在文件系统中创建的日期
    public var mdItemFSCreationDate: Date? { mdItem?.mdItemFSCreationDate }

    /// 是否有自定义图标 (格式: Bool?) - 文件是否有自定义图标
    public var mdItemFSHasCustomIcon: Bool? { mdItem?.mdItemFSHasCustomIcon }

    /// 是否隐藏 (格式: Bool?) - 文件是否在Finder中隐藏
    public var mdItemFSInvisible: Bool? { mdItem?.mdItemFSInvisible }

    /// 是否隐藏扩展名 (格式: Bool?) - 文件扩展名是否隐藏
    public var mdItemFSIsExtensionHidden: Bool? { mdItem?.mdItemFSIsExtensionHidden }

    /// 是否为模板文件 (格式: Bool?) - 文件是否为模板文件
    public var mdItemFSIsStationery: Bool? { mdItem?.mdItemFSIsStationery }

    /// Finder标签 (格式: Int?) - Finder标签颜色索引(0-7)
    public var mdItemFSLabel: Int? { mdItem?.mdItemFSLabel }

    /// 文件名 (格式: String?) - 文件的名称(包括扩展名)
    public var mdItemFSName: String? { mdItem?.mdItemFSName }

    /// 节点数量 (格式: Int?) - 目录包含的项目数(仅目录有效)
    public var mdItemFSNodeCount: Int? { mdItem?.mdItemFSNodeCount }

    /// 所有者组ID (格式: Int?) - 文件所有者组的ID
    public var mdItemFSOwnerGroupID: Int? { mdItem?.mdItemFSOwnerGroupID }

    /// 所有者用户ID (格式: Int?) - 文件所有者的用户ID
    public var mdItemFSOwnerUserID: Int? { mdItem?.mdItemFSOwnerUserID }

    /// 文件路径 (格式: String?) - 文件的完整路径
    public var mdItemFSPath: String? { mdItem?.mdItemFSPath }

    /// 文件大小 (格式: Int?) - 文件大小(以字节为单位)
    public var mdItemFSSize: Int? { mdItem?.mdItemFSSize }

    // MARK: - 图像属性

    /// 相机品牌 (格式: String?) - 拍摄照片的相机品牌
    public var mdItemAcquisitionMake: String? { mdItem?.mdItemAcquisitionMake }

    /// 相机型号 (格式: String?) - 拍摄照片的相机型号
    public var mdItemAcquisitionModel: String? { mdItem?.mdItemAcquisitionModel }

    /// 相册名称 (格式: String?) - 照片所属的相册名称
    public var mdItemAlbum: String? { mdItem?.mdItemAlbum }

    /// 海拔高度 (格式: Double?) - 拍摄地点的海拔高度(米)
    public var mdItemAltitude: Double? { mdItem?.mdItemAltitude }

    /// 光圈值 (格式: Double?) - 拍摄时的光圈值(f-number)
    public var mdItemAperture: Double? { mdItem?.mdItemAperture }

    /// 每样本位数 (格式: Int?) - 图像每个颜色分量的位数
    public var mdItemBitsPerSample: Int? { mdItem?.mdItemBitsPerSample }

    /// 相机所有者 (格式: String?) - 相机所有者的姓名
    public var mdItemCameraOwner: String? { mdItem?.mdItemCameraOwner }

    /// 色彩空间 (格式: String?) - 图像使用的色彩空间，如 "RGB", "CMYK"
    public var mdItemColorSpace: String? { mdItem?.mdItemColorSpace }

    /// EXIF版本 (格式: String?) - EXIF元数据的版本
    public var mdItemExifVersion: String? { mdItem?.mdItemExifVersion }

    /// 曝光模式 (格式: Int?) - 相机曝光模式(1=手动,2=自动,3=自动包围)
    public var mdItemExposureMode: Int? { mdItem?.mdItemExposureMode }

    /// 曝光程序 (格式: Int?) - 相机使用的曝光程序(1=手动,2=正常,3=光圈优先等)
    public var mdItemExposureProgram: Int? { mdItem?.mdItemExposureProgram }

    /// 曝光时间(秒) (格式: Double?) - 快门速度(以秒为单位)
    public var mdItemExposureTimeSeconds: Double? { mdItem?.mdItemExposureTimeSeconds }

    /// 曝光时间字符串 (格式: String?) - 人类可读的曝光时间，如 "1/125"
    public var mdItemExposureTimeString: String? { mdItem?.mdItemExposureTimeString }

    /// 光圈值 (格式: Double?) - 拍摄时的光圈值(f-number)
    public var mdItemFNumber: Double? { mdItem?.mdItemFNumber }

    /// 闪光灯状态 (格式: Int?) - 闪光灯是否触发(0=关闭,1=开启)
    public var mdItemFlashOnOff: Int? { mdItem?.mdItemFlashOnOff }

    /// 焦距 (格式: Double?) - 拍摄时的实际焦距(毫米)
    public var mdItemFocalLength: Double? { mdItem?.mdItemFocalLength }

    /// 35mm等效焦距 (格式: Double?) - 35mm胶片等效焦距(毫米)
    public var mdItemFocalLength35mm: Double? { mdItem?.mdItemFocalLength35mm }

    /// GPS区域信息 (格式: String?) - GPS区域描述
    public var mdItemGPSAreaInformation: String? { mdItem?.mdItemGPSAreaInformation }

    /// GPS日期戳 (格式: String?) - GPS日期记录(格式: "YYYY:MM:DD")
    public var mdItemGPSDateStamp: String? { mdItem?.mdItemGPSDateStamp }

    /// GPS目标方位 (格式: Double?) - 相对于真北的目标方位角(度数)
    public var mdItemGPSDestBearing: Double? { mdItem?.mdItemGPSDestBearing }

    /// GPS目标距离 (格式: Double?) - 到目标的距离(米)
    public var mdItemGPSDestDistance: Double? { mdItem?.mdItemGPSDestDistance }

    /// GPS目标纬度 (格式: Double?) - 目标地点的纬度
    public var mdItemGPSDestLatitude: Double? { mdItem?.mdItemGPSDestLatitude }

    /// GPS目标经度 (格式: Double?) - 目标地点的经度
    public var mdItemGPSDestLongitude: Double? { mdItem?.mdItemGPSDestLongitude }

    /// GPS差分校正 (格式: Int?) - 是否应用差分GPS校正(0=无,1=已应用)
    public var mdItemGPSDifferental: Int? { mdItem?.mdItemGPSDifferental }

    /// GPS精度 (格式: Double?) - GPS精度(0-100)
    public var mdItemGPSDop: Double? { mdItem?.mdItemGPSDop }

    /// GPS地图基准 (格式: String?) - GPS使用的地图基准
    public var mdItemGPSMapDatum: String? { mdItem?.mdItemGPSMapDatum }

    /// GPS测量模式 (格式: String?) - GPS测量模式，如 "2-dimensional"
    public var mdItemGPSMeasureMode: String? { mdItem?.mdItemGPSMeasureMode }

    /// GPS处理方法 (格式: String?) - GPS位置计算方法
    public var mdItemGPSProcessingMethod: String? { mdItem?.mdItemGPSProcessingMethod }

    /// GPS状态 (格式: String?) - GPS接收器状态，如 "A"(活动)或 "V"(无效)
    public var mdItemGPSStatus: String? { mdItem?.mdItemGPSStatus }

    /// GPS轨迹 (格式: Double?) - 相对于真北的运动方向(度数)
    public var mdItemGPSTrack: Double? { mdItem?.mdItemGPSTrack }

    /// 是否有Alpha通道 (格式: Bool?) - 图像是否包含Alpha通道
    public var mdItemHasAlphaChannel: Bool? { mdItem?.mdItemHasAlphaChannel }

    /// 图像方向 (格式: Double?) - 拍摄时相机相对于真北的方向(度数)
    public var mdItemImageDirection: Double? { mdItem?.mdItemImageDirection }

    /// ISO感光度 (格式: Int?) - 相机ISO感光度设置
    public var mdItemISOSpeed: Int? { mdItem?.mdItemISOSpeed }

    /// 纬度 (格式: Double?) - 拍摄地点的纬度
    public var mdItemLatitude: Double? { mdItem?.mdItemLatitude }

    /// 图层名称 (格式: [String]?) - 图像中图层的名称列表
    public var mdItemLayerNames: [String]? { mdItem?.mdItemLayerNames }

    /// 镜头型号 (格式: String?) - 相机镜头的型号
    public var mdItemLensModel: String? { mdItem?.mdItemLensModel }

    /// 经度 (格式: Double?) - 拍摄地点的经度
    public var mdItemLongitude: Double? { mdItem?.mdItemLongitude }

    /// 最大光圈 (格式: Double?) - 镜头的最大光圈值
    public var mdItemMaxAperture: Double? { mdItem?.mdItemMaxAperture }

    /// 测光模式 (格式: Int?) - 相机使用的测光模式
    public var mdItemMeteringMode: Int? { mdItem?.mdItemMeteringMode }

    /// 方向 (格式: Int?) - 图像方向(1=正常,3=180度,6=90度顺时针,8=270度顺时针)
    public var mdItemOrientation: Int? { mdItem?.mdItemOrientation }

    /// 像素总数 (格式: Int?) - 图像中的总像素数
    public var mdItemPixelCount: Int? { mdItem?.mdItemPixelCount }

    /// 像素高度 (格式: Int?) - 图像高度(像素)
    public var mdItemPixelHeight: Int? { mdItem?.mdItemPixelHeight }

    /// 像素宽度 (格式: Int?) - 图像宽度(像素)
    public var mdItemPixelWidth: Int? { mdItem?.mdItemPixelWidth }

    /// 色彩配置文件名 (格式: String?) - 图像使用的色彩配置文件名
    public var mdItemProfileName: String? { mdItem?.mdItemProfileName }

    /// 红眼校正状态 (格式: Int?) - 是否应用红眼校正(0=否,1=是)
    public var mdItemRedEyeOnOff: Int? { mdItem?.mdItemRedEyeOnOff }

    /// 垂直分辨率 (DPI) (格式: Int?) - 图像的垂直分辨率(每英寸点数)
    public var mdItemResolutionHeightDpi: Int? { mdItem?.mdItemResolutionHeightDpi }

    /// 水平分辨率 (DPI) (格式: Int?) - 图像的水平分辨率(每英寸点数)
    public var mdItemResolutionWidthDpi: Int? { mdItem?.mdItemResolutionWidthDpi }

    /// 速度 (格式: Double?) - 拍摄时相机的移动速度(km/h)
    public var mdItemSpeed: Double? { mdItem?.mdItemSpeed }

    /// 时间戳 (格式: Date?) - 图像创建的时间戳
    public var mdItemTimestamp: Date? { mdItem?.mdItemTimestamp }

    /// 白平衡 (格式: Int?) - 相机白平衡设置(0=自动,1=手动)
    public var mdItemWhiteBalance: Int? { mdItem?.mdItemWhiteBalance }

    /// XMP信用信息 (格式: String?) - XMP元数据中的信用信息
    public var mdItemXMPCredit: String? { mdItem?.mdItemXMPCredit }

    /// XMP数字来源类型 (格式: String?) - XMP元数据中的数字来源类型
    public var mdItemXMPDigitalSourceType: String? { mdItem?.mdItemXMPDigitalSourceType }

    // MARK: - 音频/视频属性

    /// 音频比特率 (格式: Int?) - 音频流的比特率(比特/秒)
    public var mdItemAudioBitRate: Int? { mdItem?.mdItemAudioBitRate }

    /// 音频通道数 (格式: Int?) - 音频通道数量(1=单声道,2=立体声等)
    public var mdItemAudioChannelCount: Int? { mdItem?.mdItemAudioChannelCount }

    /// 音频采样率 (格式: Int?) - 音频采样率(Hz)
    public var mdItemAudioSampleRate: Int? { mdItem?.mdItemAudioSampleRate }

    /// 音轨编号 (格式: Int?) - 音轨在专辑中的编号
    public var mdItemAudioTrackNumber: Int? { mdItem?.mdItemAudioTrackNumber }

    /// 编解码器 (格式: [String]?) - 媒体使用的编解码器列表
    public var mdItemCodecs: [String]? { mdItem?.mdItemCodecs }

    /// 作曲家 (格式: String?) - 音频内容的作曲家
    public var mdItemComposer: String? { mdItem?.mdItemComposer }

    /// 交付类型 (格式: String?) - 媒体交付类型，如 "streaming"
    public var mdItemDeliveryType: String? { mdItem?.mdItemDeliveryType }

    /// 导演 (格式: String?) - 视频内容的导演
    public var mdItemDirector: String? { mdItem?.mdItemDirector }

    /// 流派 (格式: String?) - 媒体内容的流派
    public var mdItemGenre: String? { mdItem?.mdItemGenre }

    /// 是否为通用MIDI序列 (格式: Bool?) - 是否是通用MIDI序列文件
    public var mdItemIsGeneralMIDISequence: Bool? { mdItem?.mdItemIsGeneralMIDISequence }

    /// 调号 (格式: String?) - 音频的调号，如 "C major"
    public var mdItemKeySignature: String? { mdItem?.mdItemKeySignature }

    /// 作词者 (格式: String?) - 音频歌词的作者
    public var mdItemLyricist: String? { mdItem?.mdItemLyricist }

    /// 媒体类型 (格式: [String]?) - 媒体包含的内容类型列表，如 ["audio", "video"]
    public var mdItemMediaTypes: [String]? { mdItem?.mdItemMediaTypes }

    /// 音乐流派 (格式: String?) - 音频内容的音乐流派
    public var mdItemMusicalGenre: String? { mdItem?.mdItemMusicalGenre }

    /// 原始格式 (格式: String?) - 媒体原始格式
    public var mdItemOriginalFormat: String? { mdItem?.mdItemOriginalFormat }

    /// 原始来源 (格式: String?) - 媒体的原始来源
    public var mdItemOriginalSource: String? { mdItem?.mdItemOriginalSource }

    /// 表演者 (格式: [String]?) - 媒体内容的表演者列表
    public var mdItemPerformers: [String]? { mdItem?.mdItemPerformers }

    /// 制作人 (格式: String?) - 媒体内容的制作人
    public var mdItemProducer: String? { mdItem?.mdItemProducer }

    /// 录制日期 (格式: Date?) - 媒体内容的录制日期
    public var mdItemRecordingDate: Date? { mdItem?.mdItemRecordingDate }

    /// 录制年份 (格式: Int?) - 媒体内容的录制年份
    public var mdItemRecordingYear: Int? { mdItem?.mdItemRecordingYear }

    /// 是否可流式传输 (格式: Bool?) - 媒体是否适合流式传输
    public var mdItemStreamable: Bool? { mdItem?.mdItemStreamable }

    /// 速度 (格式: Double?) - 音频的速度(每分钟节拍数)
    public var mdItemTempo: Double? { mdItem?.mdItemTempo }

    /// 拍号 (格式: String?) - 音频的拍号，如 "4/4"
    public var mdItemTimeSignature: String? { mdItem?.mdItemTimeSignature }

    /// 总比特率 (格式: Int?) - 媒体的总比特率(音频+视频，比特/秒)
    public var mdItemTotalBitRate: Int? { mdItem?.mdItemTotalBitRate }

    /// 视频比特率 (格式: Int?) - 视频流的比特率(比特/秒)
    public var mdItemVideoBitRate: Int? { mdItem?.mdItemVideoBitRate }

    // MARK: - 应用相关属性

    /// 应用类别 (格式: [String]?) - 应用的类别列表，如 ["Games", "Entertainment"]
    public var mdItemApplicationCategories: [String]? { mdItem?.mdItemApplicationCategories }

    /// 应用包标识符 (格式: String?) - 应用的Bundle Identifier，如 "com.apple.Safari"
    public var mdItemCFBundleIdentifier: String? { mdItem?.mdItemCFBundleIdentifier }

    /// 可执行架构 (格式: [String]?) - 应用支持的CPU架构列表，如 ["x86_64", "arm64"]
    public var mdItemExecutableArchitectures: [String]? { mdItem?.mdItemExecutableArchitectures }

    /// 可执行平台 (格式: String?) - 应用的目标平台，如 "macosx"
    public var mdItemExecutablePlatform: String? { mdItem?.mdItemExecutablePlatform }

    /// 是否由应用管理 (格式: Bool?) - 文件是否由特定应用管理
    public var mdItemIsApplicationManaged: Bool? { mdItem?.mdItemIsApplicationManaged }

    /// 可能是垃圾文件 (格式: Bool?) - 文件是否可能是不需要的文件
    public var mdItemIsLikelyJunk: Bool? { mdItem?.mdItemIsLikelyJunk }

    // MARK: - 媒体制作属性

    /// Apple Loop描述符 (格式: [String]?) - Apple Loop音频文件的描述符
    public var mdItemAppleLoopDescriptors: [String]? { mdItem?.mdItemAppleLoopDescriptors }

    /// Apple Loop键过滤器类型 (格式: String?) - Apple Loop的键过滤器类型
    public var mdItemAppleLoopsKeyFilterType: String? { mdItem?.mdItemAppleLoopsKeyFilterType }

    /// Apple Loop循环模式 (格式: String?) - Apple Loop的循环模式
    public var mdItemAppleLoopsLoopMode: String? { mdItem?.mdItemAppleLoopsLoopMode }

    /// Apple Loop根键 (格式: String?) - Apple Loop的根音键
    public var mdItemAppleLoopsRootKey: String? { mdItem?.mdItemAppleLoopsRootKey }

    /// 音频编码应用 (格式: String?) - 用于编码音频的应用程序
    public var mdItemAudioEncodingApplication: String? { mdItem?.mdItemAudioEncodingApplication }

    /// EXIF GPS版本 (格式: String?) - EXIF中GPS信息的版本
    public var mdItemEXIFGPSVersion: String? { mdItem?.mdItemEXIFGPSVersion }

    /// GPS版本 (格式: String?) - GPS信息的版本
    public var mdItemGPSVersion: String? { mdItem?.mdItemGPSVersion }

    /// 媒体扩展 (格式: [String]?) - 媒体文件支持的扩展名列表
    public var mdItemMediaExtensions: [String]? { mdItem?.mdItemMediaExtensions }

    /// 乐器类别 (格式: String?) - 音乐乐器的类别
    public var mdItemMusicalInstrumentCategory: String? { mdItem?.mdItemMusicalInstrumentCategory }

    /// 乐器名称 (格式: String?) - 音乐乐器的名称
    public var mdItemMusicalInstrumentName: String? { mdItem?.mdItemMusicalInstrumentName }

    // MARK: - 页面/文档属性

    /// HTML内容 (格式: String?) - 文档的HTML内容
    public var mdItemHTMLContent: String? { mdItem?.mdItemHTMLContent }

    /// 页数 (格式: Int?) - 文档的总页数
    public var mdItemNumberOfPages: Int? { mdItem?.mdItemNumberOfPages }

    /// 页面高度 (格式: Double?) - 文档页面的高度(点)
    public var mdItemPageHeight: Double? { mdItem?.mdItemPageHeight }

    /// 页面宽度 (格式: Double?) - 文档页面的宽度(点)
    public var mdItemPageWidth: Double? { mdItem?.mdItemPageWidth }

    // MARK: - 其他

    /// 文件tags
    public var mdItemUserTags: [String]? {
        value(forMetadataItem: MDKey.userTags)
    }
}
