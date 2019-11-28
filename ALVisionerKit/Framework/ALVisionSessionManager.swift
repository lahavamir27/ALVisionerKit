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

public final class ALVisionSessionManager {
    
    private let processor = ALVisionProcessor()

    //MARK: Public API
    public init() {}
    
    public func detect(in assets:PHFetchResult<PHAsset>, with jobTypes:[ALVisionProcessorType], completion:@escaping(Result<[ProcessedALAsset],ALVisionError>)-> Void) {
        processor.performDetection(on: assets, jobTypes: jobTypes, completion: completion)
    }
    
    public func detect(in assets:[PHAsset], with jobTypes:[ALVisionProcessorType], completion:@escaping(Result<[ProcessedALAsset],ALVisionError>)-> Void) {
         processor.performDetection(on: assets, jobTypes: jobTypes, completion: completion)
     }
    
    public func detect<T>(in assets:UIImage, model:MLModel, returnType:T.Type, completion:@escaping (Result<T,ALVisionError>)-> Void) {
        processor.perform(image: assets, model: model, completion: completion)
    }
}
