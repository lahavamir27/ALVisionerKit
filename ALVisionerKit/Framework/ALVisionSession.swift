//
//  ALVisionManager.swift
//  ALVisionerKit
//
//  Created by amir.lahav on 16/11/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import Photos
import CoreML

public final class ALVisionSession {
    
    private let processor = ALVisionProcessor()
    
    //MARK: Public API
    public init() {}
    
    public func detect(in assets:PHFetchResult<PHAsset>, with jobTypes:[ALVisionProcessorType],options:ALSessionOptinos = ALSessionOptinos(), completion:@escaping(Result<[ALProcessedAsset],ALVisionError>)-> Void) {
        processor.performDetection(on: assets, jobTypes: jobTypes, options:options, completion: completion)
    }
    
    public func detect(in assets:[PHAsset], with jobTypes:[ALVisionProcessorType], options:ALSessionOptinos = ALSessionOptinos(), completion:@escaping(Result<[ALProcessedAsset],ALVisionError>)-> Void) {
        processor.performDetection(on: assets, jobTypes: jobTypes, options:options, completion: completion)
    }
    
    public func detect<T>(in assets:UIImage, model:MLModel, returnType:T.Type, completion:@escaping (Result<T,ALVisionError>)-> Void) {
        DispatchQueue.global().async {
            self.processor.perform(image: assets, model: model, completion: completion)
        }
    }
}
