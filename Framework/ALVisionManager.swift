//
//  ALVisionManager.swift
//  ALFacerKit
//
//  Created by amir.lahav on 16/11/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import Photos
import CoreML

public final class ALVisionManager {
    
    private static let detector = ALVisionProcessor()

    //MARK: Public API
    
    public static func detect(in assets:PHFetchResult<PHAsset>, with jobTypes:[ALVisionProcessorType], completion:@escaping(Result<[ProcessedALAsset],ALVisionError>)-> Void) {
        detector.performDetection(on: assets, jobTypes: jobTypes, completion: completion)
    }
    
    public static func detect(in assets:[PHAsset], with jobTypes:[ALVisionProcessorType], completion:@escaping(Result<[ProcessedALAsset],ALVisionError>)-> Void) {
         detector.performDetection(on: assets, jobTypes: jobTypes, completion: completion)
     }
    
    public static func detect<T>(in assets:UIImage, model:MLModel, returnType:T.Type, completion:@escaping (Result<T,ALVisionError>)-> Void) {
        detector.perform(image: assets, model: model, completion: completion)
    }
}
