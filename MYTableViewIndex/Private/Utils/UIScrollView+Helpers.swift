//
//  UIScrollView+Helpers.swift
//  MYTableViewIndex
//
//  Created by Makarov Yury on 02/12/2017.
//  Copyright © 2017 Makarov Yury. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    var my_effectiveContentInset: UIEdgeInsets {
        get {
            if #available(iOS 11.0, *) {
                return self.adjustedContentInset
            } else {
                return self.contentInset
            }
        }
    }
}
