//
//  ALPerformOptinos.swift
//  ALVisionerKit
//
//  Created by amir.lahav on 30/11/2019.
//

import Foundation

public class ALSessionOptinos {
    public var qos:DispatchQoS.QoSClass = .default
    public var parallelProcessQuantity:Int = 5
    public var optimzedFaceDetection:Bool = false
    public init() {}
}
