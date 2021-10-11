//
//  ImageCropViewController.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/30.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///图片裁剪
class ImageCropViewController: BaseViewController {

///裁剪框的位置 大小
    private var _cropFrame: CGRect?
    public var cropFrame: CGRect {
        if _cropFrame == nil {
            var size = cropSettings.cropSize
            if cropSettings.useFullScreenCropFrame {
                size = CGSize(view.gkWidth, view.gkWidth * size.height / size.width)
            }
            _cropFrame = CGRect((view.gkWidth - size.width) / 2, (view.gkHeight - size.height) / 2, size.width, size.height)
        }
        return _cropFrame!
    }

    ///图片相框
    private let showImageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.isMultipleTouchEnabled = true
        
        return view
    }()

    ///图片裁剪的部分控制图层，不被裁剪的部分会覆盖黑色半透明
    private let overlayView: UIView = {
        let view = UIView()
        view.alpha = 0.5
        view.backgroundColor = .black
        view.isUserInteractionEnabled = false
        
        return view
    }()

    ///裁剪框
    private let ratioView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1.0
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = false
        
        return view
    }()

    ///图片的起始位置大小
    private var oldFrame: CGRect!

    ///图片的可以放大的最大尺寸
    private var largeFrame: CGRect!

    ///当前图片位置大小
    private var latestFrame: CGRect!

    ///取消按钮
    private let cancelButton: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleShadowColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17)
        btn.contentEdgeInsets = UIEdgeInsets(10, UIApplication.gkNavigationBarMargin, 10, UIApplication.gkNavigationBarMargin)
        btn.setTitle("取消", for: .normal)
        
        return btn
    }()

    ///确认按钮
    private let confirmButton: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleShadowColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17)
        btn.contentEdgeInsets = UIEdgeInsets(10, UIApplication.gkNavigationBarMargin, 10, UIApplication.gkNavigationBarMargin)
        btn.setTitle("使用", for: .normal)
        
        return btn
    }()

    ///选项
    private var photosOptions: PhotosOptions
    
    ///裁剪选项
    private var cropSettings: ImageCropSettings {
        photosOptions.cropSettings!
    }

    init(options: PhotosOptions) {
        photosOptions = options
        super.init(nibName: nil, bundle: nil)
        
        assert(!cropSettings.cropSize.hasZeroOrNegative, "Invalid CropSize, ImageCropSettings cropSize must greater than zero")
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 加载视图

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigatonBarHidden(true, animated: false)
        view.clipsToBounds = true
        view.backgroundColor = .black
        gkShowBackItem = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initViews()
    }

    //初始化视图
    private func initViews()
    {
        if showImageView.superview != nil {
            return
        }
        
        let image = cropSettings.image!
        let cropFrame = self.cropFrame
        
        //显示图片
        showImageView.image = image
        
        //把图片适配屏幕
        var width: CGFloat = min(view.gkWidth, image.size.width)
        var height: CGFloat = image.size.height * (width / image.size.width)
        
        if cropSettings.useFullScreenCropFrame {
            if width < cropFrame.width || height < cropFrame.height {
                let scale: CGFloat = max(cropFrame.width / width, cropFrame.height / height)
                width *= scale
                height *= scale
            }
        }
        
        
        let x: CGFloat = cropFrame.minX + (cropFrame.width - width) / 2
        let y: CGFloat = cropFrame.minY + (cropFrame.height - height) / 2
        
        oldFrame = CGRect(x, y, width, height)
        latestFrame = oldFrame
        showImageView.frame = oldFrame
        
        largeFrame = CGRect(0, 0, cropSettings.limitRatio * oldFrame.width, cropSettings.limitRatio * oldFrame.height)
        
        //添加捏合缩放手势
        view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:))))
        
        //添加平移手势
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
        
        view.addSubview(showImageView)
        
        //裁剪区分图层
        overlayView.frame = view.bounds
        view.addSubview(overlayView)
        
        //编辑框
        var radius = cropSettings.cropCornerRadius
        if cropSettings.useFullScreenCropFrame {
            radius *= cropFrame.width / cropSettings.cropSize.width
        }
        ratioView.layer.cornerRadius = radius
        ratioView.frame = cropFrame
        view.addSubview(ratioView)
        
        overlayClipping()
        initControlBtn()
    }
    
    //绘制裁剪区分图层
    private func overlayClipping() {
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        
        if cropSettings.cropCornerRadius == 0 {
            //编辑框左边
            path.addRect(CGRect(0, 0, ratioView.gkLeft, overlayView.gkHeight))
            
            //编辑框右边
            path.addRect(CGRect(ratioView.gkRight, 0, overlayView.gkWidth - ratioView.gkRight, overlayView.gkHeight))
    
            //编辑框上面
            path.addRect(CGRect(0, 0, overlayView.gkWidth, ratioView.gkTop))

            //编辑框下面
            path.addRect(CGRect(0, ratioView.gkBottom, overlayView.gkWidth, overlayView.gkHeight - ratioView.gkBottom))
        } else {
            let point1 = CGPoint(0, ratioView.gkCenterY)
            let point2 = CGPoint(ratioView.gkWidth, ratioView.gkCenterY)
            
            let path1 = CGMutablePath()
            path1.move(to: point1)
            path1.addLine(to: CGPoint(0, 0))
            path1.addLine(to: CGPoint(ratioView.gkWidth, 0))
            path1.addLine(to: point2)
            path1.addArc(center: CGPoint(ratioView.gkWidth / 2, point1.y), radius: ratioView.gkWidth / 2, startAngle: 0, endAngle: CGFloat.pi, clockwise: true)
            
            path.addPath(path1)
            
            let path2 = CGMutablePath()
            path2.move(to: point1)
            path2.addLine(to: CGPoint(0, overlayView.gkHeight))
            path2.addLine(to: CGPoint(ratioView.gkWidth, overlayView.gkHeight))
            path2.addLine(to: point2)
            path2.addArc(center: CGPoint(ratioView.gkWidth / 2, point1.y), radius: ratioView.gkWidth / 2, startAngle: 0, endAngle: CGFloat.pi, clockwise: false)
            
            path.addPath(path2)
        }

        maskLayer.path = path
        overlayView.layer.mask = maskLayer
    }

    //初始化控制按钮
    private func initControlBtn(){
        cancelButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.leading.equalTo(0)
            make.bottom.equalTo(gkSafeAreaLayoutGuideBottom)
        }
       
        confirmButton.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(0)
            make.bottom.equalTo(gkSafeAreaLayoutGuideBottom)
        }
    }

    // MARK: - Action

    private var showProgress: Bool = false {
        didSet{
            if oldValue != showProgress {
                if showProgress {
                    gkShowLoadingToast()
                } else {
                    gkDismissLoadingToast()
                }
            }
        }
    }

    ///取消
    @objc private func handleCancel(){
        gkBack()
    }

    ///确认编辑
    @objc private func handleConfirm() {
        let image = cropImage()
        
        if !photosOptions.compressedImageSize.bothZeroOrNegative || !photosOptions.thumbnailSize.bothZeroOrNegative {
            showProgress = true
            DispatchQueue.global(qos: .default).async {
                let result = PhotosPickResult(image: image, options: self.photosOptions)
                DispatchQueue.main.async {
                    self.onCropImage(result)
                }
            }
        } else {
            onCropImage(PhotosPickResult(image: image, options: self.photosOptions))
        }
    }

    ///裁剪完成
    private func onCropImage(_ result: PhotosPickResult) {
        showProgress = false
        photosOptions.completion?([result])
        
        if let viewControllers = navigationController?.viewControllers, viewControllers.count >= 2 {
            let count = viewControllers.count
            if viewControllers[count - 2] is PhotosGridViewController {
                if count > 3 {
                    navigationController?.popToViewController(viewControllers[count - 3], animated: true)
                } else {
                    gkBack()
                }
            } else {
                gkBack()
            }
        } else {
            gkBack()
        }
    }

    // MARK: - Gesture

    ///图片捏合缩放
    @objc private func handlePinch(_ pinch: UIPinchGestureRecognizer) {
        switch pinch.state {
        case .began, .changed :
            showImageView.transform = showImageView.transform.scaledBy(x: pinch.scale, y: pinch.scale)
            pinch.scale = 1
            
        case .ended :
            var frame = showImageView.frame
            frame = handleScaleOverflow(frame)
            frame = handleBorderOverflow(frame)
            
            UIView.animate(withDuration: 0.25) {
                self.showImageView.frame = frame
                self.largeFrame = frame
            }
            
        default:
            break
        }
    }

    ///图片平移
    @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began, .changed :
            let absCenterX = cropFrame.midX
            let absCenterY = cropFrame.midY
            let widthScale = showImageView.gkWidth / cropFrame.width
            let heightScale = showImageView.gkHeight / cropFrame.height
            
            let acceleratorX: CGFloat = 1 - abs(absCenterX - showImageView.gkCenterX) / (widthScale * absCenterX)
            let acceleratorY: CGFloat = 1 -  abs(absCenterY - showImageView.gkCenterY) / (heightScale * absCenterY)
            
            let translation = pan.translation(in: showImageView.superview)
            
            showImageView.center = CGPoint(showImageView.gkCenterX + translation.x * acceleratorX, showImageView.gkCenterY + translation.y * acceleratorY)
            pan.setTranslation(.zero, in: showImageView.superview)
            
        case .ended :
            var frame = showImageView.frame
            frame = handleBorderOverflow(frame)
            UIView.animate(withDuration: 0.25) {
                self.showImageView.frame = frame
                self.latestFrame = frame
            }
            
        default:
            break
        }
    }

    ///控制图片的缩放大小
    private func handleScaleOverflow(_ frame: CGRect) -> CGRect {
        var _frame = frame
        let center = frame.center
        if frame.width < oldFrame.width {
            _frame = oldFrame
        }
        if _frame.width > largeFrame.width {
            _frame = largeFrame
        }
        _frame.origin.x = center.x - _frame.width / 2
        _frame.origin.y = center.y - _frame.height / 2
        
        return frame
    }

    ///控制平移的范围，不让图片超出编辑框
    private func handleBorderOverflow(_ frame: CGRect) -> CGRect {
        
        var _frame = frame
        
        //水平方向
        if _frame.midX > cropFrame.midX {
            _frame.origin.x = cropFrame.midX
        }
        
        if _frame.maxX < cropFrame.maxX {
            _frame.origin.x = cropFrame.maxX - _frame.width
        }
        
        //垂直方向
        if _frame.midY > cropFrame.midY {
            _frame.origin.y = cropFrame.midY
        }
        
        if _frame.maxY < cropFrame.maxY {
            _frame.origin.y = cropFrame.maxY - _frame.height
        }
        
        //图片小于裁剪框 让图片居中
        if _frame.height < cropFrame.height {
            _frame.origin.y = cropFrame.midY + (cropFrame.height - _frame.height ) / 2
        }
        
        if _frame.width < cropFrame.width {
            _frame.origin.x = cropFrame.midX + (cropFrame.width - _frame.width) / 2
        }
        
        return _frame
    }

    //裁剪图片
    private func cropImage() -> UIImage {
        
        //隐藏编辑框和控制按钮
        overlayView.isHidden = true
        ratioView.isHidden = true
        cancelButton.isHidden = true
        confirmButton.isHidden = true
        
        //裁剪图片
        let height = view.gkHeight
        UIGraphicsBeginImageContextWithOptions(CGSize(UIScreen.gkWidth, height), false, 2.0)
        defer {
            UIGraphicsEndImageContext()
        }
        
        if let context = UIGraphicsGetCurrentContext() {
            view.layer .render(in: context)
            
            //如果图片小于编辑框，使用白色背景替代
            if showImageView.gkWidth < cropFrame.width || showImageView.gkHeight < cropFrame.height {
                UIColor.white.setFill()
            }
            
            if let image = UIGraphicsGetImageFromCurrentImageContext(), let cgImage = image.cgImage {
                
                let scale = image.scale
                let rect = CGRect(
                    floor(cropFrame.midX * scale),
                    floor(cropFrame.midY * scale),
                    floor(cropFrame.width * scale),
                    floor(cropFrame.height * scale)) //这里可以设置想要截图的区域
                
                if let cropImage = cgImage.cropping(to: rect) {
                    var result = UIImage(cgImage: cropImage)
                    
                    if result.size.width > cropSettings.cropSize.width {
                        result = result.gkAspectFill(with: cropSettings.cropSize)
                    }
                    
                    return result
                }
            }
        }
        
        return UIImage()
    }
}
