//
//  AssetManager.swift
//  DisplayLiveSamples
//
//  Created by amir.lahav on 05/11/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import Photos

public final class ALAssetManager {
    
    public init() {}
    
    private lazy var fetchOptions:PHFetchOptions = {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }()
    
    func getMyAssets(options:ClusterMangerOptions) -> ALStack<[PHAsset]> {
        return chunk(assets: getUserAssets(), usersAssets: options.numberOfUserAssetsToProcess, chunkSize: options.chunckSize) |> stackAssets
    }
    
    func getAssetsStacked(assets:[PHAsset], options:ClusterMangerOptions = ClusterMangerOptions()) -> ALStack<[PHAsset]> {
        return chunk(assets: assets, usersAssets: options.numberOfUserAssetsToProcess, chunkSize: options.chunckSize) |> stackAssets
    }
    
    func getAssetsStacked(assets:PHFetchResult<PHAsset>, options:ClusterMangerOptions = ClusterMangerOptions()) -> ALStack<[PHAsset]> {
        let parseAsset = assetParser(asstes: assets)
        return chunk(assets: parseAsset, usersAssets: options.numberOfUserAssetsToProcess, chunkSize: options.chunckSize) |> stackAssets
    }

    public func getUserPhotos(with options:ALFetchOptions, fetchOptions:ALFetchAssetsOptions = ALFetchAssetsOptions()) -> [PHAsset] {
        let filter = applyFilter(fetchOptions: fetchOptions)
        return getAssetsBy(options: options, fetchOptions: fetchOptions) |> assetParser |> filter
    }
    
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
        return assetParser(asstes:PHAsset.fetchAssets(with: .image, options: fetchOptions))
    }
    
    private func assetParser(asstes:PHFetchResult<PHAsset>) -> [PHAsset] {
        var assets:[PHAsset] = []
        asstes.enumerateObjects { (asset, _, _) in
            if !(asset.mediaSubtypes == .photoScreenshot) {
                assets.append(asset)
            }
        }
        return assets
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
    
    private func chunk(assets:[PHAsset], usersAssets:Int, chunkSize:Int) -> [[PHAsset]] {
        assets.prefix(usersAssets).chunked(into: chunkSize)
    }
    
    private func enumarateAssets(assets:[PHAsset]) -> [UIImage] {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
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
    
    private func enumarateAssets(assets:[PHAsset]) -> [CGImage] {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
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
    
    func mapAssets(_ assets:[PHAsset]) -> [ALProcessAsset] {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        var preProcessPHAssets:[ALProcessAsset] = []
        let blocks = assets.map { (asset) in
            return BlockOperation {
                let imageFetcher = ALImageFetcher()
                if let image = imageFetcher.getUserImages(asset: asset) {
                    let assettt = ALProcessAsset(identifier: asset.localIdentifier, image: image, tags: [], quality: 0, observation: [])
                    preProcessPHAssets.append(assettt)
                }
            }
        }
        queue.addOperations(blocks, waitUntilFinished: true)
        return preProcessPHAssets
    }
    
    public enum ALFetchOptions {
        case allAssets
        case albumName(String)
        case assetCollection(PHAssetCollection)
        case mediaType(PHAssetMediaType)
        case identifiers([String])
    }
    
}


public class ALFetchAssetsOptions {
    public var numberOfPhotos:Int = Int.max
    public var dateAscending:Bool = false
    public init() {}
}


