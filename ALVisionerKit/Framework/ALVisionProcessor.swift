//
//  ALVisionProcessor.swift
//  ALFacerKit
//
//  Created by amir.lahav on 16/11/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import Photos
import CoreML

class ALVisionProcessor {
    
    private var imageFilter = ALImageFilter()
    private var assetsManager = ALAssetManager()
    private var imageFetcher = ALImageFetcher()
    
    func performDetection(on: PHFetchResult<PHAsset>, jobTypes:[ALVisionProcessorType], completion:@escaping(Result<[ProcessedALAsset],ALVisionError>)-> Void) {
        let stack = assetsManager.getAssetsStacked(assets: on)
        handleStack(stack:stack, jobTypes:jobTypes, completion:completion)
    }
    
    func performDetection(on: [PHAsset], jobTypes:[ALVisionProcessorType], completion:@escaping (Result<[ProcessedALAsset],ALVisionError>)-> Void) {
        let stack = assetsManager.getAssetsStacked(assets: on)
        handleStack(stack:stack, jobTypes:jobTypes, completion:completion)
    }
    
    private func handleStack(stack:ALStack<[PHAsset]>, jobTypes:[ALVisionProcessorType], completion: @escaping (Result<[ProcessedALAsset],ALVisionError>)-> Void) {
        DispatchQueue.global().async {
            do {
                let objects = try self.detect(stack: stack, jobTypes: jobTypes) |> self.mapDetectedObjects
                DispatchQueue.main.async {
                    completion(.success(objects))
                }
            }catch let error {
                DispatchQueue.main.async {
                    completion(.failure(.myError(error)))
                }
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
    
    private func mapDetectedObjects(objects:[ALProcessAsset]) -> [ProcessedALAsset] {
        return objects.map (ProcessedALAsset.init)
    }
    
    private func detect(stack:ALStack<[PHAsset]>, jobTypes:[ALVisionProcessorType]) throws ->  [ALProcessAsset] {
        if jobTypes.isEmpty { fatalError("jobs cannot be empty") }
        return try stack |> fullPipeProcess(jobTypes: jobTypes)
    }
    
    private func fullPipeProcess(jobTypes:[ALVisionProcessorType]) -> (ALStack<[PHAsset]>) throws -> [ALProcessAsset] {
        return imagesProcessor(types: jobTypes) |> stackProcessor
    }
    
    private func stackProcessor(processor:@escaping processor) -> stackProcessor {
        return processor |> ALImageProcessor.createStackProcessor
    }
    
    private func imagesProcessor(types:[ALVisionProcessorType]) ->  processor {
        let filter = types.reduce(imageFilter.filter(type: types[0])) { (result, type) -> ALFilter in
            return add(filter: result, type: type)
        }
        return ALImageProcessor.singleProcessProcessor(preformOn: filter)
    }
    
    private func add(filter:@escaping ALFilter, type:ALVisionProcessorType) -> ALFilter {
        return filter |>> imageFilter.filter(type: type)
    }
}

extension PHFetchResult where ObjectType == PHAsset {
    var objects: [ObjectType] {
        var _objects: [ObjectType] = []
        enumerateObjects { (object, _, _) in
            _objects.append(object)
        }
        return _objects
    }
} 
