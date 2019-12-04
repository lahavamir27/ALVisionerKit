//
//  AssetManager.swift
//  DisplayLiveSamples
//
//  Created by amir.lahav on 05/11/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import Photos
import UIKit

public final class ALAssetManager {
    
    public init() {}
    
    private lazy var fetchOptions:PHFetchOptions = {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }()
    
    // Public API
    
    public func getUserPhotos(with options:ALFetchOptions, fetchOptions:ALFetchAssetsOptions = ALFetchAssetsOptions()) -> [PHAsset] {
        let filter = applyFilter(fetchOptions: fetchOptions)
        let objects = getAssetsBy(options: options, fetchOptions: fetchOptions).objects
        return objects |> filter
    }
    
    // Internal API
    
    func getAssetsStacked(assets:[PHAsset], options:ALSessionOptinos) -> ALStack<[PHAsset]> {
        return chunk(assets: assets, chunkSize: options.parallelProcessQuantity) |> stackAssets
    }
    
    func getAssetsStacked(assets:PHFetchResult<PHAsset>, options:ALSessionOptinos) -> ALStack<[PHAsset]> {
        let parseAsset = assets.objects
        return chunk(assets: parseAsset, chunkSize: options.parallelProcessQuantity) |> stackAssets
    }
    
    func mapAssetsToImages(_ assets:[PHAsset]) -> [ALProcessAsset] {
        let queue = OperationQueue()
        var preProcessPHAssets:[ALProcessAsset] = []
        let blocks = assets.map { (asset) in
            return BlockOperation {
                let imageFetcher = ALImageFetcher()
                if let image = imageFetcher.getUserImages(asset: asset) {
                    let assettt = ALProcessAsset(identifier: asset.localIdentifier, image: image, tags: [],faces: [], texts: [])
                    preProcessPHAssets.append(assettt)
                }
            }
        }
        queue.addOperations(blocks, waitUntilFinished: true)
        return preProcessPHAssets
    }

    // Private API
    
    private func getAssetsBy(options:ALFetchOptions, fetchOptions:ALFetchAssetsOptions) -> PHFetchResult<PHAsset> {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: fetchOptions.dateAscending)]
        switch options {
        case .allAssets:
            return PHAsset.fetchAssets(with: fetchOption)
        case .albumName(let albumName):
            fetchOption.predicate = NSPredicate(format: "title = %@", albumName)
            let fetchResult: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOption)
            if fetchResult.firstObject == nil { fatalError("no album name:\(albumName) found)") }
            return PHAsset.fetchAssets(in: fetchResult.firstObject!, options: fetchOption)
        case .assetCollection(let assetsCollection):
            return PHAsset.fetchAssets(in: assetsCollection, options: fetchOption)
        case .mediaType(_):
            let fetchResult: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOption)
            if fetchResult.firstObject == nil { fatalError("no album found)") }
            return PHAsset.fetchAssets(in: fetchResult.firstObject!, options: fetchOption)
        case .identifiers(let identifiers):
            return PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: fetchOption)
        }
    }
    
    private func getUserAssets() -> [PHAsset] {
        PHAsset.fetchAssets(with: .image, options: fetchOptions).objects
    }
    
    private func applyFilter(fetchOptions:ALFetchAssetsOptions) -> ([PHAsset]) -> [PHAsset] {
        return { (assets) in
            return Array(assets.prefix(fetchOptions.numberOfPhotos))
        }
    }
    
    private func stackAssets(chuncks: [[PHAsset]]) -> ALStack<[PHAsset]> {
        var stack = ALStack<[PHAsset]>()
        chuncks.forEach({stack.push($0)})
        return stack
    }
    
    private func chunk(assets:[PHAsset], chunkSize:Int) -> [[PHAsset]] {
        assets.chunked(into: chunkSize)
    }
    
    private func mapAssetsToImages(assets:[PHAsset]) -> [UIImage] {
        let queue = OperationQueue()
        var images:[UIImage] = []
        let blocks = assets.map { (asset) in
            return BlockOperation {
                let imageFetcher = ALImageFetcher()
                if let image = imageFetcher.getUserImages(asset: asset) {
                    images.append(image)
                }
            }
        }
        queue.addOperations(blocks, waitUntilFinished: true)
        return images
    }
    
    private func mapAssetsToImages(assets:[PHAsset]) -> [CGImage] {
        let queue = OperationQueue()
        var images:[CGImage] = []
        let blocks = assets.map { (asset) in
            return BlockOperation {
                let imageFetcher = ALImageFetcher()
                if let image = imageFetcher.getUserCGImages(asset: asset) {
                    images.append(image)
                }
            }
        }
        queue.addOperations(blocks, waitUntilFinished: true)
        return images
    }
}


