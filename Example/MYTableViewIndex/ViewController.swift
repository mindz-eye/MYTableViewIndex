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
    
    private var hasSearchIndex = true
    private var dataSource: DataSource!
    private var indexDataSource: TableViewIndexDataSource!
    
    lazy private var searchController = UISearchController(searchResultsController: nil)
    
    private var useMYTableViewIndex = true {
        didSet {
            tableViewIndex.hidden = !useMYTableViewIndex
            setNativeIndexHidden(useMYTableViewIndex)
        }
    }
    
    @IBOutlet private var tableView: UITableView!
    
    @IBOutlet private var tableViewIndex: TableViewIndex!
    
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.handleKeyboardNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.handleKeyboardNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - UITableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfItemsInSection(section)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.titleForHeaderInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = dataSource.itemAtIndexPath(indexPath) as? String
        return cell
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if title == UITableViewIndexSearch {
            tableView.scrollRectToVisible(searchController.searchBar.frame, animated: false)
            return NSNotFound
        } else {
            let sectionIndex = hasSearchIndex ? index - 1 : index
            return UILocalizedIndexedCollation.currentCollation().sectionForSectionIndexTitleAtIndex(sectionIndex)
        }
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var titles = UILocalizedIndexedCollation.currentCollation().sectionIndexTitles
        if hasSearchIndex {
            titles.insert(UITableViewIndexSearch, atIndex: 0)
        }
        return titles
    }
    
    // MARK: - TableViewIndex
    
    func indexItems(forTableViewIndex tableViewIndex: TableViewIndex) -> [UIView] {
        var items = UILocalizedIndexedCollation.currentCollation().sectionIndexTitles.map{ title -> UIView in
            return StringItem(text: title)
        }
        if hasSearchIndex {
            items.insert(SearchItem(), atIndex: 0)
        }
        return items
    }
    
    func tableViewIndex(tableViewIndex: TableViewIndex, didSelectItem item: UIView, atIndex index: Int) {
        if item is SearchItem {
            tableView.scrollRectToVisible(searchController.searchBar.frame, animated: false)
        } else {
            let sectionIndex = hasSearchIndex ? index - 1 : index
            
            let rowCount = tableView.numberOfRowsInSection(sectionIndex)
            let indexPath = NSIndexPath(forRow: rowCount > 0 ? 0 : NSNotFound, inSection: sectionIndex)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func useTableViewIndexSwitcherValueChanged(sender: UISwitch) {
        useMYTableViewIndex = sender.on
    }
    
    @IBAction func insetSliderValueChanged(sender: UISlider) {
        self.bottomConstraint.constant = min(view.bounds.height * CGFloat(sender.maximumValue - sender.value),
                                             view.bounds.height * 0.7)
    }
    
    // MARK: - Keyboard
    
    func handleKeyboardNotification(note: NSNotification) {
        slider.value = 1.0
        
        if let frame = note.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue,
               curve = UIViewAnimationCurve(rawValue: (note.userInfo?[UIKeyboardAnimationCurveUserInfoKey]?.integerValue)!),
               duration = note.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
            
            let convertedFrame = view.convertRect(frame, fromView: nil)
            self.bottomConstraint.constant += (tableView.frame.maxY - convertedFrame.minY)
            
            UIView.animateWithDuration(duration, animations: {
                UIView.setAnimationCurve(curve)
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: - Helpers
    
    private func setNativeIndexHidden(hidden: Bool) {
        tableView.sectionIndexColor = hidden ? UIColor.clearColor() : nil
        tableView.sectionIndexBackgroundColor = hidden ? UIColor.clearColor() : nil
        tableView.sectionIndexTrackingBackgroundColor = hidden ? UIColor.clearColor() : nil
    }
}

