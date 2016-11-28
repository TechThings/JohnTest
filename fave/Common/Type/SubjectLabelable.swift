//
//  SubjectLabelable.swift
//  FAVE
//
//  Created by Nazih Shoura on 11/27/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

protocol SubjectLabelable {
    static var subjectLabel: String { get }
    var subjectLabel: String { get }
}

extension SubjectLabelable {
    static var subjectLabel: String { return String(Self.self) }
    var subjectLabel: String { return String(Self) }
}

extension View: SubjectLabelable {}
extension ViewController: SubjectLabelable {}
extension NSObject: SubjectLabelable {}
extension TabBarController: SubjectLabelable {}
extension NavigationController: SubjectLabelable {}
