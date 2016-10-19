//
//  ViewController.swift
//  TableViewIndex
//
//  Created by Makarov Yuriy on 04/19/2016.
//  Copyright (c) 2016 Makarov Yuriy. All rights reserved.
//

import UIKit
import MYTableViewIndex

class ViewController: UIViewController, UITableViewDataSource, TableViewIndexDataSource, TableViewIndexDelegate, ExampleContainer {
    
    var example: Example!
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    fileprivate var hasSearchIndex = true
    fileprivate var dataSource: DataSource!
    fileprivate var indexDataSource: TableViewIndexDataSource!
    
    lazy fileprivate var searchController = UISearchController(searchResultsController: nil)
    
    fileprivate var useMYTableViewIndex = true {
        didSet {
            tableViewIndex.isHidden = !useMYTableViewIndex
            setNativeIndexHidden(useMYTableViewIndex)
        }
    }
    
    @IBOutlet fileprivate var tableView: UITableView!
    
    @IBOutlet fileprivate var tableViewIndex: TableViewIndex!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hasSearchIndex = example.hasSearchIndex
        dataSource = example.dataSource
        indexDataSource = example.indexDataSource
        
        tableViewIndex.delegate = self
        tableViewIndex.dataSource = self
        
        if hasSearchIndex {
            tableView.tableHeaderView = searchController.searchBar
        }
        
        setNativeIndexHidden(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleKeyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleKeyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfItemsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.titleForHeaderInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource.itemAtIndexPath(indexPath) as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if title == UITableViewIndexSearch {
            tableView.scrollRectToVisible(searchController.searchBar.frame, animated: false)
            return NSNotFound
        } else {
            let sectionIndex = hasSearchIndex ? index - 1 : index
            return UILocalizedIndexedCollation.current().section(forSectionIndexTitle: sectionIndex)
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var titles = UILocalizedIndexedCollation.current().sectionIndexTitles
        if hasSearchIndex {
            titles.insert(UITableViewIndexSearch, at: 0)
        }
        return titles
    }
    
    // MARK: - TableViewIndex
    
    func indexItems(for tableViewIndex: TableViewIndex) -> [UIView] {
        var items = UILocalizedIndexedCollation.current().sectionIndexTitles.map{ title -> UIView in
            return StringItem(text: title)
        }
        if hasSearchIndex {
            items.insert(SearchItem(), at: 0)
        }
        return items
    }
    
    func tableViewIndex(_ tableViewIndex: TableViewIndex, didSelect item: UIView, at index: Int) {
        if item is SearchItem {
            tableView.scrollRectToVisible(searchController.searchBar.frame, animated: false)
        } else {
            let sectionIndex = hasSearchIndex ? index - 1 : index
            
            let rowCount = tableView.numberOfRows(inSection: sectionIndex)
            let indexPath = IndexPath(row: rowCount > 0 ? 0 : NSNotFound, section: sectionIndex)
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func useTableViewIndexSwitcherValueChanged(_ sender: UISwitch) {
        useMYTableViewIndex = sender.isOn
    }
    
    @IBAction func insetSliderValueChanged(_ sender: UISlider) {
        self.bottomConstraint.constant = min(view.bounds.height * CGFloat(sender.maximumValue - sender.value),
                                             view.bounds.height * 0.7)
    }
    
    // MARK: - Keyboard
    
    func handleKeyboardNotification(_ note: Notification) {
        slider.value = 1.0
        
        guard let userInfo = note.userInfo else {
            return
        }
        
        if let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let curve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            
            let convertedFrame = view.convert(frame, from: nil)
            self.bottomConstraint.constant += (tableView.frame.maxY - convertedFrame.minY)
            
            UIView.animate(withDuration: duration, animations: {
                UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve)!)
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func setNativeIndexHidden(_ hidden: Bool) {
        tableView.sectionIndexColor = hidden ? UIColor.clear : nil
        tableView.sectionIndexBackgroundColor = hidden ? UIColor.clear : nil
        tableView.sectionIndexTrackingBackgroundColor = hidden ? UIColor.clear : nil
    }
}

