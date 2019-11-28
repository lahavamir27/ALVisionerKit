//
//  ImageFetcher.swift
//  DisplayLiveSamples
//
//  Created by amir.lahav on 04/11/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import Photos

class ALImageFetcher {
    
    private let imgManager = PHImageManager.default()
    
    private var rquestOptions:PHImageRequestOptions {
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.version = .current
        return options
    }
    
    func getUserImages(asset:PHAsset) -> UIImage?  {

        return autoreleasepool { () -> UIImage? in
            var myImage:UIImage?
                let semaphore = DispatchSemaphore(value: 0)
                
                imgManager.requestImageDataAndOrientation(for: asset, options: rquestOptions) { (data, str, ori, _) in
                        myImage = data?.downSmaple(to: CGSize(width: 500, height: 500), scale: UIScreen.main.scale)
                        semaphore.signal()
                }
                _ = semaphore.wait(wallTimeout: .distantFuture)
            return myImage
        }
    }
    
    func getUserCGImages(asset:PHAsset) -> CGImage?  {

        return autoreleasepool { () -> CGImage? in
            var myImage:CGImage?
                let semaphore = DispatchSemaphore(value: 0)
                
                imgManager.requestImageDataAndOrientation(for: asset, options: rquestOptions) { (data, str, ori, _) in
                        myImage = data?.downSmaple(to: CGSize(width: 500, height: 500), scale: UIScreen.main.scale)
                        semaphore.signal()
                }
                _ = semaphore.wait(wallTimeout: .distantFuture)
            return myImage
        }
    }
}
