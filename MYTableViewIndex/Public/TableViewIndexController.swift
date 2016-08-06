//
//  TableViewIndexController.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 22/05/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

public class TableViewIndexController : NSObject {
    
    public let tableViewIndex = TableViewIndex()
    
    public var layouter: ((tableView: UITableView, tableIndex: TableViewIndex) -> Void)?
    
    private(set) weak var tableView: UITableView?
    
    private enum ObservedKeyPaths: String {
        case contentInset = "contentInset"
        case bounds = "bounds"
        case center = "center"
    }
    
    private var observer: KeyValueObserver?
    
    private var hidden = false
    
    public init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        
        observeTableView()
        observeKeyboard();
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - UITableView observation
    
    private func observeTableView() {
        guard let tableView = tableView else {
            return
        }
        let keyPaths = [ObservedKeyPaths.bounds.rawValue,
                        ObservedKeyPaths.center.rawValue,
                        ObservedKeyPaths.contentInset.rawValue]
        
        observer = KeyValueObserver(object: tableView, keyPaths: keyPaths, handler: {[weak self] keyPath in
            self?.layoutUsingTableInset()
        })
        
        tableView.my_didMoveToSuperviewHandler = { [weak self] superview in
            if let superview = superview, tableIndex = self?.tableViewIndex {
                superview.addSubview(tableIndex)
                self?.layoutUsingTableInset()
            } else {
                self?.tableViewIndex.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Keyboard
    
    func observeKeyboard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TableViewIndexController.handleKeyboardNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TableViewIndexController.handleKeyboardNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func handleKeyboardNotification(note: NSNotification) {
        guard let tableView = tableView, parentView = tableView.superview, userInfo = note.userInfo else {
            return;
        }
        if let frame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue,
               curve = userInfo[UIKeyboardAnimationCurveUserInfoKey]?.integerValue,
            duration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
            
            let convertedFrame = parentView.convertRect(frame, fromView: nil)
            
            var inset = tableView.contentInset
            inset.bottom = (tableView.frame.maxY - convertedFrame.minY)
            
            UIView.animateWithDuration(duration, animations: {
                if let curveValue = UIViewAnimationCurve(rawValue: curve) {
                    UIView.setAnimationCurve(curveValue)
                }
                self.layout(withInset: inset)
                parentView.layoutIfNeeded()
                
                }, completion: { _ in
                    self.layoutUsingTableInset()
            })
        }
    }
    
    // MARK: - Layout
    
    private func layoutUsingTableInset() {
        guard let tableView = tableView else {
            return
        }
        layout(withInset: tableView.contentInset)
    }
    
    private func layout(withInset inset: UIEdgeInsets) {
        guard let tableView = tableView else {
            return
        }
        let tableFrame = tableViewIndex.superview != nil
            ? tableView.convertRect(tableView.bounds, toView: tableViewIndex.superview) : tableView.frame
        
        let width = tableFrame.width - (inset.left + inset.right)
        let height = tableFrame.height - (inset.top + inset.bottom)
        
        layoutInRect(CGRect(x: tableFrame.x, y: tableFrame.y + inset.top, width: width, height: height))
    }
    
    private func layoutInRect(rect: CGRect) {
        let tableIndexSize = tableViewIndex.sizeThatFits(rect.size)
        
        var frame = CGRect(origin: CGPoint(x: rect.right - tableIndexSize.width, y: rect.y), size: tableIndexSize)
        
        if hidden {
            frame.right = frame.right + tableViewIndex.backgroundRect().width
        }
        tableViewIndex.frame = frame
        
        if let layouter = layouter, tableView = tableView {
            layouter(tableView: tableView, tableIndex: tableViewIndex)
        }
    }
    
    // MARK: - Visibility
    
    public func setHidden(hidden: Bool, animated: Bool, completion: (Void -> ())?, alongsideAnimations: (Void -> ())?) {
        if self.hidden == hidden {
            return
        }
        self.hidden = hidden
        
        if hidden {
            observer = nil
        }
        let completionHandler = {
            self.tableViewIndex.hidden = hidden
            
            if !hidden {
                self.observeTableView()
            }
            if let completion = completion {
                completion()
            }
        }
        if animated {
            animateToHidden(hidden, completion: completionHandler, alongsideAnimations: alongsideAnimations)
        } else {
            completionHandler()
        }
    }
    
    public func setHidden(hidden: Bool, animated: Bool) {
        setHidden(hidden, animated: animated, completion: nil, alongsideAnimations: nil)
    }
    
    private func animateToHidden(hidden: Bool, completion: Void -> (), alongsideAnimations: (Void -> ())?) {
        if !hidden {
            tableViewIndex.hidden = false
        }        
        UIView.animateWithDuration(0.25, animations: {
            self.layoutUsingTableInset()
            
            if let animations = alongsideAnimations {
                animations()
            }
        }, completion: { _ in
            completion()
        })
    }
    
}
