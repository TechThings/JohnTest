//
//  UIFont+Extensions.swift
//
//  Created by Jonathan Landon on 4/15/15.
//
// The MIT License (MIT)
//
// Copyright (c) 2014-2016 Oven Bits, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

extension UIFont {
    /**
    Registers a font for use in the app

    - parameter name: The name of the font family.
    - parameter fileExtension: The extension of the font file.
    - parameter bundle: The bundle in which the font file is located.
    */
    public static func registerFont(name name: String, fileExtension: String, inBundle bundle: NSBundle) {
        guard let path = bundle.pathForResource(name, ofType: fileExtension), fontData = NSData(contentsOfFile: path) else {
            print("Error registering font")
            return
        }
        
        guard let provider = CGDataProviderCreateWithCFData(fontData as CFDataRef) else { return }
        
        let font = CGFontCreateWithDataProvider(provider)
        
        var error: Unmanaged<CFErrorRef>?
        guard !CTFontManagerRegisterGraphicsFont(font, &error) else {
            error?.release()
            return
        }
        
        if let errorRef = error?.takeRetainedValue() {
            let errorDescription = CFErrorCopyDescription(errorRef)
            print("Failed to load font: \(errorDescription)")
        }

        error?.release()
    }
}
