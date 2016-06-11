# MYTableViewIndex

[![CI Status](http://img.shields.io/travis/Makarov Yuriy/MYTableViewIndex.svg?style=flat)](https://travis-ci.org/Makarov Yuriy/MYTableViewIndex)
[![Version](https://img.shields.io/cocoapods/v/MYTableViewIndex.svg?style=flat)](http://cocoapods.org/pods/MYTableViewIndex)
[![License](https://img.shields.io/cocoapods/l/MYTableViewIndex.svg?style=flat)](http://cocoapods.org/pods/MYTableViewIndex)
[![Platform](https://img.shields.io/cocoapods/p/MYTableViewIndex.svg?style=flat)](http://cocoapods.org/pods/MYTableViewIndex)

**A pixel perfect replacement for UITableView section index, written in Swift**

MYTableViewIndex is a re-implementation of UITableView section index. This control is usually seen in apps displaying contacts, tracks and other alphabetically sorted data. MYTableViewIndex completely replicates native iOS section index, but can also display images and has additional customization capabilities.

## Features

* Can display images
* Fully customizable. E.g, you can set your font, add custom background view or even add your own type of items
* Supports both UITableViewController and UIViewController
* Includes TableViewIndexController class for simplified integration with UITableView

## Usage

### Instantiation

* #### Manual setup

The component is a UIControl subclass and can be used as any other view, simply by adding it to the view hierarchy. This can be done via Interface Builder or in code:

````swift
let tableViewIndex = tableViewIndex(frame: CGRect())
view.addSubview(tableViewIndex)
````

Note that in this case index view should be aligned to UITableView either manually or by setting up layout constraints. 


* #### Using TableViewIndexController

Things get more complicated when dealing with UITableViewController. The root view of this view controller is UITableView and adding your own view to UITableView hierarchy is generally a bad idea.
Enter TableViewIndexController. When used, it creates a TableViewIndex, adds it to the hierarchy and sets up the layout for you. You can also use it to hide TableViewIndex for cirtain table sections, like Apple does in its Music app.


Using TableViewIndexController the setup can be made in just one line of code:

````swift
let tableViewIndexController = TableViewIndexController(tableView: tableView)
````

The controller also observes UITableView insets and updates index view size accordingly. This makes sense when e.g. keyboard shows up:

 
### Data source

To feed index view with data, one should simply implement the following method of TableViewIndexDataSource protocol:

````swift
func indexItems(forTableViewIndex tableViewIndex: TableViewIndex) -> [UIView] {
    return UILocalizedIndexedCollation.currentCollation().sectionIndexTitles.map{ title -> UIView in
        return StringItem(text: title)
    }
}
````

Several predefined types of items are available for displaying strings, images, magnifying glass and truncation symbols. You can provide your own type of item though.

### Delegate

To respond to index view touches and scroll table to the selected section, one should provide a delegate object and implement the following method:

````swift
func tableViewIndex(tableViewIndex: TableViewIndex, didSelectItem item: UIView, atIndex index: Int) {
    let indexPath = NSIndexPath(forRow: 0, inSection: sectionIndex)
    tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
}
````

### Customization

MYTableViewIndex is fully customizable. See TableViewIndex properties for more details.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* iOS 8.0+

## Installation

MYTableViewIndex is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MYTableViewIndex"
```

## Author

Makarov Yuriy, makarov.yuriy@gmail.com

## License

MYTableViewIndex is available under the MIT license. See the LICENSE file for more info.
