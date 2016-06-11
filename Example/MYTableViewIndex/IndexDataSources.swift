//
//  IndexDataSource.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 28/05/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit
import MYTableViewIndex

class CollationIndexDataSource : NSObject, TableViewIndexDataSource {
    
    private let collaction = UILocalizedIndexedCollation.currentCollation()
    
    private let showsSearchItem: Bool
    
    init(hasSearchIndex: Bool) {
        showsSearchItem = hasSearchIndex
    }
    
    convenience override init() {
        self.init(hasSearchIndex: true)
    }
    
    func indexItems(forTableViewIndex tableViewIndex: TableViewIndex) -> [UIView] {
        var items = collaction.sectionIndexTitles.map{ title -> UIView in
            return StringItem(text: title)
        }
        if showsSearchItem {
            items.insert(SearchItem(), atIndex: 0)
        }
        return items
    }
}


private func generateRandomNumber(from from: UInt32, to: UInt32) -> UInt32 {
    return from + arc4random_uniform(to - from + 1)
}

extension UIColor {
    
    func my_shiftHue(shift: CGFloat) -> UIColor? {
        var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0
        if !getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return nil
        }
        return UIColor(hue: (hue + shift) % 1.0, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    func my_shiftHueRandomlyWithGradation(gradation: Int) -> UIColor {
        let rand = generateRandomNumber(from: 1, to: UInt32(gradation))
        let hueShift: CGFloat = 1.0 / CGFloat(rand)
        if let c = my_shiftHue(hueShift) {
            return c
        }
        return self
    }
}

class ColoredIndexDataSource : CollationIndexDataSource {
    
    override func indexItems(forTableViewIndex tableViewIndex: TableViewIndex) -> [UIView] {
        var color = UIColor.redColor()
        let gradation = collaction.sectionIndexTitles.count + 1
        
        var items = collaction.sectionIndexTitles.map{ title -> UIView in
            color = color.my_shiftHueRandomlyWithGradation(gradation)
            let item = StringItem(text: title)
            item.tintColor = color
            return item
        }
        let searchItem = SearchItem()
        searchItem.tintColor = color.my_shiftHueRandomlyWithGradation(gradation)
        items.insert(searchItem, atIndex: 0)
        return items
    }
}

class ImageIndexDataSource : CollationIndexDataSource {
    
    convenience init() {
        self.init(hasSearchIndex: false)
    }
    
    override func indexItems(forTableViewIndex tableViewIndex: TableViewIndex) -> [UIView] {
        var items = collaction.sectionIndexTitles.map{ title -> UIView in
            return StringItem(text: title)
        }
        let item1 = ImageItem(image: UIImage(named: "Contacts")!)
        item1.contentInset = UIEdgeInsets(top: 0, left: 0.5, bottom: -4, right: 0.5)
        items.insert(item1, atIndex: 0)

        let item2 = ImageItem(image: UIImage(named: "Settings")!)
        item2.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -4, right: 0)
        items.insert(item2, atIndex: 0)
        
        return items
    }
}