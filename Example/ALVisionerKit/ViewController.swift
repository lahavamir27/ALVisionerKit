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
        ALPhotosAuthorization.checkPhotoLibraryPermission { (result) in
            switch result {
            case .success(_):
                // User Approve Permission
                let fetchOptions = ALFetchAssetsOptions()
                fetchOptions.numberOfPhotos = 20
                let assetsManager = ALAssetManager()
                let assets = assetsManager.getUserPhotos(with: .allAssets, fetchOptions: fetchOptions)
                ALVisionManager.detect(in: assets, with: [.faceDetection,.imageQuality,.objectDetection]) { (result) in
                    switch result {
                    case .success(let objs):
                        objs.printObjects()
                        // do something with detet asstes
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

