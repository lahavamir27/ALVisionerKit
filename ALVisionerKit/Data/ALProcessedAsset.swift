//
//  ProcessedALAsset.swift
//  ALFacerKit
//
//  Created by amir.lahav on 24/11/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation

public struct ALProcessedAsset {
    let localIdentifier:String
    let imageQuality:Float
    let categories:[String]
    let boundingBoxes:[CGRect]
    init(asset:ALProcessAsset) {
        self.localIdentifier = asset.identifier
        self.imageQuality = asset.quality
        self.categories = asset.tags
        self.boundingBoxes = asset.observation
    }
}
