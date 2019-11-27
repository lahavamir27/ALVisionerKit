//
//  UIImageExtantion.swift
//  ALVisionerKit
//
//  Created by amir.lahav on 27/11/2019.
//

import Foundation
import UIKit

extension UIImageView {
    public func circleImageView(borderColor: UIColor, borderWidth: CGFloat){
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = self.layer.frame.size.width / 2
        self.clipsToBounds = true
    }
}
