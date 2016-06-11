//
//  UIFont+Helpers.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 28/05/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

public func ==(lhs: [String : AnyObject], rhs: [String : AnyObject]) -> Bool {
    return NSDictionary(dictionary: lhs).isEqualToDictionary(rhs)
}

extension UIFont {
    
    func my_boundingSize() -> CGSize {
        return CGSize(width: lineHeight, height: lineHeight)
    }
    
    func my_isEqual(font: UIFont) -> Bool {
        return font.fontDescriptor().fontAttributes() == self.fontDescriptor().fontAttributes()
    }
}