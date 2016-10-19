//
//  Cell.swift
//  MYTableViewIndex
//
//  Created by Makarov Yury on 09/07/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

class Cell : UITableViewCell {
    
    func setupWithItem(_ item: Item) {
        textLabel?.text = item as? String
        contentView.backgroundColor = item as? UIColor
    }
    
    static func heightForItem(_ item: Item) -> CGFloat {
        return item is UIColor ? 100 : 44
    }
}
