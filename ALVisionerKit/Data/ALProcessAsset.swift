//
//  ALProcessAsset.swift
//  ALVisionerKit
//
//  Created by amir.lahav on 26/11/2019.
//

import Foundation

struct ALProcessAsset {
    let identifier:String
    let image:UIImage
    let tags:[String]
    let quality:Float
    let facesRects:[CGRect]
}
