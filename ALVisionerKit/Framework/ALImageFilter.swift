//
//  ImageAnalyzer.swift
//  ALFacerKit
//
//  Created by amir.lahav on 10/11/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import Vision
import CoreML


typealias ALFilter = (ALProcessAsset) throws -> ALProcessAsset
typealias ALCustomFilter<T> = (ALCustomProcessAsset) throws -> T
class ALImageFilter {
    
    func filter(type:ALVisionProcessorType) -> ALFilter {
        switch type {
        case .faceDetection:
            return detectFaces
        case .objectDetection:
            return tagPhoto
        case .imageQuality:
            return imageQuality
        }
    }
    
    /// Detect bounding box around faces in image
    ///
    /// - Parameter asset: User image
    ///
    /// - Returns: ImageObservation struct include vision bounding rect, original image, and image size
    private func detectFaces(asset:ALProcessAsset) throws -> ALProcessAsset {
        return try autoreleasepool { () -> ALProcessAsset in
            let requestHandler = VNImageRequestHandler(cgImage: (asset.image.cgImage!), options: [:])
            let request = VNDetectFaceRectanglesRequest()
            try requestHandler.perform([request])
            guard let observations = request.results as? [VNFaceObservation] else {
                throw ALFaceClustaringError.facesDetcting
            }
//            guard !observations.isEmpty else {
//                throw FaceClustaringError.emptyObservation
//            }
            return ALProcessAsset(identifier: asset.identifier, image: asset.image, tags: asset.tags, quality: asset.quality, observation: mapBoundignBoxToRects(observation: observations))
        }
    }

    
    private func imageQuality(asset:ALProcessAsset) throws -> ALProcessAsset {
        return try autoreleasepool { () -> ALProcessAsset in
            let requestHandler = VNImageRequestHandler(cgImage: (asset.image.cgImage!), options: [:])
            let request = VNDetectFaceCaptureQualityRequest()
            try requestHandler.perform([request])
//            guard let observation = request.results?.first as? VNFaceObservation else {
//                throw FaceClustaringError.facesDetcting
//            }
            return ALProcessAsset(identifier: asset.identifier, image: asset.image, tags: asset.tags, quality: (request.results?.first as? VNFaceObservation)?.faceCaptureQuality ?? 0, observation: asset.observation)
        }
    }
    
    private func tagPhoto(asset:ALProcessAsset) throws -> ALProcessAsset {
        return try autoreleasepool { () -> ALProcessAsset in
            let requestHandler = VNImageRequestHandler(cgImage: (asset.image.cgImage!), options: [:])
            let request = VNClassifyImageRequest()
            try requestHandler.perform([request])
            var categories: [String] = []

            if let observations = request.results as? [VNClassificationObservation] {
                categories = observations
                    .filter { $0.hasMinimumRecall(0.01, forPrecision: 0.9) }
                    .reduce(into: [String]()) { arr, observation in arr.append(observation.identifier)  }
            }
            
            return ALProcessAsset(identifier: asset.identifier, image: asset.image, tags: categories, quality: asset.quality, observation: asset.observation)
        }
    }
    
    func custom<T>(model:MLModel) -> ALCustomFilter<T> {
        return { asset in
            return try autoreleasepool { () -> T in
                guard let model = try? VNCoreMLModel(for: model) else {
                    throw ALVisionError.unknown
                }
                let request =  VNCoreMLRequest(model:model)
                request.imageCropAndScaleOption = .centerCrop
                let requestHandler = VNImageRequestHandler(cgImage: (asset.image.cgImage!), options: [:])
                try requestHandler.perform([request])
                guard let results = request.results as? T else {
                    throw ALVisionError.unknown
                }
                return results
            }
        }
    }
    
    private func mapBoundignBoxToRects(observation: [VNFaceObservation]) -> [CGRect] {
        observation.map(convertRect)
    }
    
    private func convertRect(face:VNFaceObservation) -> CGRect {
        return face.boundingBox
    }
}
