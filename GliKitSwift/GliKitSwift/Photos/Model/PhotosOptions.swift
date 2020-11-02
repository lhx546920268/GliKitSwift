//
//  PhotosOptions.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/28.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///打开相册的意图
enum PhotosIntention {
    
    ///单选
    case singleSelection
    
    ///多选
    case multiSelection
    
    ///裁剪 必须设置裁剪选项 cropSettings
    case crop
}

///相册选择结果
public struct PhotosPickResult {
    
    ///图片缩略图
    public private(set) var thumbnail: UIImage?
    
    ///压缩后的图片
    public private(set) var  compressedImage: UIImage?
    
    ///原图
    public private(set) var  originalImage: UIImage?
    
    ///通过相册选项 图片数据创建 创建失败返回nil
    init?(data: Data, options: PhotosOptions) {
        
        if let source = CGImageSourceCreateWithData(data as CFData, [kCGImageSourceShouldAllowFloat: true] as CFDictionary) {
            if let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] {
                
                let width = properties[kCGImagePropertyPixelWidth] as! Int
                let height = properties[kCGImagePropertyPixelHeight] as! Int
                let imageSize = CGSize(width, height)
                let scale = options.scale
                
                if options.needOriginalImage {
                    if let image = CGImageSourceCreateImageAtIndex(source, 0, nil) {
                        originalImage = UIImage(cgImage: image, scale: scale, orientation: .up)
                    }
                }
                
                if !options.compressedImageSize.hasZeroOrNegative {
                    var size = CGSize(options.compressedImageSize.width * scale, options.compressedImageSize.height * scale)
                    size = UIImage.gkFitImageSize(imageSize, size: size, type: .width)
                    
                    let dic: [CFString: Any] = [
                        kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
                        kCGImageSourceCreateThumbnailFromImageAlways: true,
                        kCGImageSourceCreateThumbnailWithTransform: true
                    ]
                    if let image = CGImageSourceCreateThumbnailAtIndex(source, 0, dic as CFDictionary) {
                        compressedImage = UIImage(cgImage: image, scale: scale, orientation: .up)
                    }
                }
                
                if !options.thumbnailSize.hasZeroOrNegative {
                    var size = CGSize(options.thumbnailSize.width * scale, options.thumbnailSize.height * scale)
                    size = UIImage.gkFitImageSize(imageSize, size: size, type: .width)
                    
                    let dic: [CFString: Any] = [
                        kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height),
                        kCGImageSourceCreateThumbnailFromImageAlways: true,
                        kCGImageSourceCreateThumbnailWithTransform: true
                    ]
                    if let image = CGImageSourceCreateThumbnailAtIndex(source, 0, dic as CFDictionary) {
                        thumbnail = UIImage(cgImage: image, scale: scale, orientation: .up)
                    }
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    init(image: UIImage, options: PhotosOptions) {
        var _image = image
        if options.needOriginalImage {
            originalImage = _image
        }
        
        if !options.compressedImageSize.hasZeroOrNegative {
            let compressedImage = _image.gkAspectFit(with: options.compressedImageSize)
            self.compressedImage = compressedImage
            _image = compressedImage
        }
        
        if !options.thumbnailSize.hasZeroOrNegative {
            self.thumbnail = _image.gkAspectFit(with: options.thumbnailSize)
        }
    }
}

public typealias PhotosCompletion = (_ results: [PhotosPickResult]) -> Void

///相册选项
public class PhotosOptions {
    
    ///选择图片完成回调
    var completion: PhotosCompletion?
    
    ///意图
    var intention: PhotosIntention = .multiSelection
    
    ///裁剪选项
    var cropSettings: ImageCropSettings?
    
    ///缩略图大小
    var thumbnailSize: CGSize = .zero
    
    ///压缩图片的大小
    var compressedImageSize: CGSize = CGSize(512, 512)
    
    ///是否需要原图
    var needOriginalImage: Bool = false
    
    ///多选数量
    var maxCount: Int = 1
    
    ///网格图片间距
    var gridSpacing: CGFloat = 3
    
    ///每行图片数量
    var numberOfItemsPerRow: Int = 4
    
    ///是否显示所有图片
    var shouldDisplayAllPhotos: Bool = true
    
    ///是否显示空的相册
    var shouldDisplayEmptyCollection: Bool = false
    
    ///是否直接显示第一个相册的内容
    var displayFistCollection: Bool = true
    
    ///图片scale
    @RangeWrapper(value: UIImage.gkImageScale, min: 1.0, max: 3.0)
    var scale: CGFloat
    
}
