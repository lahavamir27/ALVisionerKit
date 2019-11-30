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
    
    func performDetection(on: PHFetchResult<PHAsset>, jobTypes:[ALVisionProcessorType], completion:@escaping(Result<[ALProcessedAsset],ALVisionError>)-> Void) {
        let stack = assetsManager.getAssetsStacked(assets: on)
        performOpertion(on:stack, jobTypes:jobTypes, completion:completion)
    }
    
    func performDetection(on: [PHAsset], jobTypes:[ALVisionProcessorType], completion:@escaping (Result<[ALProcessedAsset],ALVisionError>)-> Void) {
        let stack = assetsManager.getAssetsStacked(assets: on)
        performOpertion(on:stack, jobTypes:jobTypes, completion:completion)
    }
    
    private func performOpertion(on stack:ALStack<[PHAsset]>, jobTypes:[ALVisionProcessorType], completion: @escaping (Result<[ALProcessedAsset],ALVisionError>)-> Void) {
            do {
                let objects = try detect(stack: stack, jobTypes: jobTypes)
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
    
    private func detect(stack:ALStack<[PHAsset]>, jobTypes:[ALVisionProcessorType]) throws ->  [ALProcessedAsset] {
        if jobTypes.isEmpty { fatalError("jobs cannot be empty") }
        return try stack |> fullPipeProcess(jobTypes: jobTypes)
    }
    
    private func fullPipeProcess(jobTypes:[ALVisionProcessorType]) -> (ALStack<[PHAsset]>) throws -> [ALProcessedAsset] {
        return imagesProcessor(types: jobTypes) |> stackProcessor
    }
    
    private func stackProcessor(processor:@escaping ALMultiPipelineProcessor) -> ALStackProcessor {
        return processor |> imageProcessor.createStackProcessor
    }
    
    private func imagesProcessor(types:[ALVisionProcessorType]) ->  ALMultiPipelineProcessor {
        let filter = types.reduce(imageFilter.pipeline(for: types[0])) { (result, type) -> ALPipeline in
            return add(filter: result, type: type)
        }
        let mappedFillter = filter |>> mapDetectedObject
        return imageProcessor.singleProcessProcessor(preformOn: mappedFillter)
    }
    
    
    // HELPER
    
    private func add(filter:@escaping ALPipeline, type:ALVisionProcessorType) -> ALPipeline {
        return filter |>> imageFilter.pipeline(for: type)
    }
    
    private func mapDetectedObjects(objects:[ALProcessAsset]) -> [ALProcessedAsset] {
        return objects.map (ALProcessedAsset.init)
    }
    
    private func mapDetectedObject(object:ALProcessAsset) -> ALProcessedAsset {
        ALProcessedAsset.init(asset: object)
    }
}

