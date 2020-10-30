//
//  PhotosCollection.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/28.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import Photos.PHFetchResult
import Photos.PHAsset

///相册分组信息
struct PhotosCollection {
    
    ///标题
    let title: String?
    
    ///资源信息
    let assets: PHFetchResult<PHAsset>
}
