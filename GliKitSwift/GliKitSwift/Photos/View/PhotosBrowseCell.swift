//
//  PhotosBrowseCell.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/30.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import Kingfisher

///图片浏览cell代理
protocol PhotosBrowseCellDelegate: AnyObject {
    
    ///单击图片
    func photosBrowseCellDidClick(_ cell: PhotosBrowseCell)
}

///图片浏览cell
class PhotosBrowseCell: UICollectionViewCell, UIScrollViewDelegate {
    
    ///滚动视图，用于图片放大缩小
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.minimumZoomScale = 1.0;
        scrollView.maximumZoomScale = 5.0;
        scrollView.decelerationRate = .fast
        scrollView.scrollsToTop = false
        scrollView.bouncesZoom = true
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        
        return scrollView
    }()
    
    ///图片
    let imageView: UIImageView = UIImageView()
    
    ///代理
    weak var delegate: PhotosBrowseCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        scrollView.frame = self.bounds
        scrollView.delegate = self
        contentView.addSubview(scrollView)
        
        imageView.frame = self.bounds
        imageView.kf.indicatorType = .activity
        if let indicator = imageView.kf.indicator?.view as? UIActivityIndicatorView {
            if #available(iOS 13, *) {
                indicator.style = .large
                indicator.color = .white
            } else {
                indicator.style = .whiteLarge
            }
        }
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
    
    ///重新布局图片当图片加载完成时
    func layoutImageAfterLoad(animated: Bool) {
        var frame: CGRect
        let image = imageView.image
        if image != nil {
            frame = rectFromImage(image!)
            scrollView.contentSize = CGSize(scrollView.gkWidth, max(scrollView.gkHeight, imageView.gkHeight))
        } else {
            frame = CGRect(0, 0, scrollView.gkWidth, scrollView.gkHeight)
            scrollView.contentSize = .zero
        }
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.imageView.frame = frame
            }
        } else {
            self.imageView.frame = frame
        }
    }
    
    ///计算imageView的位置大小
    func rectFromImage(_ image: UIImage) -> CGRect {
        let size = image.gkFit(with: scrollView.frame.size, type: .width)
        return CGRect(max(0, (gkWidth - size.width) / 2.0), max((gkHeight - size.height) / 2.0, 0), size.width, size.height)
    }
    
    // MARK: - Action
    
    ///双击
    @objc private func handleDoubleTap() {
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
    
    @objc private func handleTap() {
        delegate?.photosBrowseCellDidClick(self)
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

