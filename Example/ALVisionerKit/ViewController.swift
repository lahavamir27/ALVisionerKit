//
//  ViewController.swift
//  ALVisionerKit
//
//  Created by smartytoe on 11/27/2019.
//  Copyright (c) 2019 smartytoe. All rights reserved.
//

import UIKit
import ALVisionerKit
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask user permission
        ALPhotosAuthorization.checkPhotoLibraryPermission { (result) in
            switch result {
            case .success(_):
                // User Approve Permission
                
                // fetch user assets from galley
                let fetchOptions = ALFetchAssetsOptions()
                fetchOptions.numberOfPhotos = 5
                let assetsManager = ALAssetManager()
                let assets = assetsManager.getUserPhotos(with: .allAssets, fetchOptions: fetchOptions)
                
                
                let session = ALVisionSession()
                let sessionOptions = ALSessionOptinos()
                sessionOptions.optimzedFaceDetection = false
                // detect objects, faces rects and face quality (0-1)
                let startDate = Date()
                session.detect(in: assets, with: [.textDetecting],options: sessionOptions) { (result) in
                    switch result {
                    case .success(let objs):
                        objs.printObjects()
                        print("finish round in: \(startDate.timeIntervalSinceNow * -1) sconed")
                        // do something with deteted assets
                        break
                    case .failure(_):break
                    }
                }
            case .failure(_): break
                // User denied Permission
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

