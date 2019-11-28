//
//  ALFetchOptions.swift
//  ALVisionerKit
//
//  Created by amir.lahav on 28/11/2019.
//

import Foundation
import Photos

public enum ALFetchOptions {
    case allAssets
    case albumName(String)
    case assetCollection(PHAssetCollection)
    case mediaType(PHAssetMediaType)
    case identifiers([String])
}
