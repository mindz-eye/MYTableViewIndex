//
//  BackgroundView.swift
//  Pods
//
//  Created by Makarov Yury on 24/06/2017.
//
//

import UIKit

class BackgroundView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        if #available(iOS 11.0, *) {} else {
            backgroundColor = UIColor.white.withAlphaComponent(0.9)
        }
        isUserInteractionEnabled = false
    }
}
