//
//  TableViewController.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 30/04/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit
import MYTableViewIndex
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class TableViewController : UITableViewController, UITextFieldDelegate, TableViewIndexDelegate, ExampleContainer {
    
    var example: Example!
    
    fileprivate var dataSource: DataSource!
    
    lazy fileprivate var searchController = UISearchController(searchResultsController: nil)
    
    fileprivate var tableViewIndexController: TableViewIndexController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = example.dataSource
        
        tableViewIndexController = TableViewIndexController(scrollView: tableView)
        tableViewIndexController.tableViewIndex.delegate = self
        
        example.setupTableIndexController(tableViewIndexController)
    
        if example.hasSearchIndex {
            tableView.tableHeaderView = searchController.searchBar
            tableView.sectionIndexColor = UIColor.clear
            tableView.sectionIndexBackgroundColor = UIColor.clear
            tableView.sectionIndexTrackingBackgroundColor = UIColor.clear
            
            searchController.hidesNavigationBarDuringPresentation = false
        }
    }
    
    // MARK: - UITableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfItemsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.titleForHeaderInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let dataCell = cell as? TableCell {
            dataCell.setupWithItem(dataSource.itemAtIndexPath(indexPath)!)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableCell.heightForItem(dataSource.itemAtIndexPath(indexPath)!)
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return NSNotFound
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return example.hasSearchIndex ? [dummyItemForNativeTableIndex()] : nil
    }
    
    // MARK: - UIScrollView
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateIndexVisibility()
        updateHighlightedItems()
    }
    
    // MARK: - TableViewIndex
    
    func tableViewIndex(_ tableViewIndex: TableViewIndex, didSelect item: UIView, at index: Int) {
        if item is SearchItem {
            tableView.scrollRectToVisible(searchController.searchBar.frame, animated: false)
        } else {
            let sectionIndex = example.mapIndexItemToSection(item, index: index)
            if sectionIndex != NSNotFound {
                let rowCount = tableView.numberOfRows(inSection: sectionIndex)
                let indexPath = IndexPath(row: rowCount > 0 ? 0 : NSNotFound, section: sectionIndex)
                tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            } else {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func uncoveredTableViewFrame() -> CGRect {
        return CGRect(x: tableView.bounds.origin.x, y: tableView.bounds.origin.y + topLayoutGuide.length,
                      width: tableView.bounds.width, height: tableView.bounds.height - topLayoutGuide.length)
    }
    
    fileprivate func updateIndexVisibility() {
        guard let visibleIndexes = tableView.indexPathsForVisibleRows else {
            return
        }
        for indexPath in visibleIndexes {
            if (dataSource.titleForHeaderInSection((indexPath as NSIndexPath).section)) != nil {
                continue
            }
            let cellFrame = view.convert(tableView.rectForRow(at: indexPath), to: nil)
            
            if view.convert(uncoveredTableViewFrame(), to: nil).intersects(cellFrame) {
                tableViewIndexController.setHidden(true, animated: true)
                return
            }
        }
        tableViewIndexController.setHidden(false, animated: true)
    }

    fileprivate func updateHighlightedItems() {
        let frame = uncoveredTableViewFrame()
        var visibleSections = Set<Int>()
        
        for section in 0..<tableView.numberOfSections {
            if (frame.intersects(tableView.rect(forSection: section)) ||
                frame.intersects(tableView.rectForHeader(inSection: section))) {
                visibleSections.insert(section)
            }
        }
        example.trackSelectedSections(visibleSections)
    }
    
    fileprivate func dummyItemForNativeTableIndex() -> String {
        let maxLetterWidth = self.tableViewIndexController.tableViewIndex.font?.lineHeight
        var str = "";
        var size = CGSize()
        while size.width < maxLetterWidth {
            str += "i"
            size = str.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                                            options: [.usesFontLeading, .usesLineFragmentOrigin],
                                            attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 11.0)],
                                            context: nil).size
        }
        return str
    }
}
