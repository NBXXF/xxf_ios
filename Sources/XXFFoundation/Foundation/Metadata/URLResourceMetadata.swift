//
//  URLResourceMetadata.swift
//  xxf_ios
//  使用 URLResourceValues 填充 NSMetadataProtocol
//  Created by xxf on 9/12.
//

import Foundation
import UniformTypeIdentifiers

public class URLResourceMetadata: NSMetadataProtocol {
    private let fileURL: URL
    private let fileManager = FileManager.default

    public init?(path: String) {
        let url = URL(fileURLWithPath: path)
        guard fileManager.fileExistsFast(atPath: url.path) else {
            return nil
        }
        fileURL = url
    }

    public init?(fileURL: URL) {
        guard fileManager.fileExistsFast(atPath: fileURL.path) else {
            return nil
        }
        self.fileURL = fileURL
    }

    // MARK: - 文件系统属性 helpers

    private lazy var resourceValues: URLResourceValues? = try? fileURL.resourceValues(forKeys: [
        .creationDateKey,
        .contentModificationDateKey,
        .contentAccessDateKey,
        .fileSizeKey,
        .isHiddenKey,
        .isAliasFileKey,
        .isExecutableKey,
        .isReadableKey,
        .isWritableKey,
        .isDirectoryKey,
        .isPackageKey,
        .typeIdentifierKey,
        .nameKey,
        .isSymbolicLinkKey,
        .labelNumberKey,
        .hasHiddenExtensionKey,
    ])

    private lazy var fileAttributes: [FileAttributeKey: Any]? = try? fileManager.attributesOfItem(atPath: fileURL.path)

    // MARK: - 文件系统基础字段

    public lazy var mdItemFSPath: String = fileURL.path
    public lazy var mdItemFSName: String = resourceValues?.name ?? fileURL.lastPathComponent
    public lazy var mdItemFSSize: Int64? = resourceValues?.fileSize.flatMap { Int64($0) }
    public lazy var mdItemFSCreationDate: Date? = resourceValues?.creationDate
    public lazy var mdItemFSContentChangeDate: Date? = resourceValues?.contentModificationDate
    public lazy var mdItemFSInvisible: Bool = fileURL.isHiddenFile
    public lazy var mdItemFSIsExtensionHidden: Bool? = resourceValues?.hasHiddenExtension
    public lazy var mdItemFSLabel: Int? = resourceValues?.labelNumber
    public lazy var mdItemFSOwnerUserID: Int? = fileAttributes?[.ownerAccountID] as? Int
    public lazy var mdItemFSOwnerGroupID: Int? = fileAttributes?[.groupOwnerAccountID] as? Int
    public lazy var mdItemFSNodeCount: Int? = fileAttributes?[.referenceCount] as? Int
    public lazy var mdItemFSHasCustomIcon: Bool? = nil
    public lazy var mdItemFSIsStationery: Bool? = nil

    // MARK: - 文件内容 / 通用属性

    public lazy var mdItemContentType: String? = resourceValues?.typeIdentifier
    public lazy var mdItemContentTypeTree: [String]? = {
        guard let uti = mdItemContentType else { return nil }
        var types = [uti]
        if let utType = UTType(uti) {
            types.append(contentsOf: utType.supertypes.map { $0.identifier })
        }
        return types
    }()

    public lazy var mdItemDisplayName: String? = resourceValues?.name
    public lazy var mdItemKind: String? = resourceValues?.typeIdentifier
    public lazy var mdItemAttributeChangeDate: Date? = fileAttributes?[.modificationDate] as? Date
    public lazy var mdItemContentCreationDate: Date? = resourceValues?.creationDate
    public lazy var mdItemContentModificationDate: Date? = resourceValues?.contentModificationDate
    public lazy var mdItemUrl: URL? = fileURL

    // MARK: - 其他字段全部返回 nil / 默认

    public lazy var mdItemAudiences: [String]? = nil
    public lazy var mdItemAuthors: [String]? = nil
    public lazy var mdItemAuthorAddresses: [String]? = nil
    public lazy var mdItemAuthorEmailAddresses: [String]? = nil
    public lazy var mdItemCity: String? = nil
    public lazy var mdItemComment: String? = nil
    public lazy var mdItemContactKeywords: [String]? = nil
    public lazy var mdItemContributors: [String]? = nil
    public lazy var mdItemCopyright: String? = nil
    public lazy var mdItemCountry: String? = nil
    public lazy var mdItemCoverage: String? = nil
    public lazy var mdItemCreator: String? = nil
    public lazy var mdItemDateAdded: Date? = nil
    public lazy var mdItemDescription: String? = nil
    public lazy var mdItemDownloadedDate: Date? = nil
    public lazy var mdItemDueDate: Date? = nil
    public lazy var mdItemDurationSeconds: Double? = nil
    public lazy var mdItemEditors: [String]? = nil
    public lazy var mdItemEmailAddresses: [String]? = nil
    public lazy var mdItemEncodingApplications: [String]? = nil
    public lazy var mdItemFinderComment: String? = nil
    public lazy var mdItemFonts: [String]? = nil
    public lazy var mdItemHeadline: String? = nil
    public lazy var mdItemIdentifier: String? = nil
    public lazy var mdItemInformation: String? = nil
    public lazy var mdItemInstantMessageAddresses: [String]? = nil
    public lazy var mdItemInstructions: String? = nil
    public lazy var mdItemKeywords: [String]? = nil
    public lazy var mdItemLanguages: [String]? = nil
    public lazy var mdItemLastUsedDate: Date? = nil
    public lazy var mdItemNamedLocation: String? = nil
    public lazy var mdItemOrganizations: [String]? = nil
    public lazy var mdItemParticipants: [String]? = nil
    public lazy var mdItemPhoneNumbers: [String]? = nil
    public lazy var mdItemProjects: [String]? = nil
    public lazy var mdItemPublishers: [String]? = nil
    public lazy var mdItemRecipients: [String]? = nil
    public lazy var mdItemRecipientAddresses: [String]? = nil
    public lazy var mdItemRecipientEmailAddresses: [String]? = nil
    public lazy var mdItemRights: String? = nil
    public lazy var mdItemSecurityMethod: String? = nil
    public lazy var mdItemStarRating: Double? = nil
    public lazy var mdItemStateOrProvince: String? = nil
    public lazy var mdItemSubject: String? = nil
    public lazy var mdItemTextContent: String? = nil
    public lazy var mdItemTheme: String? = nil
    public lazy var mdItemTitle: String? = nil
    public lazy var mdItemVersion: String? = nil
    public lazy var mdItemWhereFroms: [String]? = nil

    // MARK: - 图像属性

    public lazy var mdItemAcquisitionMake: String? = nil
    public lazy var mdItemAcquisitionModel: String? = nil
    public lazy var mdItemAlbum: String? = nil
    public lazy var mdItemAltitude: Double? = nil
    public lazy var mdItemAperture: Double? = nil
    public lazy var mdItemBitsPerSample: Int? = nil
    public lazy var mdItemCameraOwner: String? = nil
    public lazy var mdItemColorSpace: String? = nil
    public lazy var mdItemExifVersion: String? = nil
    public lazy var mdItemExposureMode: Int? = nil
    public lazy var mdItemExposureProgram: Int? = nil
    public lazy var mdItemExposureTimeSeconds: Double? = nil
    public lazy var mdItemExposureTimeString: String? = nil
    public lazy var mdItemFNumber: Double? = nil
    public lazy var mdItemFlashOnOff: Int? = nil
    public lazy var mdItemFocalLength: Double? = nil
    public lazy var mdItemFocalLength35mm: Double? = nil
    public lazy var mdItemGPSAreaInformation: String? = nil
    public lazy var mdItemGPSDateStamp: String? = nil
    public lazy var mdItemGPSDestBearing: Double? = nil
    public lazy var mdItemGPSDestDistance: Double? = nil
    public lazy var mdItemGPSDestLatitude: Double? = nil
    public lazy var mdItemGPSDestLongitude: Double? = nil
    public lazy var mdItemGPSDifferental: Int? = nil
    public lazy var mdItemGPSDop: Double? = nil
    public lazy var mdItemGPSMapDatum: String? = nil
    public lazy var mdItemGPSMeasureMode: String? = nil
    public lazy var mdItemGPSProcessingMethod: String? = nil
    public lazy var mdItemGPSStatus: String? = nil
    public lazy var mdItemGPSTrack: Double? = nil
    public lazy var mdItemHasAlphaChannel: Bool? = nil
    public lazy var mdItemImageDirection: Double? = nil
    public lazy var mdItemISOSpeed: Int? = nil
    public lazy var mdItemLatitude: Double? = nil
    public lazy var mdItemLayerNames: [String]? = nil
    public lazy var mdItemLensModel: String? = nil
    public lazy var mdItemLongitude: Double? = nil
    public lazy var mdItemMaxAperture: Double? = nil
    public lazy var mdItemMeteringMode: Int? = nil
    public lazy var mdItemOrientation: Int? = nil
    public lazy var mdItemPixelCount: Int? = nil
    public lazy var mdItemPixelHeight: Int? = nil
    public lazy var mdItemPixelWidth: Int? = nil
    public lazy var mdItemProfileName: String? = nil
    public lazy var mdItemRedEyeOnOff: Int? = nil
    public lazy var mdItemResolutionHeightDpi: Int? = nil
    public lazy var mdItemResolutionWidthDpi: Int? = nil
    public lazy var mdItemSpeed: Double? = nil
    public lazy var mdItemTimestamp: Date? = nil
    public lazy var mdItemWhiteBalance: Int? = nil
    public lazy var mdItemXMPCredit: String? = nil
    public lazy var mdItemXMPDigitalSourceType: String? = nil

    // MARK: - 音视频属性

    public lazy var mdItemAudioBitRate: Int? = nil
    public lazy var mdItemAudioChannelCount: Int? = nil
    public lazy var mdItemAudioSampleRate: Int? = nil
    public lazy var mdItemAudioTrackNumber: Int? = nil
    public lazy var mdItemCodecs: [String]? = nil
    public lazy var mdItemComposer: String? = nil
    public lazy var mdItemDeliveryType: String? = nil
    public lazy var mdItemDirector: String? = nil
    public lazy var mdItemGenre: String? = nil
    public lazy var mdItemIsGeneralMIDISequence: Bool? = nil
    public lazy var mdItemKeySignature: String? = nil
    public lazy var mdItemLyricist: String? = nil
    public lazy var mdItemMediaTypes: [String]? = nil
    public lazy var mdItemMusicalGenre: String? = nil
    public lazy var mdItemOriginalFormat: String? = nil
    public lazy var mdItemOriginalSource: String? = nil
    public lazy var mdItemPerformers: [String]? = nil
    public lazy var mdItemProducer: String? = nil
    public lazy var mdItemRecordingDate: Date? = nil
    public lazy var mdItemRecordingYear: Int? = nil
    public lazy var mdItemStreamable: Bool? = nil
    public lazy var mdItemTempo: Double? = nil
    public lazy var mdItemTimeSignature: String? = nil
    public lazy var mdItemTotalBitRate: Int? = nil
    public lazy var mdItemVideoBitRate: Int? = nil

    // MARK: - 应用属性

    public lazy var mdItemApplicationCategories: [String]? = nil
    public lazy var mdItemCFBundleIdentifier: String? = nil
    public lazy var mdItemExecutableArchitectures: [String]? = nil
    public lazy var mdItemExecutablePlatform: String? = nil
    public lazy var mdItemIsApplicationManaged: Bool? = nil
    public lazy var mdItemIsLikelyJunk: Bool? = nil

    // MARK: - 媒体制作 / 页面 / 文档属性

    public lazy var mdItemAppleLoopDescriptors: [String]? = nil
    public lazy var mdItemAppleLoopsKeyFilterType: String? = nil
    public lazy var mdItemAppleLoopsLoopMode: String? = nil
    public lazy var mdItemAppleLoopsRootKey: String? = nil
    public lazy var mdItemAudioEncodingApplication: String? = nil
    public lazy var mdItemEXIFGPSVersion: String? = nil
    public lazy var mdItemGPSVersion: String? = nil
    public lazy var mdItemMediaExtensions: [String]? = nil
    public lazy var mdItemMusicalInstrumentCategory: String? = nil
    public lazy var mdItemMusicalInstrumentName: String? = nil
    public lazy var mdItemHTMLContent: String? = nil
    public lazy var mdItemNumberOfPages: Int? = nil
    public lazy var mdItemPageHeight: Double? = nil
    public lazy var mdItemPageWidth: Double? = nil
    public lazy var mdItemUserTags: [String]? = nil
}
