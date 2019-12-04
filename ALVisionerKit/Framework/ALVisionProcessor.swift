//
//  ALVisionProcessor.swift
//  ALVisionerKit
//
//  Created by amir.lahav on 16/11/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import Photos
import CoreML

final class ALVisionProcessor {
    
    private var imageFilter = ALImagePipeline()
    private var assetsManager = ALAssetManager()
    private var imageFetcher = ALImageFetcher()
    private var imageProcessor = ALImageProcessor()
    
    func performDetection(on assets: PHFetchResult<PHAsset>, jobTypes:[ALVisionProcessorType], options:ALSessionOptinos, completion:@escaping(Result<[ALProcessedAsset],ALVisionError>)-> Void) {
        DispatchQueue.global(qos: options.qos).async {
            let stack = self.assetsManager.getAssetsStacked(assets: assets, options: options)
            self.performOpertion(on:stack, jobTypes:jobTypes, optimized: options.optimzedFaceDetection, completion:completion)
        }

    }
    
    func performDetection(on assets: [PHAsset], jobTypes:[ALVisionProcessorType], options:ALSessionOptinos, completion:@escaping (Result<[ALProcessedAsset],ALVisionError>)-> Void) {
        DispatchQueue.global(qos: options.qos).async {
            let stack = self.assetsManager.getAssetsStacked(assets: assets, options: options)
            self.performOpertion(on:stack, jobTypes:jobTypes, optimized: options.optimzedFaceDetection, completion:completion)
        }
    }
    
    private func performOpertion(on stack:ALStack<[PHAsset]>, jobTypes:[ALVisionProcessorType], optimized:Bool, completion: @escaping (Result<[ALProcessedAsset],ALVisionError>)-> Void) {
            do {
                let objects = try detect(stack: stack, jobTypes: jobTypes, optimized: optimized)
                DispatchQueue.main.async {
                    completion(.success(objects))
                }
            }catch let error {
                DispatchQueue.main.async {
                    completion(.failure(.myError(error)))
                }
            }
    }
    
    func perform<T>(image: UIImage, model:MLModel, completion: @escaping (Result<T,ALVisionError>)-> Void) {
        let asset = ALCustomProcessAsset(identifier: "on.localIdentifier", image: image)
        let process:(ALCustomProcessAsset) throws -> T = imageFilter.custom(model: model)
        do {
            let proccest = try asset |> process
            completion(.success(proccest))
        } catch {
            completion(.failure(.myError(error)))
        }
    }
    
    private func detect(stack:ALStack<[PHAsset]>, jobTypes:[ALVisionProcessorType], optimized:Bool) throws ->  [ALProcessedAsset] {
        if jobTypes.isEmpty { fatalError("jobs cannot be empty") }
        return try stack |> fullPipeProcess(jobTypes: jobTypes, optimized: optimized)
    }
    
    private func fullPipeProcess(jobTypes:[ALVisionProcessorType], optimized:Bool) throws  -> (ALStack<[PHAsset]>) throws -> [ALProcessedAsset] {
        return try imagesProcessor(types: jobTypes, optimized: optimized) |> stackProcessor
    }
    
    typealias ALStackProcessor = (ALStack<[PHAsset]>) throws -> [ALProcessedAsset]

    
    private func stackProcessor(processor:@escaping ALMultiPipelineProcessor) -> ALStackProcessor {
        return processor |> imageProcessor.createStackProcessor
    }
    

    
    private func imagesProcessor(types:[ALVisionProcessorType], optimized:Bool) throws ->  ALMultiPipelineProcessor {
        let filter = try types.reduce(imageFilter.pipeline(for: .copy)) { (result, type) throws -> ALPipeline in
            return try add(filter: result, type: type, optimized: optimized)
        }
        let mappedFillter = filter |>> mapDetectedObject
        return imageProcessor.singleProcessProcessor(preformOn: mappedFillter)
    }
    
    
    // HELPER
    private func add(filter:@escaping ALPipeline, type:ALVisionProcessorType, optimized:Bool) throws -> ALPipeline {
        return try filter |>>  imageFilter.pipeline(for: type, optimized: optimized)
    }
    
    private func mapDetectedObjects(objects:[ALProcessAsset]) -> [ALProcessedAsset] {
        return objects.map (ALProcessedAsset.init)
    }
    
    private func mapDetectedObject(object:ALProcessAsset) -> ALProcessedAsset {
        ALProcessedAsset.init(asset: object)
    }
}

