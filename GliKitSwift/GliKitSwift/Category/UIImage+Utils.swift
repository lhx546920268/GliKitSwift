//
//  UIImage+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/8/27.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import CoreImage

public extension UIImage {
    
    ///图片等比例缩小方式
    enum FitType {
        
        ///宽和高 宽高有一个大于指定值都会整体缩放
        case size
        
        ///宽 只有宽度大于指定宽度时，才缩放
        case width
        
        ///高 只有高度度大于指定宽度时，才缩放
        case height
    }
    
    ///二维码容错率
    enum QRCodeCorrectionLevel: String {
        
        /// 7% 容错率 L
        case percent7 = "L"
        
        /// 15% 容错率 M
        case percent15 = "M"
        
        /// 25% 容错率 Q
        case percent25 = "Q"
        
        /// 30% 容错率 H
        case percent30 = "H"
    }
    
    // MARK: - 创建图片
    
    ///通过view生成图片
    class func gkImageFromView(_ view: UIView) -> UIImage {
        return gkImageFromLayer(view.layer)
    }
    
    ///通过layer生成图片
    class func gkImageFromLayer(_ layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(floor(layer.bounds.width), floor(layer.bounds.height)), layer.isOpaque, 0);
        let context = UIGraphicsGetCurrentContext()!
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    ///通过给定颜色创建图片
    class func gkImageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        let context = UIGraphicsGetCurrentContext()!
        color.setFill()
        context.addRect(CGRect(0, 0, size.width, size.height))
        context.drawPath(using: .fill)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    
    // MARK: - resize
    
    ///可使用 AVFoundation 中的AVMakeRectWithAspectRatioInsideRect
    
    /**
     通过给定的大小，获取等比例缩小后的图片尺寸
     *@param size 要缩小的图片最大尺寸
     *@param type 缩小方式
     *@return 返回要缩小的图片尺寸
     */
    func gkFit(with size: CGSize, type: FitType) -> CGSize {
        return UIImage.gkFitImageSize(self.size, size: size, type: type)
    }
    
    /**
     通过给定的大小，获取等比例缩小后的图片尺寸
     *@param imageSize 要缩小的图片大小
     *@param size 要缩小的图片最大尺寸
     *@param type 缩小方式
     *@return 返回要缩小的图片尺寸
     */
    class func gkFitImageSize(_ imageSize: CGSize, size: CGSize, type: FitType) -> CGSize {
        var width = imageSize.width
        var height = imageSize.height
        
        if width == height {
            width = min(width, size.width > size.height ? size.height : size.width)
            height = width
        } else {
            let heightScale = height / size.height
            let widthScale = width / size.width
            
            switch type {
            case .size :
                if height >= size.height && width >= size.width {
                    if heightScale > widthScale {
                        height = floor(height / heightScale)
                        width = floor(width / heightScale)
                    } else {
                        height = floor(height / widthScale)
                        width = floor(width / widthScale)
                    }
                } else {
                    if height >= size.height && width <= size.width {
                        height = floor(height / heightScale)
                        width = floor(width / heightScale)
                    } else if height <= size.height && width >= size.width {
                        height = floor(height / widthScale)
                        width = floor(width / widthScale)
                    }
                }
                
            case .width :
                if width > size.width {
                    height = floor(height / widthScale)
                    width = floor(width / widthScale)
                }
                
            case .height :
                if height > size.height {
                    height = floor(height / heightScale)
                    width = floor(width / heightScale)
                }
            }
        }
        
        return CGSize(width, height)
    }
    
    
    /**
     通过给定大小获取图片的等比例缩小的缩率图
     *@param size 目标图片大小
     *@return 图片的缩略图
     */
    func gkAspectFit(with size: CGSize) -> UIImage {
        let width = self.size.width
        let height = self.size.height
        
        let size = UIImage.gkFitImageSize(CGSize(width, height), size: size, type: .size)
        
        if(size.height >= height || size.width >= width) {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIImage.gkImageScale)
        self.draw(in: CGRect(0, 0, floor(size.width), floor(size.height)))
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let image = thumbnail, let cgImage = image.cgImage else {
            return self
        }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
    }
    
    /**
     居中截取的缩略图
     *@param size 目标图片大小
     *@return 图片的缩略图
     */
    func gkAspectFill(with size: CGSize) -> UIImage {
        var image: UIImage
        
        if self.size.width == self.size.height && size.width == size.height {
            //正方形图片
            image = self
        } else {
            let multipleWidthNum = self.size.width / size.width
            let multipleHeightNum = self.size.height / size.height
            
            let scale = min(multipleWidthNum, multipleHeightNum)
            let width = size.width * scale
            let height = size.height * scale
            image = gkSubImage(with: CGRect((self.size.width - width) / 2.0, (self.size.height - height) / 2.0, width, height))
        }
        
        return image.gkAspectFit(with: size)
    }
    
    /**
     截取图片
     *@param rect 要截取的rect
     *@return 截取的图片
     */
    func gkSubImage(with rect: CGRect) -> UIImage {
        
        let origin = CGPoint(-rect.midX, -rect.midY)
        UIGraphicsBeginImageContextWithOptions(CGSize(floor(rect.width), floor(rect.height)), false, UIImage.gkImageScale)
        
        self.draw(at: origin)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    /**
     修复图片方向错误，比如拍照的时候，有时图片方向不对
     */
    class func gkFixOrientation(with image: UIImage) -> UIImage {
        
        guard image.imageOrientation != .up, let cgImage = image.cgImage else {
            return image
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity
        switch image.imageOrientation {
        case .down, .downMirrored :
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat.pi)
            
        case .left, .leftMirrored :
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
            
        case .right, .rightMirrored :
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: -CGFloat.pi / 2)
        default:
            break
        }
        
        switch image.imageOrientation {
        case .upMirrored, .downMirrored :
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored :
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        
        let width = cgImage.width
        let height = cgImage.height
        
        guard let ctx = CGContext(data: nil,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: cgImage.bitsPerComponent,
                                  bytesPerRow: 0,
                                  space: cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: cgImage.bitmapInfo.rawValue) else {
                                    return image
        }
        
        ctx.concatenate(transform)
        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            // Grr...
            ctx.draw(cgImage, in: CGRect(0, 0, height, width))
        default:
            ctx.draw(cgImage, in: CGRect(0, 0, width, height))
        }
        
        // And now we just create a new UIImage from the drawing context
        guard let result = ctx.makeImage() else {
            return image
        }
        
        return UIImage(cgImage: result, scale: image.scale, orientation: .up)
    }
    
    // MARK: - 二维码
    
    /**
     通过给定信息生成二维码
     
     *@param string 二维码信息 不能为空
     *@param correctionLevel 二维码容错率
     *@param size 二维码大小 如果为CGSizeZero ，将使用 240的大小
     *@param contentColor 二维码内容颜色，如果空，将使用 blackColor
     *@param backgroundColor 二维码背景颜色，如果空，将使用 whiteColor
     *@param logo 二维码 logo ,放在中心位置 ，logo的大小 根据 UIImage.size 来确定
     *@param logoSize logo 大小 0则表示是用图片大小
     *@return 成功返回二维码图片，否则nil
     */
    class func gkQRCodeImage(with string: String,
                             correctionLevel: QRCodeCorrectionLevel,
                             size: CGSize = CGSize(240, 240),
                             contentColor: UIColor = .black,
                             backgroundColor: UIColor = .white,
                             logo: UIImage?,
                             logoSize: CGSize = .zero) -> UIImage? {
        
        //通过coreImage生成默认的二维码图片
        if let data = string.data(using: .utf8), let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue(correctionLevel.rawValue, forKey: "inputCorrectionLevel")
            
            if let ciImage = filter.outputImage {
                //把它生成给定大小的图片
                let rect = ciImage.extent.integral
                let context = CIContext(options: nil)
                
                if let cgImage = context.createCGImage(ciImage, from: rect) {
                    
                    //获取实际生成的图片宽高
                    var width = cgImage.width
                    var height = cgImage.height
                    
                    //计算需要的二维码图片宽高比例
                    let w_scale = size.width / width.cgFloatValue
                    let h_scale = size.height / height.cgFloatValue
                    
                    width = (width.cgFloatValue * w_scale).intValue
                    height = (height.cgFloatValue * h_scale).intValue
                    
                    let bytesPerRow = width * 4 //每行字节数
                    //创建像素存储空间
                    let imageData = UnsafeMutablePointer<[UInt8]>.allocate(capacity: width * height)
                    defer {
                        imageData.deallocate()
                    }
                    
                    //创建位图
                    let colorSpace = CGColorSpaceCreateDeviceRGB()
                    
                    if let cx = CGContext(data: imageData,
                                          width: width,
                                          height: height,
                                          bitsPerComponent: 8,
                                          bytesPerRow: bytesPerRow,
                                          space: colorSpace,
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
                        cx.interpolationQuality = .none //设置二维码质量，否则二维码图片会变模糊，可无损放大
                        cx.scaleBy(x: w_scale, y: h_scale) //调整坐标系比例
                        cx.draw(cgImage, in: rect)
                        
                        //也可以使用 CIFalseColor 类型的滤镜来改变二维码背景颜色和二维码颜色
                        //如果二维码颜色不是黑色 并且背景不是白色 ，改变它的颜色
                        
                        if !contentColor.isEqualToColor(.black) || !backgroundColor.isEqualToColor(.white) {
                            //获取颜色的rgba值
                            let cARBG = contentColor.gkColorARGB()
                            let bARBG = backgroundColor.gkColorARGB()
                            
                            let c_red = (cARBG.red * 255).uInt8Value
                            let c_green = (cARBG.red * 255).uInt8Value
                            let c_blue = (cARBG.blue * 255).uInt8Value
                            let c_alpha = (cARBG.alpha * 255).uInt8Value
                            
                            let b_red = (bARBG.red * 255).uInt8Value
                            let b_green = (bARBG.red * 255).uInt8Value
                            let b_blue = (bARBG.blue * 255).uInt8Value
                            let b_alpha = (bARBG.alpha * 255).uInt8Value
                            
                            //遍历图片的像素并改变值，像素是一个二维数组， 每个像素由RGBA的数组组成，在数组中的排列顺序是从右到左即 array[0] 是 A阿尔法通道
                            var i = 0
                            for _ in 0 ..< height {
                                for _ in 0 ..< width {
                                    var ptr = imageData[i]
                                    if ptr[3] < 255 { //判断是否是背景像素，白色是背景
                                        ///改变二维码颜色
                                        ptr[3] = c_red;
                                        ptr[2] = c_green;
                                        ptr[1] = c_blue;
                                        ptr[0] = c_alpha;
                                    } else {
                                        //改变背景颜色
                                        ptr[3] = b_red;
                                        ptr[2] = b_green;
                                        ptr[1] = b_blue;
                                        ptr[0] = b_alpha;
                                    }
                                    imageData[i] = ptr
                                    i += 1
                                }
                            }
                        }
                        
                        if let qrImage = cx.makeImage() {
                            var image: UIImage? = UIImage(cgImage: qrImage)
                            
                            //绘制logo 没有锯齿
                            if let logo = logo {
                                var logoSize = logoSize
                                if logoSize.hasZeroOrNegative {
                                    logoSize = logo.size
                                }
                                
                                let size = CGSize(floor(image!.size.width), floor(image!.size.height))
                                UIGraphicsBeginImageContextWithOptions(size, false, UIImage.gkImageScale)
                                image!.draw(at: .zero)
                                logo.draw(in: CGRect((size.width - logoSize.width) / 2, (size.height - logoSize.height) / 2, logoSize.width, logoSize.height))
                                image = UIGraphicsGetImageFromCurrentImageContext()
                                UIGraphicsEndImageContext()
                            }
                            return image
                        }
                    }
                }
            }
        }
        return nil
    }
}
