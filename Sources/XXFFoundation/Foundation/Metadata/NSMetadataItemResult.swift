//
//  NSMetadataItemResult.swift
//  xxf_ios
//  避免内存缓存的模型
//  Created by xxf on 6/12.
//
import Foundation

/// 字段信息 请查看协议里面的注释
open class NSMetadataItemResult: NSMetadataProtocol {
    open var mdItemAttributeChangeDate: Date?

    open var mdItemAudiences: [String]?

    open var mdItemAuthors: [String]?

    open var mdItemAuthorAddresses: [String]?

    open var mdItemAuthorEmailAddresses: [String]?

    open var mdItemCity: String?

    open var mdItemComment: String?

    open var mdItemContactKeywords: [String]?

    open var mdItemContentCreationDate: Date?

    open var mdItemContentModificationDate: Date?

    open var mdItemContentType: String?

    open var mdItemContentTypeTree: [String]?

    open var mdItemContributors: [String]?

    open var mdItemCopyright: String?

    open var mdItemCountry: String?

    open var mdItemCoverage: String?

    open var mdItemCreator: String?

    open var mdItemDateAdded: Date?

    open var mdItemDescription: String?

    open var mdItemDisplayName: String?

    open var mdItemDownloadedDate: Date?

    open var mdItemDueDate: Date?

    open var mdItemDurationSeconds: Double?

    open var mdItemEditors: [String]?

    open var mdItemEmailAddresses: [String]?

    open var mdItemEncodingApplications: [String]?

    open var mdItemFinderComment: String?

    open var mdItemFonts: [String]?

    open var mdItemHeadline: String?

    open var mdItemIdentifier: String?

    open var mdItemInformation: String?

    open var mdItemInstantMessageAddresses: [String]?

    open var mdItemInstructions: String?

    open var mdItemKeywords: [String]?

    open var mdItemKind: String?

    open var mdItemLanguages: [String]?

    open var mdItemLastUsedDate: Date?

    open var mdItemNamedLocation: String?

    open var mdItemOrganizations: [String]?

    open var mdItemParticipants: [String]?

    open var mdItemPhoneNumbers: [String]?

    open var mdItemProjects: [String]?

    open var mdItemPublishers: [String]?

    open var mdItemRecipients: [String]?

    open var mdItemRecipientAddresses: [String]?

    open var mdItemRecipientEmailAddresses: [String]?

    open var mdItemRights: String?

    open var mdItemSecurityMethod: String?

    open var mdItemStarRating: Double?

    open var mdItemStateOrProvince: String?

    open var mdItemSubject: String?

    open var mdItemTextContent: String?

    open var mdItemTheme: String?

    open var mdItemTitle: String?

    open var mdItemUrl: URL?

    open var mdItemVersion: String?

    open var mdItemWhereFroms: [String]?

    open var mdItemFSContentChangeDate: Date?

    open var mdItemFSCreationDate: Date?

    open var mdItemFSHasCustomIcon: Bool?

    open var mdItemFSInvisible: Bool

    open var mdItemFSIsExtensionHidden: Bool?

    open var mdItemFSIsStationery: Bool?

    open var mdItemFSLabel: Int?

    open var mdItemFSName: String

    open var mdItemFSNodeCount: Int?

    open var mdItemFSOwnerGroupID: Int?

    open var mdItemFSOwnerUserID: Int?

    open var mdItemFSPath: String

    open var mdItemFSSize: Int64?

    open var mdItemAcquisitionMake: String?

    open var mdItemAcquisitionModel: String?

    open var mdItemAlbum: String?

    open var mdItemAltitude: Double?

    open var mdItemAperture: Double?

    open var mdItemBitsPerSample: Int?

    open var mdItemCameraOwner: String?

    open var mdItemColorSpace: String?

    open var mdItemExifVersion: String?

    open var mdItemExposureMode: Int?

    open var mdItemExposureProgram: Int?

    open var mdItemExposureTimeSeconds: Double?

    open var mdItemExposureTimeString: String?

    open var mdItemFNumber: Double?

    open var mdItemFlashOnOff: Int?

    open var mdItemFocalLength: Double?

    open var mdItemFocalLength35mm: Double?

    open var mdItemGPSAreaInformation: String?

    open var mdItemGPSDateStamp: String?

    open var mdItemGPSDestBearing: Double?

    open var mdItemGPSDestDistance: Double?

    open var mdItemGPSDestLatitude: Double?

    open var mdItemGPSDestLongitude: Double?

    open var mdItemGPSDifferental: Int?

    open var mdItemGPSDop: Double?

    open var mdItemGPSMapDatum: String?

    open var mdItemGPSMeasureMode: String?

    open var mdItemGPSProcessingMethod: String?

    open var mdItemGPSStatus: String?

    open var mdItemGPSTrack: Double?

    open var mdItemHasAlphaChannel: Bool?

    open var mdItemImageDirection: Double?

    open var mdItemISOSpeed: Int?

    open var mdItemLatitude: Double?

    open var mdItemLayerNames: [String]?

    open var mdItemLensModel: String?

    open var mdItemLongitude: Double?

    open var mdItemMaxAperture: Double?

    open var mdItemMeteringMode: Int?

    open var mdItemOrientation: Int?

    open var mdItemPixelCount: Int?

    open var mdItemPixelHeight: Int?

    open var mdItemPixelWidth: Int?

    open var mdItemProfileName: String?

    open var mdItemRedEyeOnOff: Int?

    open var mdItemResolutionHeightDpi: Int?

    open var mdItemResolutionWidthDpi: Int?

    open var mdItemSpeed: Double?

    open var mdItemTimestamp: Date?

    open var mdItemWhiteBalance: Int?

    open var mdItemXMPCredit: String?

    open var mdItemXMPDigitalSourceType: String?

    open var mdItemAudioBitRate: Int?

    open var mdItemAudioChannelCount: Int?

    open var mdItemAudioSampleRate: Int?

    open var mdItemAudioTrackNumber: Int?

    open var mdItemCodecs: [String]?

    open var mdItemComposer: String?

    open var mdItemDeliveryType: String?

    open var mdItemDirector: String?

    open var mdItemGenre: String?

    open var mdItemIsGeneralMIDISequence: Bool?

    open var mdItemKeySignature: String?

    open var mdItemLyricist: String?

    open var mdItemMediaTypes: [String]?

    open var mdItemMusicalGenre: String?

    open var mdItemOriginalFormat: String?

    open var mdItemOriginalSource: String?

    open var mdItemPerformers: [String]?

    open var mdItemProducer: String?

    open var mdItemRecordingDate: Date?

    open var mdItemRecordingYear: Int?

    open var mdItemStreamable: Bool?

    open var mdItemTempo: Double?

    open var mdItemTimeSignature: String?

    open var mdItemTotalBitRate: Int?

    open var mdItemVideoBitRate: Int?

    open var mdItemApplicationCategories: [String]?

    open var mdItemCFBundleIdentifier: String?

    open var mdItemExecutableArchitectures: [String]?

    open var mdItemExecutablePlatform: String?

    open var mdItemIsApplicationManaged: Bool?

    open var mdItemIsLikelyJunk: Bool?

    open var mdItemAppleLoopDescriptors: [String]?

    open var mdItemAppleLoopsKeyFilterType: String?

    open var mdItemAppleLoopsLoopMode: String?

    open var mdItemAppleLoopsRootKey: String?

    open var mdItemAudioEncodingApplication: String?

    open var mdItemEXIFGPSVersion: String?

    open var mdItemGPSVersion: String?

    open var mdItemMediaExtensions: [String]?

    open var mdItemMusicalInstrumentCategory: String?

    open var mdItemMusicalInstrumentName: String?

    open var mdItemHTMLContent: String?

    open var mdItemNumberOfPages: Int?

    open var mdItemPageHeight: Double?

    open var mdItemPageWidth: Double?

    open var mdItemUserTags: [String]?
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
        mdItemFSPath = metadataItem.mdItemFSPath
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

        mdItemUserTags = metadataItem.mdItemUserTags
    }
}
