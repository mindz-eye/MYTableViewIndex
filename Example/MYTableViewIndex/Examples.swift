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
    case collectionView = "collectionView"
}

protocol Example {
    
    var dataSource: DataSource { get }
    
    var indexDataSource: TableViewIndexDataSource { get }
    
    var hasSearchIndex: Bool { get }
    
    func mapIndexItemToSection(_ indexItem: IndexItem, index: NSInteger) -> Int
    
    func setupTableIndexController(_ tableIndexController: TableViewIndexController) -> Void
    
    func trackSelectedSections(_ sections: Set<Int>)
}

class BasicExample : Example {
    
    var dataSource: DataSource {
        return CountryDataSource()
    }
    
    var indexDataSource: TableViewIndexDataSource {
        return CollationIndexDataSource(hasSearchIndex: hasSearchIndex)
    }

    var hasSearchIndex: Bool {
        return false
    }
    
    func mapIndexItemToSection(_ indexItem: IndexItem, index: NSInteger) -> Int {
        return hasSearchIndex ? index - 1 : index
    }
    
    func setupTableIndexController(_ tableIndexController: TableViewIndexController) -> Void {
        tableIndexController.tableViewIndex.dataSource = indexDataSource
    }
    
    func trackSelectedSections(_ sections: Set<Int>) {}
}

class SearchExample : BasicExample {
    
    override var hasSearchIndex: Bool {
        return true
    }
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
        backgroundColor = UIColor.lightGray.withAlphaComponent(Alpha.normal.rawValue)
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func pressed(_ sender: TableViewIndex) {
        backgroundColor = UIColor.lightGray.withAlphaComponent(Alpha.highlighted.rawValue)
    }
    
    @objc func released(_ sender: TableViewIndex) {
        UIView.animate(withDuration: 0.15) {
            self.backgroundColor = UIColor.lightGray.withAlphaComponent(Alpha.normal.rawValue)
        }
    }
}

class CustomBackgroundExample : BasicExample {
    
    fileprivate(set) var tableViewIndex: TableViewIndex!
    
    override func setupTableIndexController(_ tableIndexController: TableViewIndexController) {
        super.setupTableIndexController(tableIndexController)
        
        tableIndexController.tableViewIndex.font = UIFont.boldSystemFont(ofSize: 12.0)
        
        let backgroundView = BackgroundView()
        
        tableIndexController.tableViewIndex.backgroundView = backgroundView
        tableIndexController.tableViewIndex.indexInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        
        tableIndexController.layouter = { tableView, tableIndex in
            var frame = tableIndex.frame
            frame.origin = CGPoint(x: frame.origin.x - 3, y: frame.origin.y)
            tableIndex.frame = frame
        };
        
        tableIndexController.tableViewIndex.addTarget(backgroundView, action: #selector(BackgroundView.pressed(_:)),
                                                      for: .touchDown)
        
        tableIndexController.tableViewIndex.addTarget(backgroundView, action: #selector(BackgroundView.released(_:)),
                                                      for: [.touchUpInside, .touchUpOutside])
        
        tableViewIndex = tableIndexController.tableViewIndex
    }

    override func trackSelectedSections(_ sections: Set<Int>) {
        let sortedSections = sections.sorted()
        
        UIView.animate(withDuration: 0.25, animations: {
            for (index, item) in self.tableViewIndex.items.enumerated() {
                let section = self.mapIndexItemToSection(item, index: index)
                let shouldHighlight = sortedSections.count > 0 && section >= sortedSections.first! && section <= sortedSections.last!
                
                item.tintColor = shouldHighlight ? UIColor.red : nil
            }
        })
    }
}

class LargeFontExample : SearchExample {
    
    override func setupTableIndexController(_ tableIndexController: TableViewIndexController) {
        super.setupTableIndexController(tableIndexController)
        
        tableIndexController.tableViewIndex.font = UIFont.boldSystemFont(ofSize: 20.0)
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

class ColoredIndexExample : SearchExample {
    
    override var indexDataSource: TableViewIndexDataSource {
        return ColoredIndexDataSource()
    }
}

class ImageIndexExample : BasicExample {
    
    override var indexDataSource: TableViewIndexDataSource {
        return ImageIndexDataSource()
    }
    
    override func mapIndexItemToSection(_ indexItem: IndexItem, index: NSInteger) -> Int {
        return index <= 1 ? NSNotFound : index - 2
    }
}

func exampleByType(_ type: ExampleType) -> Example {
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
        return SearchExample()
    case .collectionView:
        return BasicExample()
    }
}


