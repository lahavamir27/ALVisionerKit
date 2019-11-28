//
//  ALPhotosAuthorization.swift
//  ALFacerKit
//
//  Created by amir.lahav on 23/11/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation
import Photos

public final class ALPhotosAuthorization {
    public static func checkPhotoLibraryPermission(completion:@escaping (Result<Bool,ALPhotosAuthorizationError>)->()) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized: completion(Result.success(true))
        //handle authorized status
        case .denied, .restricted : completion(Result.failure(ALPhotosAuthorizationError.denied))
        //handle denied status
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized: completion(Result.success(true))
                    // as above
                    case .denied, .restricted: completion(Result.failure(ALPhotosAuthorizationError.denied))
                    
                    // as above
                    case .notDetermined: completion(Result.failure(ALPhotosAuthorizationError.notDetermined))
                        // won't happen but still
                    @unknown default:
                        fatalError("user access approval is not determined")
                    }
                }
            }
        @unknown default:
            fatalError("user access approval is not determined")
        }
    }
}
