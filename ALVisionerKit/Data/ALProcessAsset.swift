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
    let faces:[ALFace]
    let texts:[ALText]
    
    func duplicate(image:UIImage? = nil, tags:[String]? = nil, faces:[ALFace]? = nil, texts:[ALText]? = nil) -> ALProcessAsset {
        ALProcessAsset(identifier: identifier, image: image ?? self.image, tags: tags ?? self.tags, faces: faces ?? self.faces, texts:texts ?? self.texts )
    }
}
