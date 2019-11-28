//
//  ClusterMangerOptions.swift
//  ALVisionerKit
//
//  Created by amir.lahav on 26/11/2019.
//

import Foundation

class ALClusterMangerOptions {
    var numberOfUserAssetsToProcess:Int = Int.max
    var chunckSize:Int = 10
    var minimumClusterSize:Int = 0
    var maximumFaceDetect:Int = Int.max
    var ascendingOrder:Bool = true
    var threshold:Double = 0.6
}
