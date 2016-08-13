//
//  ImageItem.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 06/08/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

/// Use this class for displaying image based items.
@objc (MYImageItem)
public class ImageItem : UIImageView {
    
    public var contentInset = UIEdgeInsets()
    
    override public init(image: UIImage?) {
        super.init(image: image)
        contentMode = .ScaleAspectFit
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        guard let image = image else {
            return CGSize()
        }
        let imageRect = CGRect(origin: CGPoint(), size: image.size)
        let targetSize = CGSize(width: min(imageRect.width, size.width), height: min(imageRect.height, size.height))
        return CGRect(origin: CGPoint(), size: targetSize).insetBy(contentInset).size
    }
}
