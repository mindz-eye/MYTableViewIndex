//
//  CollectionViewController.swift
//  MYTableViewIndex
//
//  Created by Makarov Yury on 24/06/2017.
//  Copyright © 2017 Makarov Yury. All rights reserved.
//

import UIKit
import MYTableViewIndex

class CollectionHeader : UICollectionReusableView {
        
    @IBOutlet weak var titleLabel: UILabel!
}

class CollectionViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout, TableViewIndexDelegate, ExampleContainer {
    
    var example: Example!
    
    fileprivate var dataSource: DataSource!
    
    fileprivate var tableViewIndexController: TableViewIndexController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = example.dataSource
        
        tableViewIndexController = TableViewIndexController(scrollView: collectionView!)
        tableViewIndexController.tableViewIndex.delegate = self
        
        example.setupTableIndexController(tableViewIndexController)
        
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.headerReferenceSize = CGSize(width: view.bounds.size.width, height: 30)
        layout.itemSize = CGSize(width: view.bounds.size.width, height: 44)
    }
    
    // MARK: - UICollectionView
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItemsInSection(section)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.numberOfSections()
    }
        
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionCell
        if let item = dataSource.itemAtIndexPath(indexPath) {
            cell.setupWithItem(item)
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! CollectionHeader
        header.titleLabel.text = dataSource.titleForHeaderInSection(indexPath.section)
        return header
    }
    
    // MARK: - TableViewIndex
    
    func tableViewIndex(_ tableViewIndex: TableViewIndex, didSelect item: UIView, at index: Int) {
        let sectionIndex = example.mapIndexItemToSection(item, index: index)
        if sectionIndex == NSNotFound {
            return
        }
        let indexPath = IndexPath(row: 0, section: sectionIndex)
        guard let attrs = collectionView!.layoutAttributesForSupplementaryElement(ofKind: UICollectionElementKindSectionHeader, at: indexPath) else {
            return
        }
        let yOffset = min(attrs.frame.origin.y, collectionView!.contentSize.height - collectionView!.frame.height + collectionView!.contentInset.top)
        collectionView!.contentOffset = CGPoint(x: 0, y: yOffset - collectionView!.contentInset.top)
    }
}
