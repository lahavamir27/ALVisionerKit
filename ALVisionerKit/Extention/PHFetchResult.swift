//
//  PHFetchResult.swift
//  ALVisionerKit
//
//  Created by amir.lahav on 29/11/2019.
//

import Foundation
import Photos

extension PHFetchResult where ObjectType == PHAsset {
    var objects: [ObjectType] {
        var _objects: [ObjectType] = []
        enumerateObjects { (asset, _, _) in
            if !(asset.mediaSubtypes == .photoScreenshot) {
                _objects.append(asset)
            }
        }
        return _objects
    }
}
