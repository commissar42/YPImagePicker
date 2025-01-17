//
//  YPMenuItem.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 24/01/2018.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit
import Stevia

final class YPMenuItem: UIView {
    
    var textLabel = UILabel()
    var button = UIButton()
    var config: YPImagePickerConfiguration! {
        didSet {
            if config == nil { return }
            backgroundColor = config.colors.bottomMenuItemBackgroundColor
            textLabel.textColor = config.colors.bottomMenuItemUnselectedTextColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init(config: YPImagePickerConfiguration) {
        self.init(frame: .zero)
        self.config = config
    }
    
    func setup() {
        sv(
            textLabel,
            button
        )
        
        textLabel.centerInContainer()
        |-(10)-textLabel-(10)-|
        button.fillContainer()
        
        textLabel.style { l in
            l.textAlignment = .center
            l.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            l.adjustsFontSizeToFitWidth = true
            l.numberOfLines = 2
        }
    }

    func select() {
        textLabel.textColor = config.colors.bottomMenuItemSelectedTextColor
    }
    
    func deselect() {
        textLabel.textColor = config.colors.bottomMenuItemUnselectedTextColor
    }
}
