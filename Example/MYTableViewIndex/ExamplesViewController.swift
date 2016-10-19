//
//  ExamplesViewController.swift
//  MYTableViewIndex
//
//  Created by Makarov Yury on 09/07/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

protocol ExampleContainer {
    
    var example: Example! { get set }
}

class ExamplesViewController : UITableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let exampleType = ExampleType(rawValue: segue.identifier!) {
            var vc = segue.destination as! ExampleContainer
            vc.example = exampleByType(exampleType)
        }
    }
}
