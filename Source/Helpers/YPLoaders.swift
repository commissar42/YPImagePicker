//
//  YPLoaders.swift
//  YPImagePicker
//
//  Created by Nik Kov on 23.04.2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit

struct YPLoaders {

    static func defaultLoader(config: YPImagePickerConfiguration) -> UIBarButtonItem {
        let spinner = UIActivityIndicatorView(style: .gray)
        // TODO: Make this setable not constant
        spinner.color = config.colors.navigationBarActivityIndicatorColor
        spinner.startAnimating()
        return UIBarButtonItem(customView: spinner)
    }
    
}
