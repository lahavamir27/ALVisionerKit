//
//  ALFace.swift
//  ALVisionerKit
//
//  Created by amir.lahav on 30/11/2019.
//

import Foundation
import Vision

struct ALFace {
    
    init(face:ALFace, faceObservation:VNFaceObservation) {
        if face.faceLandmarkRegions == nil {
            self.faceLandmarkRegions = ALFaceLandmarkRegion(landmarks: faceObservation.landmarks)
        }else {
            self.faceLandmarkRegions = face.faceLandmarkRegions
        }
        self.faceQuality = face.faceQuality > 0 ? face.faceQuality : faceObservation.faceCaptureQuality ?? 0
        self.rect = faceObservation.boundingBox
    }
    
    init(faceObservation:VNFaceObservation) {
        self.faceLandmarkRegions = ALFaceLandmarkRegion(landmarks: faceObservation.landmarks)
        self.rect = faceObservation.boundingBox
        self.faceQuality = faceQuality > 0 ? faceQuality : faceObservation.faceCaptureQuality ?? 0
    }
    var faceQuality:Float = 0
    var rect:CGRect
    var faceLandmarkRegions:ALFaceLandmarkRegion?
    init(faceQuality:Float,  rect:CGRect, faceLandmarkRegions:ALFaceLandmarkRegion?) {
        self.faceQuality = faceQuality
        self.rect = rect
        self.faceLandmarkRegions = faceLandmarkRegions
    }
    
    
    func duplicate(faceQuality:Float? = nil, rect:CGRect? = nil, faceLandmarkRegions:VNFaceObservation? = nil) -> ALFace {
        ALFace(faceQuality: faceQuality ?? self.faceQuality, rect: rect ?? self.rect, faceLandmarkRegions: faceLandmarkRegions?.landmarks != nil ? ALFaceLandmarkRegion(landmarks: faceLandmarkRegions?.landmarks) : self.faceLandmarkRegions)
    }

}

struct ALFaceLandmarkRegion {
    
    init(landmarks:VNFaceLandmarks2D?) {
        if let faceContour = landmarks?.faceContour {
            self.faceContour = ALFaceLandmarkRegion2D(faceLandmarkRegion2D: faceContour)
        }
        if let leftEye = landmarks?.leftEye {
            self.leftEye = ALFaceLandmarkRegion2D(faceLandmarkRegion2D: leftEye)
        }
        if let rightEye = landmarks?.rightEye {
            self.rightEye = ALFaceLandmarkRegion2D(faceLandmarkRegion2D: rightEye)
        }
        if let leftEyebrow = landmarks?.leftEyebrow {
            self.leftEyebrow = ALFaceLandmarkRegion2D(faceLandmarkRegion2D: leftEyebrow)
        }
        if let rightEyebrow = landmarks?.rightEyebrow {
            self.rightEyebrow = ALFaceLandmarkRegion2D(faceLandmarkRegion2D: rightEyebrow)
        }
        if let nose = landmarks?.nose {
            self.nose = ALFaceLandmarkRegion2D(faceLandmarkRegion2D: nose)
        }
        if let noseCrest = landmarks?.noseCrest {
            self.noseCrest = ALFaceLandmarkRegion2D(faceLandmarkRegion2D: noseCrest)
        }
        if let medianLine = landmarks?.medianLine {
            self.medianLine = ALFaceLandmarkRegion2D(faceLandmarkRegion2D: medianLine)
        }
        if let outerLips = landmarks?.outerLips {
            self.outerLips = ALFaceLandmarkRegion2D(faceLandmarkRegion2D: outerLips)
        }
        if let innerLips = landmarks?.innerLips {
            self.innerLips = ALFaceLandmarkRegion2D(faceLandmarkRegion2D: innerLips)
        }
        if let leftPupil = landmarks?.leftPupil {
            self.leftPupil = ALFaceLandmarkRegion2D(faceLandmarkRegion2D: leftPupil)
        }
        if let rightPupil = landmarks?.rightPupil {
            self.rightPupil = ALFaceLandmarkRegion2D(faceLandmarkRegion2D: rightPupil)
        }
        
    }
    
    var faceContour: ALFaceLandmarkRegion2D?
    var leftEye: ALFaceLandmarkRegion2D?
    var rightEye: ALFaceLandmarkRegion2D?
    var leftEyebrow: ALFaceLandmarkRegion2D?
    var rightEyebrow: ALFaceLandmarkRegion2D?
    var nose: ALFaceLandmarkRegion2D?
    var noseCrest: ALFaceLandmarkRegion2D?
    var medianLine: ALFaceLandmarkRegion2D?
    var outerLips: ALFaceLandmarkRegion2D?
    var innerLips: ALFaceLandmarkRegion2D?
    var leftPupil: ALFaceLandmarkRegion2D?
    var rightPupil: ALFaceLandmarkRegion2D?
}

struct ALFaceLandmarkRegion2D {
    var normalizedPoint:[CGPoint] = []
    init(faceLandmarkRegion2D:VNFaceLandmarkRegion2D) {
        self.normalizedPoint =  faceLandmarkRegion2D.normalizedPoints
    }
}
