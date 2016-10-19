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
    
    func numberOfItemsInSection(_ section: Int) -> Int
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> Item?
    
    func titleForHeaderInSection(_ section: Int) -> String?
}

extension String : Item {}

struct CountryDataSource : DataSource {
    fileprivate(set) var sections = [[String]]()
    
    fileprivate let collaction = UILocalizedIndexedCollation.current()
    
    init() {
        sections = split(loadCountryNames())
    }
    
    fileprivate func loadCountryNames() -> [String] {
        return Locale.isoRegionCodes.map { (code) -> String in
            return Locale.current.localizedString(forRegionCode: code)!
        }
    }
    
    fileprivate func split(_ items: [String]) -> [[String]] {
        let collation = UILocalizedIndexedCollation.current()
        let items = collation.sortedArray(from: items, collationStringSelector: #selector(NSObject.description)) as! [String]
        var sections = [[String]](repeating: [], count: collation.sectionTitles.count)
        for item in items {
            let index = collation.section(for: item, collationStringSelector: #selector(NSObject.description))
            sections[index].append(item)
        }
        return sections
    }
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return sections[section].count
    }
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> Item? {
        return sections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).item]
    }
    
    func titleForHeaderInSection(_ section: Int) -> String? {
        return collaction.sectionTitles[section]
    }
}

extension UIColor : Item {}

struct CompoundDataSource : DataSource {
    
    fileprivate let colorsSection = [UIColor.lightGray, UIColor.gray, UIColor.darkGray]
    
    fileprivate let countryDataSource = CountryDataSource()
    
    func numberOfSections() -> Int {
        return countryDataSource.numberOfSections() + 1
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return section == 0 ? colorsSection.count : countryDataSource.numberOfItemsInSection(section - 1)
    }
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> Item? {
        if (indexPath as NSIndexPath).section == 0 {
            return colorsSection[(indexPath as NSIndexPath).item]
        } else {
            return countryDataSource.itemAtIndexPath(IndexPath(item: (indexPath as NSIndexPath).item, section: (indexPath as NSIndexPath).section - 1))
        }
    }
    
    func titleForHeaderInSection(_ section: Int) -> String? {
        return section == 0 ? nil : countryDataSource.titleForHeaderInSection(section - 1)
    }
}
