//
//  TableViewController.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 30/04/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit
import MYTableViewIndex

class TableViewController : UITableViewController, UITextFieldDelegate, TableViewIndexDelegate, ExampleContainer {
    
    var example: Example!
    
    private var dataSource: DataSource!
    
    lazy private var searchController = UISearchController(searchResultsController: nil)
    
    private var tableViewIndexController: TableViewIndexController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = example.dataSource
        
        tableViewIndexController = TableViewIndexController(tableView: tableView)
        tableViewIndexController.tableViewIndex.delegate = self
        
        example.setupTableIndexController(tableViewIndexController)
    
        if example.hasSearchIndex {
            tableView.tableHeaderView = searchController.searchBar
            tableView.sectionIndexColor = UIColor.clearColor()
            tableView.sectionIndexBackgroundColor = UIColor.clearColor()
            tableView.sectionIndexTrackingBackgroundColor = UIColor.clearColor()
            
            searchController.hidesNavigationBarDuringPresentation = false
        }
    }
    
    // MARK: - UITableView
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfItemsInSection(section)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.titleForHeaderInSection(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        if let dataCell = cell as? Cell {
            dataCell.setupWithItem(dataSource.itemAtIndexPath(indexPath)!)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Cell.heightForItem(dataSource.itemAtIndexPath(indexPath)!)
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return NSNotFound
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return example.hasSearchIndex ? [dummyItemForNativeTableIndex()] : nil
    }
    
    // MARK: - UIScrollView
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        updateIndexVisibility()
        updateHighlightedItems()
    }
    
    // MARK: - TableViewIndex
    
    func tableViewIndex(tableViewIndex: TableViewIndex, didSelectItem item: UIView, atIndex index: Int) {
        if item is SearchItem {
            tableView.scrollRectToVisible(searchController.searchBar.frame, animated: false)
        } else {
            let sectionIndex = example.mapIndexItemToSection(item, index: index)
            if sectionIndex != NSNotFound {
                let rowCount = tableView.numberOfRowsInSection(sectionIndex)
                let indexPath = NSIndexPath(forRow: rowCount > 0 ? 0 : NSNotFound, inSection: sectionIndex)
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
            } else {
                tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func uncoveredTableViewFrame() -> CGRect {
        return CGRect(x: tableView.bounds.origin.x, y: tableView.bounds.origin.y + topLayoutGuide.length,
                      width: tableView.bounds.width, height: tableView.bounds.height - topLayoutGuide.length)
    }
    
    private func updateIndexVisibility() {
        guard let visibleIndexes = tableView.indexPathsForVisibleRows else {
            return
        }
        for indexPath in visibleIndexes {
            if (dataSource.titleForHeaderInSection(indexPath.section)) != nil {
                continue
            }
            let cellFrame = view.convertRect(tableView.rectForRowAtIndexPath(indexPath), toView: nil)
            
            if view.convertRect(uncoveredTableViewFrame(), toView: nil).intersects(cellFrame) {
                tableViewIndexController.setHidden(true, animated: true)
                return
            }
        }
        tableViewIndexController.setHidden(false, animated: true)
    }

    private func updateHighlightedItems() {
        let frame = uncoveredTableViewFrame()
        var visibleSections = Set<Int>()
        
        for section in 0..<tableView.numberOfSections {
            if (frame.intersects(tableView.rectForSection(section)) ||
                frame.intersects(tableView.rectForHeaderInSection(section))) {
                visibleSections.insert(section)
            }
        }
        example.trackSelectedSections(visibleSections)
    }
    
    private func dummyItemForNativeTableIndex() -> String {
        let maxLetterWidth = self.tableViewIndexController.tableViewIndex.font?.lineHeight
        var str = "";
        var size = CGSize()
        while size.width < maxLetterWidth {
            str += "i"
            size = str.boundingRectWithSize(CGSize(width: CGFloat.max, height: CGFloat.max),
                                            options: [.UsesFontLeading, .UsesLineFragmentOrigin],
                                            attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(11.0)],
                                            context: nil).size
        }
        return str
    }
}
