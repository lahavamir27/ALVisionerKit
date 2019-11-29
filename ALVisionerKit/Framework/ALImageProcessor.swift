//
//  ALImageProcessor.swift
//  ALVisionerKit
//
//  Created by amir.lahav on 16/11/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import Photos

typealias ALMultiPipelineProcessor = ([ALProcessAsset]) throws -> [ALProcessedAsset]
typealias ALStackProcessor = (ALStack<[PHAsset]>) throws -> [ALProcessedAsset]

class ALImageProcessor {
    
    private let assetMangager = ALAssetManager()
    
    /// Create opertion queue to process all assets.
    /// - Return analized objects
    /// - Parameter images: User Images
    func imageProcessor<T>(images:[ALProcessAsset], preformOn:@escaping (ALProcessAsset) throws -> [T]) ->  [T] {
        let queue = OperationQueue()
        var objects:[T] = []
        let blocks = images.map { (image) -> BlockOperation in
            return BlockOperation {
                do {
                    let face = try preformOn(image)
                    objects.append(contentsOf: face)
                }catch {
                    //TODO: handle error
                }
            }
        }
        queue.addOperations(blocks, waitUntilFinished: true)
        return objects
    }
    
    
    /// Create opertion queue to process all assets.
    /// - Return analized objects
    /// - Parameter images: User Images
    func singleImageProcessor<T>(images:[ALProcessAsset], preformOn:@escaping (ALProcessAsset) throws -> T) ->  [T] {
        let queue = OperationQueue()
        var objects:[T] = []
        let blocks = images.map { (image) -> BlockOperation in
            return BlockOperation {
                do {
                    let object = try preformOn(image)
                    objects.append(object)
                }catch {
                    //TODO: handle error
                }
            }
        }
        queue.addOperations(blocks, waitUntilFinished: true)
        return objects
    }
    
    /// Create opertion queue to process all assets.
    /// - Return analized objects
    /// - Parameter images: User Images
    func singleProcessProcessor(preformOn:@escaping (ALProcessAsset) throws -> ALProcessedAsset) ->  ALMultiPipelineProcessor {
        return { (assets) in
            let queue = OperationQueue()
            var objects:[ALProcessedAsset] = []
            let blocks = assets.map { (image) -> BlockOperation in
                return BlockOperation {
                    do {
                        let object = try preformOn(image)
                        objects.append(object)
                    }catch {
                        //TODO: handle error
                    }
                }
            }
            queue.addOperations(blocks, waitUntilFinished: true)
            return objects
        }
    }
    
    
    func stackProcessor<T>(_ stack:ALStack<[PHAsset]>, processor:@escaping ([ALProcessAsset]) throws -> [T]) -> [T] {
        var stack = stack
        var objects:[T] = []
        while !stack.isEmpty() {
            let startDate = Date()
            if let asstes = stack.pop() {
                do {
                    let asssts = assetMangager.mapAssets(asstes)
                    let detectObjects = try asssts |> processor
                    objects.append(contentsOf: detectObjects)
                }catch {   }
            }
            print("finish round in: \(startDate.timeIntervalSinceNow * -1) sconed")
        }
        return objects
    }
    
    func createStackProcessor(processor:@escaping ALMultiPipelineProcessor) -> ALStackProcessor {
        return { (stack) in
            var stack = stack
            var objects:[ALProcessedAsset] = []
            while !stack.isEmpty() && objects.count < 100 {
                let startDate = Date()
                autoreleasepool{
                    if let asstes = stack.pop() {
                        do {
                            let asssts = self.assetMangager.mapAssets(asstes)
                            let detectObjects = try  asssts |> processor
                            objects.append(contentsOf: detectObjects)
                        }catch {   }
                    }
                }
                print("finish batch process in: \(startDate.timeIntervalSinceNow * -1) sconed")
            }
            return objects
        }
    }

}
