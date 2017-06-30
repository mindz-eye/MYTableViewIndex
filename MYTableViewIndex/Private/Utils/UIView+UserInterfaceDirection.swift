//
//  UIView+SuperviewHandler.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 30/06/17.
//  Copyright © 2017 Makarov Yury. All rights reserved.
//

import UIKit

extension UIView {
    
    class func my_userInterfaceLayoutDirection(for view: UIView) -> UIUserInterfaceLayoutDirection {
        if #available(iOS 9.0, *) {
            return UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute)
        } else {
            return UIApplication.shared.userInterfaceLayoutDirection
        }
    }
}
