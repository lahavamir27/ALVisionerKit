//
//  FaceClustaringError.swift
//  ALVisionerKit
//
//  Created by amir.lahav on 26/11/2019.
//

import Foundation

enum ALFaceClustaringError:Error {
    case fetchImages
    case facesDetcting
    case cgImageNotFound
    case emptyObservation
    var description:String {
        switch self {
        case .fetchImages:
            return "Cannot fetch this image"
        case .facesDetcting:
            return "Unable to detect faces"
        case .cgImageNotFound:
            return "CGImage not found"
        case .emptyObservation:
            return "No faces found"
        }
    }
}
