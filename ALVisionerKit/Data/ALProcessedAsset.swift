//
//  ProcessedALAsset.swift
//  ALVisionerKit
//
//  Created by amir.lahav on 24/11/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation

public struct ALProcessedAsset {
    let localIdentifier:String
    let categories:[String]
    let faces:[ALFace]
    let texts:[ALText]

    init(asset:ALProcessAsset) {
        self.localIdentifier = asset.identifier
        self.categories = asset.tags
        self.faces = asset.faces
        self.texts = asset.texts
    }
}
