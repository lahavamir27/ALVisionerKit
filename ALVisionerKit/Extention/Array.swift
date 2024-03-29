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

public extension Array where Element == ALProcessedAsset {
    func printObjects() {
        print("\n*************************************************************")
        print("detect \(self.count) photos \n")
        self.forEach { (obj) in
            print("\n*************************************************************  \nLocal Identifier: \(obj.localIdentifier) \nCategories: \(obj.categories) \n faces:\(obj.faces)\n texts:\(obj.texts)")
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
