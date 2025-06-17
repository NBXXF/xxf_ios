//
//  NSMetadataItemResult.swift
//  xxf_ios
//  避免内存缓存的模型
//  Created by trl on 6/12.
//
import Foundation

/// 字段信息 请查看协议里面的注释
public class NSMetadataItemResult: NSMetadataProtocol {
    public var mdItemAttributeChangeDate: Date?

    public var mdItemAudiences: [String]?

    public var mdItemAuthors: [String]?

    public var mdItemAuthorAddresses: [String]?

    public var mdItemAuthorEmailAddresses: [String]?

    public var mdItemCity: String?

    public var mdItemComment: String?

    public var mdItemContactKeywords: [String]?

    public var mdItemContentCreationDate: Date?

    public var mdItemContentModificationDate: Date?

    public var mdItemContentType: String?

    public var mdItemContentTypeTree: [String]?

    public var mdItemContributors: [String]?

    public var mdItemCopyright: String?

    public var mdItemCountry: String?

    public var mdItemCoverage: String?

    public var mdItemCreator: String?

    public var mdItemDateAdded: Date?

    public var mdItemDescription: String?

    public var mdItemDisplayName: String?

    public var mdItemDownloadedDate: Date?

    public var mdItemDueDate: Date?

    public var mdItemDurationSeconds: Double?

    public var mdItemEditors: [String]?

    public var mdItemEmailAddresses: [String]?

    public var mdItemEncodingApplications: [String]?

    public var mdItemFinderComment: String?

    public var mdItemFonts: [String]?

    public var mdItemHeadline: String?

    public var mdItemIdentifier: String?

    public var mdItemInformation: String?

    public var mdItemInstantMessageAddresses: [String]?

    public var mdItemInstructions: String?

    public var mdItemKeywords: [String]?

    public var mdItemKind: String?

    public var mdItemLanguages: [String]?

    public var mdItemLastUsedDate: Date?

    public var mdItemNamedLocation: String?

    public var mdItemOrganizations: [String]?

    public var mdItemParticipants: [String]?

    public var mdItemPhoneNumbers: [String]?

    public var mdItemProjects: [String]?

    public var mdItemPublishers: [String]?

    public var mdItemRecipients: [String]?

    public var mdItemRecipientAddresses: [String]?

    public var mdItemRecipientEmailAddresses: [String]?

    public var mdItemRights: String?

    public var mdItemSecurityMethod: String?

    public var mdItemStarRating: Double?

    public var mdItemStateOrProvince: String?

    public var mdItemSubject: String?

    public var mdItemTextContent: String?

    public var mdItemTheme: String?

    public var mdItemTitle: String?

    public var mdItemUrl: String?

    public var mdItemVersion: String?

    public var mdItemWhereFroms: [String]?

    public var mdItemFSContentChangeDate: Date?

    public var mdItemFSCreationDate: Date?

    public var mdItemFSHasCustomIcon: Bool?

    public var mdItemFSInvisible: Bool?

    public var mdItemFSIsExtensionHidden: Bool?

    public var mdItemFSIsStationery: Bool?

    public var mdItemFSLabel: Int?

    public var mdItemFSName: String?

    public var mdItemFSNodeCount: Int?

    public var mdItemFSOwnerGroupID: Int?

    public var mdItemFSOwnerUserID: Int?

    public var mdItemFSPath: String?

    public var mdItemFSSize: Int?

    public var mdItemAcquisitionMake: String?

    public var mdItemAcquisitionModel: String?

    public var mdItemAlbum: String?

    public var mdItemAltitude: Double?

    public var mdItemAperture: Double?

    public var mdItemBitsPerSample: Int?

    public var mdItemCameraOwner: String?

    public var mdItemColorSpace: String?

    public var mdItemExifVersion: String?

    public var mdItemExposureMode: Int?

    public var mdItemExposureProgram: Int?

    public var mdItemExposureTimeSeconds: Double?

    public var mdItemExposureTimeString: String?

    public var mdItemFNumber: Double?

    public var mdItemFlashOnOff: Int?

    public var mdItemFocalLength: Double?

    public var mdItemFocalLength35mm: Double?

    public var mdItemGPSAreaInformation: String?

    public var mdItemGPSDateStamp: String?

    public var mdItemGPSDestBearing: Double?

    public var mdItemGPSDestDistance: Double?

    public var mdItemGPSDestLatitude: Double?

    public var mdItemGPSDestLongitude: Double?

    public var mdItemGPSDifferental: Int?

    public var mdItemGPSDop: Double?

    public var mdItemGPSMapDatum: String?

    public var mdItemGPSMeasureMode: String?

    public var mdItemGPSProcessingMethod: String?

    public var mdItemGPSStatus: String?

    public var mdItemGPSTrack: Double?

    public var mdItemHasAlphaChannel: Bool?

    public var mdItemImageDirection: Double?

    public var mdItemISOSpeed: Int?

    public var mdItemLatitude: Double?

    public var mdItemLayerNames: [String]?

    public var mdItemLensModel: String?

    public var mdItemLongitude: Double?

    public var mdItemMaxAperture: Double?

    public var mdItemMeteringMode: Int?

    public var mdItemOrientation: Int?

    public var mdItemPixelCount: Int?

    public var mdItemPixelHeight: Int?

    public var mdItemPixelWidth: Int?

    public var mdItemProfileName: String?

    public var mdItemRedEyeOnOff: Int?

    public var mdItemResolutionHeightDpi: Int?

    public var mdItemResolutionWidthDpi: Int?

    public var mdItemSpeed: Double?

    public var mdItemTimestamp: Date?

    public var mdItemWhiteBalance: Int?

    public var mdItemXMPCredit: String?

    public var mdItemXMPDigitalSourceType: String?

    public var mdItemAudioBitRate: Int?

    public var mdItemAudioChannelCount: Int?

    public var mdItemAudioSampleRate: Int?

    public var mdItemAudioTrackNumber: Int?

    public var mdItemCodecs: [String]?

    public var mdItemComposer: String?

    public var mdItemDeliveryType: String?

    public var mdItemDirector: String?

    public var mdItemGenre: String?

    public var mdItemIsGeneralMIDISequence: Bool?

    public var mdItemKeySignature: String?

    public var mdItemLyricist: String?

    public var mdItemMediaTypes: [String]?

    public var mdItemMusicalGenre: String?

    public var mdItemOriginalFormat: String?

    public var mdItemOriginalSource: String?

    public var mdItemPerformers: [String]?

    public var mdItemProducer: String?

    public var mdItemRecordingDate: Date?

    public var mdItemRecordingYear: Int?

    public var mdItemStreamable: Bool?

    public var mdItemTempo: Double?

    public var mdItemTimeSignature: String?

    public var mdItemTotalBitRate: Int?

    public var mdItemVideoBitRate: Int?

    public var mdItemApplicationCategories: [String]?

    public var mdItemCFBundleIdentifier: String?

    public var mdItemExecutableArchitectures: [String]?

    public var mdItemExecutablePlatform: String?

    public var mdItemIsApplicationManaged: Bool?

    public var mdItemIsLikelyJunk: Bool?

    public var mdItemAppleLoopDescriptors: [String]?

    public var mdItemAppleLoopsKeyFilterType: String?

    public var mdItemAppleLoopsLoopMode: String?

    public var mdItemAppleLoopsRootKey: String?

    public var mdItemAudioEncodingApplication: String?

    public var mdItemEXIFGPSVersion: String?

    public var mdItemGPSVersion: String?

    public var mdItemMediaExtensions: [String]?

    public var mdItemMusicalInstrumentCategory: String?

    public var mdItemMusicalInstrumentName: String?

    public var mdItemHTMLContent: String?

    public var mdItemNumberOfPages: Int?

    public var mdItemPageHeight: Double?

    public var mdItemPageWidth: Double?

    public init(fromMetadataItem metadataItem: NSMetadataProtocol) {
        // Document related
        mdItemTitle = metadataItem.mdItemTitle
        mdItemAuthors = metadataItem.mdItemAuthors
        mdItemCreator = metadataItem.mdItemCreator
        mdItemNumberOfPages = metadataItem.mdItemNumberOfPages
        mdItemPageHeight = metadataItem.mdItemPageHeight
        mdItemPageWidth = metadataItem.mdItemPageWidth

        // Image related
        mdItemPixelWidth = metadataItem.mdItemPixelWidth
        mdItemPixelHeight = metadataItem.mdItemPixelHeight
        mdItemColorSpace = metadataItem.mdItemColorSpace
        mdItemBitsPerSample = metadataItem.mdItemBitsPerSample
        mdItemExposureTimeSeconds = metadataItem.mdItemExposureTimeSeconds
        mdItemAperture = metadataItem.mdItemAperture
        mdItemFNumber = metadataItem.mdItemFNumber
        mdItemISOSpeed = metadataItem.mdItemISOSpeed
        mdItemFlashOnOff = metadataItem.mdItemFlashOnOff
        mdItemOrientation = metadataItem.mdItemOrientation
        mdItemContentCreationDate = metadataItem.mdItemContentCreationDate
        mdItemLatitude = metadataItem.mdItemLatitude
        mdItemLongitude = metadataItem.mdItemLongitude
        mdItemCountry = metadataItem.mdItemCountry
        mdItemProfileName = metadataItem.mdItemProfileName

        // Metadata properties
        mdItemAttributeChangeDate = metadataItem.mdItemAttributeChangeDate
        mdItemAudiences = metadataItem.mdItemAudiences
        mdItemAuthorAddresses = metadataItem.mdItemAuthorAddresses
        mdItemAuthorEmailAddresses = metadataItem.mdItemAuthorEmailAddresses
        mdItemCity = metadataItem.mdItemCity
        mdItemComment = metadataItem.mdItemComment
        mdItemContactKeywords = metadataItem.mdItemContactKeywords
        mdItemContentModificationDate = metadataItem.mdItemContentModificationDate
        mdItemContentType = metadataItem.mdItemContentType
        mdItemContentTypeTree = metadataItem.mdItemContentTypeTree
        mdItemContributors = metadataItem.mdItemContributors
        mdItemCopyright = metadataItem.mdItemCopyright
        mdItemCoverage = metadataItem.mdItemCoverage
        mdItemDateAdded = metadataItem.mdItemDateAdded
        mdItemDescription = metadataItem.mdItemDescription
        mdItemDisplayName = metadataItem.mdItemDisplayName
        mdItemDownloadedDate = metadataItem.mdItemDownloadedDate
        mdItemDueDate = metadataItem.mdItemDueDate
        mdItemDurationSeconds = metadataItem.mdItemDurationSeconds
        mdItemEditors = metadataItem.mdItemEditors
        mdItemEmailAddresses = metadataItem.mdItemEmailAddresses
        mdItemEncodingApplications = metadataItem.mdItemEncodingApplications
        mdItemFinderComment = metadataItem.mdItemFinderComment
        mdItemFonts = metadataItem.mdItemFonts
        mdItemHeadline = metadataItem.mdItemHeadline
        mdItemIdentifier = metadataItem.mdItemIdentifier
        mdItemInformation = metadataItem.mdItemInformation
        mdItemInstantMessageAddresses = metadataItem.mdItemInstantMessageAddresses
        mdItemInstructions = metadataItem.mdItemInstructions
        mdItemKeywords = metadataItem.mdItemKeywords
        mdItemKind = metadataItem.mdItemKind
        mdItemLanguages = metadataItem.mdItemLanguages
        mdItemLastUsedDate = metadataItem.mdItemLastUsedDate
        mdItemNamedLocation = metadataItem.mdItemNamedLocation
        mdItemOrganizations = metadataItem.mdItemOrganizations
        mdItemParticipants = metadataItem.mdItemParticipants
        mdItemPhoneNumbers = metadataItem.mdItemPhoneNumbers
        mdItemProjects = metadataItem.mdItemProjects
        mdItemPublishers = metadataItem.mdItemPublishers
        mdItemRecipients = metadataItem.mdItemRecipients
        mdItemRecipientAddresses = metadataItem.mdItemRecipientAddresses
        mdItemRecipientEmailAddresses = metadataItem.mdItemRecipientEmailAddresses
        mdItemRights = metadataItem.mdItemRights
        mdItemSecurityMethod = metadataItem.mdItemSecurityMethod
        mdItemStarRating = metadataItem.mdItemStarRating
        mdItemStateOrProvince = metadataItem.mdItemStateOrProvince
        mdItemSubject = metadataItem.mdItemSubject
        mdItemTextContent = metadataItem.mdItemTextContent
        mdItemTheme = metadataItem.mdItemTheme
        mdItemUrl = metadataItem.mdItemUrl
        mdItemVersion = metadataItem.mdItemVersion
        mdItemWhereFroms = metadataItem.mdItemWhereFroms
        mdItemFSContentChangeDate = metadataItem.mdItemFSContentChangeDate
        mdItemFSCreationDate = metadataItem.mdItemFSCreationDate
        mdItemFSHasCustomIcon = metadataItem.mdItemFSHasCustomIcon
        mdItemFSInvisible = metadataItem.mdItemFSInvisible
        mdItemFSIsExtensionHidden = metadataItem.mdItemFSIsExtensionHidden
        mdItemFSIsStationery = metadataItem.mdItemFSIsStationery
        mdItemFSLabel = metadataItem.mdItemFSLabel
        mdItemFSName = metadataItem.mdItemFSName
        mdItemFSNodeCount = metadataItem.mdItemFSNodeCount
        mdItemFSOwnerGroupID = metadataItem.mdItemFSOwnerGroupID
        mdItemFSOwnerUserID = metadataItem.mdItemFSOwnerUserID
        mdItemFSSize = metadataItem.mdItemFSSize
        mdItemAcquisitionMake = metadataItem.mdItemAcquisitionMake
        mdItemAcquisitionModel = metadataItem.mdItemAcquisitionModel
        mdItemAlbum = metadataItem.mdItemAlbum
        mdItemAltitude = metadataItem.mdItemAltitude
        mdItemExifVersion = metadataItem.mdItemExifVersion
        mdItemExposureMode = metadataItem.mdItemExposureMode
        mdItemExposureProgram = metadataItem.mdItemExposureProgram
        mdItemExposureTimeString = metadataItem.mdItemExposureTimeString
        mdItemFocalLength = metadataItem.mdItemFocalLength
        mdItemFocalLength35mm = metadataItem.mdItemFocalLength35mm
        mdItemGPSAreaInformation = metadataItem.mdItemGPSAreaInformation
        mdItemGPSDateStamp = metadataItem.mdItemGPSDateStamp
        mdItemGPSDestBearing = metadataItem.mdItemGPSDestBearing
        mdItemGPSDestDistance = metadataItem.mdItemGPSDestDistance
        mdItemGPSDestLatitude = metadataItem.mdItemGPSDestLatitude
        mdItemGPSDestLongitude = metadataItem.mdItemGPSDestLongitude
        mdItemGPSDifferental = metadataItem.mdItemGPSDifferental
        mdItemGPSDop = metadataItem.mdItemGPSDop
        mdItemGPSMapDatum = metadataItem.mdItemGPSMapDatum
        mdItemGPSMeasureMode = metadataItem.mdItemGPSMeasureMode
        mdItemGPSProcessingMethod = metadataItem.mdItemGPSProcessingMethod
        mdItemGPSStatus = metadataItem.mdItemGPSStatus
        mdItemGPSTrack = metadataItem.mdItemGPSTrack
        mdItemHasAlphaChannel = metadataItem.mdItemHasAlphaChannel
        mdItemImageDirection = metadataItem.mdItemImageDirection
        mdItemLayerNames = metadataItem.mdItemLayerNames
        mdItemLensModel = metadataItem.mdItemLensModel
        mdItemMaxAperture = metadataItem.mdItemMaxAperture
        mdItemMeteringMode = metadataItem.mdItemMeteringMode
        mdItemPixelCount = metadataItem.mdItemPixelCount
        mdItemRedEyeOnOff = metadataItem.mdItemRedEyeOnOff
        mdItemResolutionHeightDpi = metadataItem.mdItemResolutionHeightDpi
        mdItemResolutionWidthDpi = metadataItem.mdItemResolutionWidthDpi
        mdItemSpeed = metadataItem.mdItemSpeed
        mdItemTimestamp = metadataItem.mdItemTimestamp
        mdItemWhiteBalance = metadataItem.mdItemWhiteBalance
        mdItemXMPCredit = metadataItem.mdItemXMPCredit
        mdItemXMPDigitalSourceType = metadataItem.mdItemXMPDigitalSourceType
        mdItemAudioBitRate = metadataItem.mdItemAudioBitRate
        mdItemAudioChannelCount = metadataItem.mdItemAudioChannelCount
        mdItemAudioSampleRate = metadataItem.mdItemAudioSampleRate
        mdItemAudioTrackNumber = metadataItem.mdItemAudioTrackNumber
        mdItemCodecs = metadataItem.mdItemCodecs
        mdItemComposer = metadataItem.mdItemComposer
        mdItemDeliveryType = metadataItem.mdItemDeliveryType
        mdItemDirector = metadataItem.mdItemDirector
        mdItemGenre = metadataItem.mdItemGenre
        mdItemIsGeneralMIDISequence = metadataItem.mdItemIsGeneralMIDISequence
        mdItemKeySignature = metadataItem.mdItemKeySignature
        mdItemLyricist = metadataItem.mdItemLyricist
        mdItemMediaTypes = metadataItem.mdItemMediaTypes
        mdItemMusicalGenre = metadataItem.mdItemMusicalGenre
        mdItemOriginalFormat = metadataItem.mdItemOriginalFormat
        mdItemOriginalSource = metadataItem.mdItemOriginalSource
        mdItemPerformers = metadataItem.mdItemPerformers
        mdItemProducer = metadataItem.mdItemProducer
        mdItemRecordingDate = metadataItem.mdItemRecordingDate
        mdItemRecordingYear = metadataItem.mdItemRecordingYear
        mdItemStreamable = metadataItem.mdItemStreamable
        mdItemTempo = metadataItem.mdItemTempo
        mdItemTimeSignature = metadataItem.mdItemTimeSignature
        mdItemTotalBitRate = metadataItem.mdItemTotalBitRate
        mdItemVideoBitRate = metadataItem.mdItemVideoBitRate
        mdItemApplicationCategories = metadataItem.mdItemApplicationCategories
        mdItemCFBundleIdentifier = metadataItem.mdItemCFBundleIdentifier
        mdItemExecutableArchitectures = metadataItem.mdItemExecutableArchitectures
        mdItemExecutablePlatform = metadataItem.mdItemExecutablePlatform
        mdItemIsApplicationManaged = metadataItem.mdItemIsApplicationManaged
        mdItemIsLikelyJunk = metadataItem.mdItemIsLikelyJunk
        mdItemAppleLoopDescriptors = metadataItem.mdItemAppleLoopDescriptors
        mdItemAppleLoopsKeyFilterType = metadataItem.mdItemAppleLoopsKeyFilterType
        mdItemAppleLoopsLoopMode = metadataItem.mdItemAppleLoopsLoopMode
        mdItemAppleLoopsRootKey = metadataItem.mdItemAppleLoopsRootKey
        mdItemAudioEncodingApplication = metadataItem.mdItemAudioEncodingApplication
        mdItemEXIFGPSVersion = metadataItem.mdItemEXIFGPSVersion
        mdItemGPSVersion = metadataItem.mdItemGPSVersion
        mdItemMediaExtensions = metadataItem.mdItemMediaExtensions
        mdItemMusicalInstrumentCategory = metadataItem.mdItemMusicalInstrumentCategory
        mdItemMusicalInstrumentName = metadataItem.mdItemMusicalInstrumentName
        mdItemHTMLContent = metadataItem.mdItemHTMLContent
    }
}
