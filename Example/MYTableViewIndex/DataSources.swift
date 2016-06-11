//
//  TableDataSources.swift
//  MYTableViewIndex
//
//  Created by Makarov Yury on 09/07/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

protocol Item {}

protocol DataSource {
    
    func numberOfSections() -> Int
    
    func numberOfItemsInSection(section: Int) -> Int
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> Item?
    
    func titleForHeaderInSection(section: Int) -> String?
}

extension String : Item {}

struct CountryDataSource : DataSource {
    private(set) var sections = [[String]]()
    
    private let collaction = UILocalizedIndexedCollation.currentCollation()
    
    init() {
        sections = split(loadCountryNames())
    }
    
    private func loadCountryNames() -> [String] {
        return NSLocale.ISOCountryCodes().map { (code) -> String in
            return NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: code)!
        }
    }
    
    private func split(items: [String]) -> [[String]] {
        let collation = UILocalizedIndexedCollation.currentCollation()
        let items = collation.sortedArrayFromArray(items, collationStringSelector: #selector(NSObject.description)) as! [String]
        var sections = [[String]](count: collation.sectionTitles.count, repeatedValue: [])
        for item in items {
            let index = collation.sectionForObject(item, collationStringSelector: #selector(NSObject.description))
            sections[index].append(item)
        }
        return sections
    }
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        return sections[section].count
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> Item? {
        return sections[indexPath.section][indexPath.item]
    }
    
    func titleForHeaderInSection(section: Int) -> String? {
        return collaction.sectionTitles[section]
    }
}

extension UIColor : Item {}

struct CompoundDataSource : DataSource {
    
    private let colorsSection = [UIColor.lightGrayColor(), UIColor.grayColor(), UIColor.darkGrayColor()]
    
    private let countryDataSource = CountryDataSource()
    
    func numberOfSections() -> Int {
        return countryDataSource.numberOfSections() + 1
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        return section == 0 ? colorsSection.count : countryDataSource.numberOfItemsInSection(section - 1)
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> Item? {
        if indexPath.section == 0 {
            return colorsSection[indexPath.item]
        } else {
            return countryDataSource.itemAtIndexPath(NSIndexPath(forItem: indexPath.item, inSection: indexPath.section - 1))
        }
    }
    
    func titleForHeaderInSection(section: Int) -> String? {
        return section == 0 ? nil : countryDataSource.titleForHeaderInSection(section - 1)
    }
}