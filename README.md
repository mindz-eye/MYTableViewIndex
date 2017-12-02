# MYTableViewIndex

[![Build Status](https://travis-ci.org/mindz-eye/MYTableViewIndex.svg?branch=master)](https://travis-ci.org/mindz-eye/MYTableViewIndex)
[![Version](https://img.shields.io/cocoapods/v/MYTableViewIndex.svg?style=flat)](http://cocoapods.org/pods/MYTableViewIndex)
[![License](https://img.shields.io/cocoapods/l/MYTableViewIndex.svg?style=flat)](http://cocoapods.org/pods/MYTableViewIndex)
[![Platform](https://img.shields.io/cocoapods/p/MYTableViewIndex.svg?style=flat)](http://cocoapods.org/pods/MYTableViewIndex)

MYTableViewIndex is a re-implementation of UITableView section index. This control is usually seen in apps displaying contacts, tracks and other alphabetically sorted data. MYTableViewIndex completely replicates native iOS section index, but can also display images and has additional customization capabilities.

## Features

* Can display images
* Fully customizable: use custom fonts, background views, add your own type of items
* Compatible with any UIScrollView subclass
* Works properly with UITableViewController and UICollectionViewController
* Automatic layout, inset management and keyboard avoidance (via TableViewIndexController)
* Right-to-left languages support
* Haptic Feedback support
* Accessibility support

Below are the screenshots for some of the features:
<br>

![Screenshot0][highlighting]      |      ![Screenshot1][images]
----------------------------------|----------------------------
![Screenshot2][truncation]        |      ![Screenshot3][colors]
![Screenshot4][keyboard]          |      ![Screenshot5][large]

## Usage

### 1. Instantiation

#### Manual setup

The component is a UIControl subclass and can be used as any other view, simply by adding it to the view hierarchy. This can be done via Interface Builder or in code:

````swift
let tableViewIndex = tableViewIndex(frame: CGRect())
view.addSubview(tableViewIndex)
````

Note that in this case no layout is done automatically and all the required index view alignment is completely up to you. 


#### Using TableViewIndexController

Things get more complicated when dealing with UITableViewController/UICollectionViewController. The root view of these view controllers is a UIScrollView descendant and using it as a superview for TableViewIndex is generally a bad idea, since UIScrollView delays touch delivery by default.

Enter TableViewIndexController. When used, it creates a TableViewIndex instance, adds it to the hierarchy as a sibling of the root view and sets up the layout. The controller also observes UIScrollView insets and updates index view size accordingly. This makes sense when e.g. keyboard shows up.

You can also use the controller to hide TableViewIndex for cirtain table sections, like Apple once did in its Music app:

![Screenshot4][autohide]


Using TableViewIndexController the setup can be done in just one line of code:

````swift
let tableViewIndexController = TableViewIndexController(scrollView: tableView)
````

 
### 2. Data source

To feed index view with data, one should simply implement the following method of TableViewIndexDataSource protocol:

````swift
func indexItems(for tableViewIndex: TableViewIndex) -> [UIView] {
    return UILocalizedIndexedCollation.currentCollation().sectionIndexTitles.map{ title -> UIView in
        return StringItem(text: title)
    }
}
````

And attach it to the index view:

````swift
tableViewIndexController.tableViewIndex.dataSource = dataSourceObject

````


Several predefined types of items are available for displaying strings, images, magnifying glass and truncation symbols. You can provide your own type of item though.

### 3. Delegate

To respond to index view touches and scroll table to the selected section, one should provide a delegate object and implement the following method:

````swift
func tableViewIndex(_ tableViewIndex: TableViewIndex, didSelect item: UIView, at index: Int) -> Bool {
    let indexPath = NSIndexPath(forRow: 0, inSection: sectionIndex)
    tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
    
    return true // return true to produce haptic feedback on capable devices 
}
````

### 4. Customization

MYTableViewIndex is fully customizable. See TableViewIndex properties for more details.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* iOS 8.0+
* Swift 4.0

If you'd like to use the library in a project targeting Swift 3.x, please use [swift-3.x](https://github.com/mindz-eye/MYTableViewIndex/tree/swift-3.x) branch.

## Installation

### CocoaPods

MYTableViewIndex is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

````ruby
pod 'MYTableViewIndex'
````
### Manually

Download and drop all .swift files from MYTableViewIndex folder to your project. 

## Objective-C

All public classes of MYTableViewIndex are exposed to Objective-C, just import the library module:
````objective-c
@import MYTableViewIndex;
````

And don't forget to enable frameworks in your Podfile:
````ruby
use_frameworks!
````

## Author

Makarov Yuriy, makarov.yuriy@gmail.com

## License

MYTableViewIndex is available under the MIT license. See the LICENSE file for more info.

[autohide]:https://raw.github.com/mindz-eye/MYTableViewIndex/master/Screenshots/autohide.gif
[colors]:https://raw.github.com/mindz-eye/MYTableViewIndex/master/Screenshots/colors.png
[highlighting]:https://raw.github.com/mindz-eye/MYTableViewIndex/master/Screenshots/highlighting.gif
[images]:https://raw.github.com/mindz-eye/MYTableViewIndex/master/Screenshots/images.png
[large]:https://raw.github.com/mindz-eye/MYTableViewIndex/master/Screenshots/large.png
[truncation]:https://raw.github.com/mindz-eye/MYTableViewIndex/master/Screenshots/truncation.gif
[keyboard]:https://raw.github.com/mindz-eye/MYTableViewIndex/master/Screenshots/keyboard.gif
