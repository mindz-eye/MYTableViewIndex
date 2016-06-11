//
//  ConcreteStyle.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 06/06/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

class ConcreteStyle : Style {
    
    @objc let font: UIFont
    
    @objc let itemSpacing: CGFloat
    
    init(font: UIFont?, itemSpacing: CGFloat?) {
        self.font = font ?? StyleDefaults.font
        self.itemSpacing = itemSpacing ?? StyleDefaults.itemSpacing
    }
}
