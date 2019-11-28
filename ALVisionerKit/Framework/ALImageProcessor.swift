//
//  ALImageProcessor.swift
//  ALFacerKit
//
//  Created by amir.lahav on 16/11/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import Photos

typealias processor = ([ALProcessAsset]) throws -> [ALProcessAsset]
typealias stackProcessor = (ALStack<[PHAsset]>) throws -> [ALProcessAsset]

class ALImageProcessor {
    
    private static let assetMangager = ALAssetManager()
    
    /// Create opertion queue to process all assets.
    /// - Return analized objects
    /// - Parameter images: User Images
    static func imageProcessor<T>(images:[ALProcessAsset], preformOn:@escaping (ALProcessAsset) throws -> [T]) ->  [T] {
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
    static func singleImageProcessor<T>(images:[ALProcessAsset], preformOn:@escaping (ALProcessAsset) throws -> T) ->  [T] {
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
    static func singleProcessProcessor(preformOn:@escaping (ALProcessAsset) throws -> ALProcessAsset) ->  processor {
        return { (assets) in
            let queue = OperationQueue()
            var objects:[ALProcessAsset] = []
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
    
    
    static func stackProcessor<T>(_ stack:ALStack<[PHAsset]>, processor:@escaping ([ALProcessAsset]) throws -> [T]) -> [T] {
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
    
    static func createStackProcessor(processor:@escaping processor) -> stackProcessor {
        return { (stack) in
            var stack = stack
            var objects:[ALProcessAsset] = []
            while !stack.isEmpty() {
                if let asstes = stack.pop() {
                    do {
                        let asssts = assetMangager.mapAssets(asstes)
                        let detectObjects = try  asssts  |> processor 
                        objects.append(contentsOf: detectObjects)
                    }catch {   }
                }
            }
            return objects
        }
        

    }

}