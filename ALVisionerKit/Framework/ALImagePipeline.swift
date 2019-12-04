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
    
    let tagPhotosRequest = VNClassifyImageRequest()

    
    func pipeline(for type:ALVisionProcessorType, optimized:Bool = false) throws -> ALPipeline {
        switch type {
        case .faceDetection:
            return try detectFaces(optimized: optimized)
        case .objectDetection:
            return tagPhoto
        case .faceCaptureQuality:
            return try imageQuality(optimized: optimized)
        case .copy:
            return copy
        case .faceFeatures:
            return try detectFaceFeatures(optimized: optimized)
        case .textDetecting:
            return textDetecting
        }
    }
    
    private func detectFaces(optimized:Bool) throws -> ALPipeline {
        return { asset in
            let faceRequest = VNDetectFaceRectanglesRequest()
            let requestHandler = VNImageRequestHandler(cgImage: (asset.image.cgImage!), options: [:])
            if !asset.faces.isEmpty {
                // bounding box already found
                return asset
            }
            try requestHandler.perform([faceRequest])
            guard let observations = faceRequest.results as? [VNFaceObservation] else {
                throw ALFaceClustaringError.facesDetcting
            }
            if optimized {
                guard !observations.isEmpty else {
                    throw ALFaceClustaringError.emptyObservation
                }
            }
            return ALProcessAsset(identifier: asset.identifier, image: asset.image, tags: asset.tags, faces: self.mapVNFaceObservationsToFaces(faceObservations: observations), texts: asset.texts)
        }
    }
    
    
    func detectFaceFeatures(optimized:Bool) throws -> ALPipeline {
        return { asset in
            let featureDetection = VNDetectFaceLandmarksRequest()
            if !asset.faces.isEmpty {
                let observation = self.mapFacesToVNFaceObservation(faces: asset.faces)
                featureDetection.inputFaceObservations = observation
            }
            let requestHandler = VNImageRequestHandler(cgImage: (asset.image.cgImage!), options: [:])
            
            try requestHandler.perform([featureDetection])
            guard let observations = featureDetection.results as? [VNFaceObservation] else {
                throw ALFaceClustaringError.facesDetcting
            }
            if optimized {
                guard !observations.isEmpty else {
                    throw ALFaceClustaringError.emptyObservation
                }
            }
            if asset.faces.isEmpty {
                return asset.duplicate(faces: self.mapVNFaceObservationsToFaces(faceObservations: observations))
            }else{
                let zippedObservations = Array(zip(asset.faces, observations))
                return asset.duplicate(faces:self.mapNewVNFaceObservationsToFaces(faceObservations: zippedObservations))
            }
        }
    }
    
    func imageQuality(optimized:Bool) throws -> ALPipeline {
        return { asset in
            let imageQualityRequest = VNDetectFaceCaptureQualityRequest()
            if !asset.faces.isEmpty {
                let observation = self.mapFacesToVNFaceObservation(faces: asset.faces)
                imageQualityRequest.inputFaceObservations = observation
            }
            let requestHandler = VNImageRequestHandler(cgImage: (asset.image.cgImage!), options: [:])
            try requestHandler.perform([imageQualityRequest])
            guard let observations = imageQualityRequest.results as? [VNFaceObservation] else {
                throw ALFaceClustaringError.facesDetcting
            }
            if optimized {
                guard !observations.isEmpty else {
                    throw ALFaceClustaringError.emptyObservation
                }
            }
            if asset.faces.isEmpty {
                return asset.duplicate(faces: self.mapVNFaceObservationsToFaces(faceObservations: observations))
            }else{
                let zippedObservations = Array(zip(asset.faces, observations))
                return asset.duplicate(faces:self.mapNewVNFaceObservationsToFaces(faceObservations: zippedObservations))
            }
        }
    }
    
    private func tagPhoto(asset:ALProcessAsset) throws -> ALProcessAsset {
            let requestHandler = VNImageRequestHandler(cgImage: (asset.image.cgImage!), options: [:])
            try requestHandler.perform([tagPhotosRequest])
            var categories: [String] = []
            if let observations = tagPhotosRequest.results as? [VNClassificationObservation] {
                categories = observations
                    .filter { $0.hasMinimumRecall(0.01, forPrecision: 0.9) }
                    .reduce(into: [String]()) { arr, observation in arr.append(observation.identifier)  }
            }
        return ALProcessAsset(identifier: asset.identifier, image: asset.image, tags: categories, faces: asset.faces, texts: asset.texts)
    }
    
    func textDetecting(asset:ALProcessAsset) throws -> ALProcessAsset {
        let requestHandler = VNImageRequestHandler(cgImage: (asset.image.cgImage!), options: [:])
        let textDetectingRequest = VNRecognizeTextRequest()
        try requestHandler.perform([textDetectingRequest])
        guard let observations = textDetectingRequest.results as? [VNRecognizedTextObservation] else {
            throw ALFaceClustaringError.emptyObservation
        }
        return asset.duplicate(texts: mapObservationToTexts(observations: observations))
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
    
    
    // Helper
    private func copy(asset:ALProcessAsset) throws -> ALProcessAsset {
        return asset
    }
    
    private func mapBoundignBoxToRects(observation: [VNFaceObservation]) -> [CGRect] {
        observation.map(convertRect)
    }
    
    private func mapFacesToVNFaceObservation(faces:[ALFace]) -> [VNFaceObservation] {
        faces.map(facesToVNFaceObservation)
    }
    
    func mapVNFaceObservationsToFaces(faceObservations:[VNFaceObservation]) -> [ALFace] {
        faceObservations.map(vNFaceObservationToFace)
    }
    
    func vNFaceObservationToFace(faceObservation:VNFaceObservation) -> ALFace {
        ALFace(faceObservation: faceObservation)
    }
    
    func mapNewVNFaceObservationsToFaces(faceObservations:[(ALFace,VNFaceObservation)]) -> [ALFace] {
        faceObservations.map(vNFaceObservationToFace)
    }
    
    func vNFaceObservationToFace(face:ALFace, faceObservation:VNFaceObservation) -> ALFace {
        face.duplicate(faceQuality: faceObservation.faceCaptureQuality, rect: faceObservation.boundingBox, faceLandmarkRegions: faceObservation)
    }
    
    func mapObservationToTexts(observations:[VNRecognizedTextObservation]) -> [ALText] {
        observations.compactMap(observationToText)
    }
    
    func observationToText(observation:VNRecognizedTextObservation) -> ALText? {
        guard let bestCandidate = observation.topCandidates(5).first else {
            print("No candidate")
            return nil
        }
        if bestCandidate.confidence > 0.8 {
            return ALText(rect: observation.boundingBox, text: bestCandidate.string)
        }else{
            return nil
        }
    }
    
    private func convertRect(face:VNFaceObservation) -> CGRect {
        return face.boundingBox
    }
    
    private func facesToVNFaceObservation(face:ALFace) -> VNFaceObservation {
        return VNFaceObservation(boundingBox: face.rect)
    }
}
