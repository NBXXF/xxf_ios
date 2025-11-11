//
//  ImageLoaderAdapter+Default.swift
//  xxf_ios
//
//  Created by xxf on 8/20.
//

import Foundation

extension ImageLoaderAdapter {
    var imageFectchers: [ImageDataFetcher] {
        return [//LocalFileThumbnailDataFetcher(),
            LocalResourceDataFetcher()]
    }
}
