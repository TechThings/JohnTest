//
//  UIBarButtonItem.swift
//  FAVE
//
//  Created by Nazih Shoura on 9/28/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import Foundation

final class BlockBarButtonItem: UIBarButtonItem {

    private var actionHandler: ((Void) -> Void)!

    convenience init(title: String? = nil, style: UIBarButtonItemStyle, actionHandler: ((Void) -> Void)) {
        self.init(title: title, style: style, target: nil, action:  nil)
        self.actionHandler = actionHandler
        self.target = self
        self.action = #selector(barButtonItemPressed(_:))
    }

    convenience init(barButtonSystemItem: UIBarButtonSystemItem, actionHandler: ((Void) -> Void)) {
        self.init(barButtonSystemItem: barButtonSystemItem, target: nil, action:  nil)
        self.actionHandler = actionHandler
        self.target = self
        self.action = #selector(barButtonItemPressed(_:))
    }

    func barButtonItemPressed(sender: UIBarButtonItem) {
        actionHandler()
    }
}
