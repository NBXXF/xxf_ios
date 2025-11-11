//
//  RepresentationType.swift
//  xxf_ios
//  图标模式或者缩略图模式
//  Created by xxf on 9/15.
//

import QuickLookThumbnailing

public enum RepresentationType: Int {
    case all = 0
    case thumbnail = 1
    case icon = 2

    var rawTypes: QLThumbnailGenerator.Request.RepresentationTypes {
        switch self {
        case .all: return QLThumbnailGenerator.Request.RepresentationTypes.all
        case .thumbnail: return QLThumbnailGenerator.Request.RepresentationTypes.thumbnail
        case .icon: return QLThumbnailGenerator.Request.RepresentationTypes.icon
        }
    }
}
