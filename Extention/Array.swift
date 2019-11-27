//
//  Array.swift
//  DisplayLiveSamples
//
//  Created by amir.lahav on 04/11/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation

extension Array {
    
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

public extension Array where Element == ProcessedALAsset {
    func printObjects() {
        self.forEach { (obj) in
            print("\n*************************************************************  \nLocal Identifier: \(obj.localIdentifier) \nImage Quality: \(obj.imageQuality) \nCategories: \(obj.categories) \nFaces Bounding Boxes: \(obj.boundingBoxes)")
        }
    }
}

extension ArraySlice {
    
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
