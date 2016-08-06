//
//  DataProviders.swift
//  MYTableViewIndex
//
//  Created by Makarov Yury on 09/07/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit
import MYTableViewIndex

enum ExampleType : String {
    case comparison = "comparison"
    case customBackground = "background"
    case hidingIndex = "autohide"
    case coloredIndex = "color"
    case imageIndex = "image"
    case largeFont = "large"
}

protocol Example {
    
    var dataSource: DataSource { get }
    
    var indexDataSource: TableViewIndexDataSource { get }
    
    var hasSearchIndex: Bool { get }
    
    func mapIndexItemToSection(indexItem: IndexItem, index: NSInteger) -> Int
    
    func setupTableIndexController(tableIndexController: TableViewIndexController) -> Void
    
    func trackSelectedSections(sections: Set<Int>)
}


class BasicExample : Example {
    
    var dataSource: DataSource {
        return CountryDataSource()
    }
    
    var indexDataSource: TableViewIndexDataSource {
        return CollationIndexDataSource(hasSearchIndex: hasSearchIndex)
    }

    var hasSearchIndex: Bool {
        return true
    }
    
    func mapIndexItemToSection(indexItem: IndexItem, index: NSInteger) -> Int {
        return hasSearchIndex ? index - 1 : index
    }
    
    func setupTableIndexController(tableIndexController: TableViewIndexController) -> Void {
        tableIndexController.tableViewIndex.dataSource = indexDataSource
    }
    
    func trackSelectedSections(sections: Set<Int>) {}
}


class BackgroundView : UIView {
    
    enum Alpha : CGFloat {
        case normal = 0.3
        case highlighted = 0.6
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 6
        layer.masksToBounds = false
        backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(Alpha.normal.rawValue)
        userInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func pressed(sender: TableViewIndex) {
        backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(Alpha.highlighted.rawValue)
    }
    
    @objc func released(sender: TableViewIndex) {
        UIView.animateWithDuration(0.15) {
            self.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(Alpha.normal.rawValue)
        }
    }
}

class CustomBackgroundExample : BasicExample {
    
    private(set) var tableViewIndex: TableViewIndex!
    
    override func setupTableIndexController(tableIndexController: TableViewIndexController) {
        super.setupTableIndexController(tableIndexController)
        
        tableIndexController.tableViewIndex.font = UIFont.boldSystemFontOfSize(12.0)
        
        let backgroundView = BackgroundView()
        
        tableIndexController.tableViewIndex.backgroundView = backgroundView
        tableIndexController.tableViewIndex.indexInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        
        tableIndexController.layouter = { tableView, tableIndex in
            var frame = tableIndex.frame
            frame.origin = CGPoint(x: frame.origin.x - 3, y: frame.origin.y)
            tableIndex.frame = frame
        };
        
        tableIndexController.tableViewIndex.addTarget(backgroundView, action: #selector(BackgroundView.pressed(_:)),
                                                      forControlEvents: .TouchDown)
        
        tableIndexController.tableViewIndex.addTarget(backgroundView, action: #selector(BackgroundView.released(_:)),
                                                      forControlEvents: [.TouchUpInside, .TouchUpOutside])
        
        tableViewIndex = tableIndexController.tableViewIndex
    }

    override func trackSelectedSections(sections: Set<Int>) {
        let sortedSections = sections.sort()
        
        UIView.animateWithDuration(0.25, animations: {
            for (index, item) in self.tableViewIndex.items.enumerate() {
                let section = self.mapIndexItemToSection(item, index: index)
                let shouldHighlight = sortedSections.count > 0 && section >= sortedSections.first! && section <= sortedSections.last!
                
                item.tintColor = shouldHighlight ? UIColor.redColor() : nil
            }
        })
    }
    
    override var hasSearchIndex: Bool {
        return false
    }
}

class LargeFontExample : BasicExample {
    
    override func setupTableIndexController(tableIndexController: TableViewIndexController) {
        super.setupTableIndexController(tableIndexController)
        
        tableIndexController.tableViewIndex.font = UIFont.boldSystemFontOfSize(20.0)
    }
}

class AutohidingIndexExample : BasicExample {
    
    override var dataSource: DataSource {
        return CompoundDataSource()
    }
    
    override var hasSearchIndex: Bool {
        return false
    }
}

class ColoredIndexExample : BasicExample {
    
    override var indexDataSource: TableViewIndexDataSource {
        return ColoredIndexDataSource()
    }
}

class ImageIndexExample : BasicExample {
    
    override var hasSearchIndex: Bool {
        return false
    }
    
    override var indexDataSource: TableViewIndexDataSource {
        return ImageIndexDataSource()
    }
    
    override func mapIndexItemToSection(indexItem: IndexItem, index: NSInteger) -> Int {
        return index <= 1 ? NSNotFound : index - 2
    }
}

func exampleByType(type: ExampleType) -> Example {
    switch type {
    case .customBackground:
        return CustomBackgroundExample()
    case .hidingIndex:
        return AutohidingIndexExample()
    case .coloredIndex:
        return ColoredIndexExample()
    case .imageIndex:
        return ImageIndexExample()
    case .largeFont:
        return LargeFontExample()
    case .comparison:
        return BasicExample()
    }
}


