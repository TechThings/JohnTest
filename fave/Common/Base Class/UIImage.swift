//
//  UIImage.swift
//  FAVE
//
//  Created by Thanh KFit on 8/19/16.
//  Copyright © 2016 kfit. All rights reserved.
//

extension UIImage {
    /// Resizes an image instance.
    ///
    /// - parameter size: The new size of the image.
    /// - returns: A new resized image instance.
    func resize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.drawInRect(CGRect(origin: CGPoint.zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = newImage {
            return image
        }
        return self
    }
}
