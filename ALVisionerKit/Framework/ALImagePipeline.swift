//
//  ImageAnalyzer.swift
//  ALVisionerKit
//
//  Created by amir.lahav on 10/11/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import Vision
import CoreML

typealias ALPipeline = (ALProcessAsset) throws -> ALProcessAsset
typealias ALCustomFilter<T> = (ALCustomProcessAsset) throws -> T

final class ALImagePipeline {
    
    let faceRequest = VNDetectFaceRectanglesRequest()
    let imageQualityRequest = VNDetectFaceCaptureQualityRequest()
    let tagPhotosRequest = VNClassifyImageRequest()
    let featureDetection = VNDetectFaceLandmarksRequest()
    
    func pipeline(for type:ALVisionProcessorType) -> ALPipeline {
        switch type {
        case .faceDetection:
            return detectFaces
        case .objectDetection:
            return tagPhoto
        case .faceCaptureQuality:
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
            try requestHandler.perform([faceRequest])
            guard let observations = faceRequest.results as? [VNFaceObservation] else {
                throw ALFaceClustaringError.facesDetcting
            }
//            guard !observations.isEmpty else {
//                throw FaceClustaringError.emptyObservation
//            }
            return ALProcessAsset(identifier: asset.identifier, image: asset.image, tags: asset.tags, quality: asset.quality, facesRects: mapBoundignBoxToRects(observation: observations))
        }
    }

        private func detectFeaturesFaces(asset:ALProcessAsset) throws -> ALProcessAsset {
            return try autoreleasepool { () -> ALProcessAsset in
                let requestHandler = VNImageRequestHandler(cgImage: (asset.image.cgImage!), options: [:])
                try requestHandler.perform([featureDetection])
                guard let observations = faceRequest.results as? [VNFaceObservation] else {
                    throw ALFaceClustaringError.facesDetcting
                }
    //            guard !observations.isEmpty else {
    //                throw FaceClustaringError.emptyObservation
    //            }
                return ALProcessAsset(identifier: asset.identifier, image: asset.image, tags: asset.tags, quality: asset.quality, facesRects: mapBoundignBoxToRects(observation: observations))
            }
        }
    
    private func imageQuality(asset:ALProcessAsset) throws -> ALProcessAsset {
        return try autoreleasepool { () -> ALProcessAsset in
            let requestHandler = VNImageRequestHandler(cgImage: (asset.image.cgImage!), options: [:])
            try requestHandler.perform([imageQualityRequest])
            guard let observations = imageQualityRequest.results as? [VNFaceObservation] else {
                throw ALFaceClustaringError.facesDetcting
            }
            return ALProcessAsset(identifier: asset.identifier, image: asset.image, tags: asset.tags, quality: observations.first?.faceCaptureQuality ?? 0, facesRects: mapBoundignBoxToRects(observation: observations))
        }
    }
    
    private func tagPhoto(asset:ALProcessAsset) throws -> ALProcessAsset {
        return try autoreleasepool { () -> ALProcessAsset in
            let requestHandler = VNImageRequestHandler(cgImage: (asset.image.cgImage!), options: [:])
            try requestHandler.perform([tagPhotosRequest])
            var categories: [String] = []

            if let observations = tagPhotosRequest.results as? [VNClassificationObservation] {
                categories = observations
                    .filter { $0.hasMinimumRecall(0.01, forPrecision: 0.9) }
                    .reduce(into: [String]()) { arr, observation in arr.append(observation.identifier)  }
            }
            
            return ALProcessAsset(identifier: asset.identifier, image: asset.image, tags: categories, quality: asset.quality, facesRects: asset.facesRects)
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
