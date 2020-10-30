//
//  ImageCropSettings.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/28.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///裁剪设置
public struct ImageCropSettings {

    ///裁剪图片
    var image: UIImage?
    
    ///裁剪框大小
    let cropSize: CGSize
    
    ///裁剪框圆角
    let cropCornerRadius: CGFloat = 0
    
    ///是否使用满屏裁剪框
    var useFullScreenCropFrame: Bool = true
    
    ///图片可以被放大的最大比例
    var limitRatio: CGFloat = 2.5
}
