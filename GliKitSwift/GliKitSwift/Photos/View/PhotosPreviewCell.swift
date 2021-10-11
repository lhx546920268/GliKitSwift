//
//  PhotosPreviewCell.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/29.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import Photos.PHAsset

///代理
protocol PhotosPreviewCellDelegate: AnyObject {
    
    ///单击
    func photosPreviewCellDidClick(_ cell: PhotosPreviewCell)
}

///相册预览
class PhotosPreviewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    ///加载中
    public var loading: Bool = false {
        didSet{
            if oldValue != loading {
                if loading {
                    scrollView.zoomScale = 1.0
                    scrollView.contentSize = bounds.size
                    imageView.image = nil
                    indicatorView.startAnimating()
                } else {
                    indicatorView.stopAnimating()
                }
            }
        }
    }
    
    ///asset标识符
    public var asset: PHAsset?
    
    ///代理
    public weak var delegate: PhotosPreviewCellDelegate?
    
    ///图片
    private var imageView: UIImageView!

    ///滚动视图，用于图片放大缩小
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.minimumZoomScale = 1.0
        view.maximumZoomScale = 5.0
        view.decelerationRate = .fast
        view.scrollsToTop = false
        view.bouncesZoom = true
        
        return view
    }()

    ///加载菊花
    private lazy var indicatorView: UIActivityIndicatorView = {
        let view: UIActivityIndicatorView
        if #available(iOS 13, *) {
            view = UIActivityIndicatorView(style: .large)
        } else {
            view = UIActivityIndicatorView(style: .whiteLarge)
        }
        view.color = .white
        view.hidesWhenStopped = true
        contentView.addSubview(view)
        
        view.snp.makeConstraints { (make) in
            make.center.equalTo(contentView)
        }
        
        return view
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        scrollView.frame = bounds
        contentView.addSubview(scrollView)
        
        imageView = UIImageView(frame: bounds)
        scrollView.addSubview(imageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        tap.require(toFail: doubleTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///图片加载完成时
    public func onLoadImage(_ image: UIImage?) {
        loading = false
        if image != nil {
            imageView.frame = rectFromImage(image!)
            scrollView.contentSize = CGSize(scrollView.gkWidth, max(scrollView.gkHeight, imageView.gkHeight))
        }else{
            imageView.frame = CGRect(0, 0, scrollView.gkWidth, scrollView.gkHeight)
            scrollView.contentSize = .zero
        }
        self.imageView.image = image;
    }
    
    private func rectFromImage(_ image: UIImage) -> CGRect{
        
        if let _asset = asset {
            let size = UIImage.gkFitImageSize(CGSize(_asset.pixelWidth, _asset.pixelHeight), size: scrollView.frame.size)
            return CGRect(max(0, (bounds.width - size.width) / 2), max((bounds.size.height - size.height) / 2, 0), size.width, size.height)
        } else {
            return .zero
        }
    }
    
    // MARK: - Action
    
    @objc private func handleTap() {
        delegate?.photosPreviewCellDidClick(self)
    }
    
    @objc private func handleDoubleTap() {
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }

    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if imageView.image != nil {
            return imageView
        } else {
            return nil
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //缩放完后把视图居中
        var x: CGFloat = (gkWidth - imageView.gkWidth) / 2
        x = x < 0 ? 0 : x
        var y: CGFloat = (gkHeight - imageView.gkHeight) / 2
        y = y < 0 ? 0 : y
        
        imageView.center = CGPoint(x + imageView.gkWidth / 2.0, y + imageView.gkHeight / 2.0)
    }
}
