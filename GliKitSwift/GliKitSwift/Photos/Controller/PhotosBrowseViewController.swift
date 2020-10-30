//
//  PhotosBrowseViewController.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/30.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import Kingfisher

///图片浏览信息
public struct PhotosBrowseImageSource {
    
    ///图片
    public let image: UIImage?
    
    ///图片路径
    public let url: URL?
    
    ///缩略图链接
    public let thumbnailUrl: URL?
    
    init(image: UIImage?, url: URL?, thumbnailUrl: URL?) {
        assert(image != nil || url != nil, "PhotosBrowseImageSource image or url are not nil")
        self.image = image
        self.url = url
        self.thumbnailUrl = thumbnailUrl
    }
}

///图片浏览代理
@objc public protocol PhotosBrowseViewControllerDelegate: NSObjectProtocol {
    
    ///将进入全屏
    @objc optional func photosBrowseViewControllerWillEnterFullScreen(_ viewController: PhotosBrowseViewController)
    
    ///已经进入全屏
    @objc optional func photosBrowseViewControllerDidEnterFullScreen(_ viewController: PhotosBrowseViewController)
    
    ///将退出全屏
    @objc optional func photosBrowseViewControllerWillExitFullScreen(_ viewController: PhotosBrowseViewController)
    
    ///已经退出全屏
    @objc optional func photosBrowseViewControllerDidExitFullScreen(_ viewController: PhotosBrowseViewController)
}

///图片放大浏览
public class PhotosBrowseViewController : CollectionViewController, PhotosBrowseCellDelegate {
    
    ///动画时长
    public var animateDuration: TimeInterval = 0.25
    
    ///图片间隔
    public var imageSpacing: CGFloat = 15
    
    ///图片信息
    public private(set) var sources: [PhotosBrowseImageSource]
    
    ///当前显示的图片下标
    public var _visibleIndex: Int = 0
    public private(set) var visibleIndex: Int{
        set{
            _visibleIndex = newValue
        }
        get{
            if let indexPath = collectionView.indexPathsForVisibleItems.first {
                return indexPath.item
            } else {
                return _visibleIndex
            }
        }
    }
    
    ///获取动画的视图，如果需要显示和隐藏动画， index 图片下标，将使用到view.frame 和 view.contentMode
    public var animatedViewCallback: ((_ index: Int) -> UIView)?
    
    ///代理
    public weak var delegate: PhotosBrowseViewControllerDelegate?
    
    ///是否正在动画
    private var isAnimating: Bool = false

    ///图片数量及正在显示的位置
    private let pageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 18)
        label.shadowColor = .black
        label.isHidden = true
        
        return label
    }()

    ///是否需要动画显示图片
    private var shouldShowAnimate: Bool = true

    ///背景
    private var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.isUserInteractionEnabled = false
        
        return view
    }()

    ///是否滑动到可见位置
    private var shouldScrollToVisible: Bool = true
    
    init(sources: [PhotosBrowseImageSource], visibleIndex: Int) {
        self.sources = sources
        _visibleIndex = visibleIndex
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = imageSpacing
        flowLayout.sectionInset = UIEdgeInsets(0, imageSpacing / 2, 0, imageSpacing / 2)
        flowLayout.itemSize = UIScreen.main.bounds.size
        
        container?.safeLayoutGuide = .none
        
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        view.backgroundColor = .clear
        
        registerClass(PhotosBrowseCell.self)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceVertical = false
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.leading.equalTo(-imageSpacing / 2)
            make.trailing.equalTo(imageSpacing / 2)
            make.top.bottom.equalTo(0)
        }
        
        pageLabel.text = "\(_visibleIndex + 1)/\(sources.count)"
        view.addSubview(pageLabel)
        pageLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(0)
            make.bottom.equalTo(gkSafeAreaLayoutGuideBottom).offset(-20)
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shouldScrollToVisible && _visibleIndex > 0 {
            shouldScrollToVisible = false
            collectionView.scrollToItem(at: IndexPath(item: visibleIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: - Public Method
    
    ///显示
    public func show(animated: Bool = true) {
        if let vc = UIApplication.shared.delegate?.window??.rootViewController?.gkTopestPresentedViewController {
            //设置使背景透明
            modalPresentationStyle = .overCurrentContext
            vc.present(self, animated: true, completion: nil)
            
            delegate?.photosBrowseViewControllerWillEnterFullScreen?(self)
            shouldShowAnimate = animated
            if !animated {
                showCompletion()
            }
        }
    }
    
    ///显示完成
    private func showCompletion() {
        delegate?.photosBrowseViewControllerDidEnterFullScreen?(self)
        view.isUserInteractionEnabled = true
        isAnimating = false
        pageLabel.isHidden = false
    }
    
    ///消失
    public func dismiss(animated: Bool = true) {
        
        if let cell = collectionView.visibleCells.first as? PhotosBrowseCell {
            backgroundView.isHidden = true
            pageLabel.isHidden = true
            
            let rect = animatedRect()
            if cell.imageView.image != nil && animated {
                delegate?.photosBrowseViewControllerWillExitFullScreen?(self)
                
                if !view.frame.intersects(rect) {
                    isAnimating = true
                    UIView.animate(withDuration: animateDuration) {
                        cell.scrollView.zoomScale = 1.5
                        self.view.alpha = 0
                    } completion: { (_) in
                        self.isAnimating = false
                        self.dismissCompletion()
                    }
                } else {
                    var contentMode: UIView.ContentMode = .scaleAspectFill
                    if animatedViewCallback != nil {
                        contentMode = animatedViewCallback!(visibleIndex).contentMode
                    }
                    
                    isAnimating = true
                    UIView.animate(withDuration: animateDuration) {
                        cell.imageView.frame = rect
                        cell.imageView.contentMode = contentMode
                        cell.imageView.clipsToBounds = true
                    } completion: { (_) in
                        self.isAnimating = false
                        self.dismissCompletion()
                    }
                }
            } else {
                dismissCompletion()
            }
        }
    }
    
    ///重新加载数据
    private func reloadData() {
        collectionView.reloadData()
    }

    ///获取当前动画需要的rect
    private func animatedRect() -> CGRect {
        if animatedViewCallback != nil {
            let view = animatedViewCallback!(visibleIndex)
            if view.superview != nil {
                return view.superview!.convert(view.frame, to: self.view)
            }
        }
        return .zero
    }

    private func dismissCompletion(){
        
        dismiss(animated: false) {
            self.delegate?.photosBrowseViewControllerDidExitFullScreen?(self)
        }
    }

    // MARK: - UICollectionViewDelegate

    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sources.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotosBrowseCell.gkNameOfClass, for: indexPath) as! PhotosBrowseCell
        cell.scrollView.zoomScale = 1.0
        cell.scrollView.contentSize = cell.bounds.size
        
        let source = sources[indexPath.item]
        if let image = source.image {
            cell.imageView.kf.cancelDownloadTask()
            cell.imageView.image = image
            if !shouldShowAnimate {
                cell.layoutImageAfterLoad(animated: false)
            }
        } else {
            
            let hasThumbnail: Bool = source.thumbnailUrl != nil && ImageCache.default.isCached(forKey: source.thumbnailUrl!.absoluteString)
            let hasImage: Bool = source.url != nil && ImageCache.default.isCached(forKey: source.url!.absoluteString)
            
            //加载缩率图
            if !hasImage && hasThumbnail {
                cell.imageView.kf.setImage(with: source.thumbnailUrl!, options: [.onlyFromCache], completionHandler:  { [weak self] (_) in
                    if let self = self, self.shouldShowAnimate {
                        cell.layoutImageAfterLoad(animated: false)
                    }
                })
                //有缩率图，加载原图时不要把缩率图清空
            }
            
            //加载原图
            cell.imageView.kf.setImage(with: source.url, options: [.keepCurrentImageWhileLoading], completionHandler: { [weak self] (result) in
                
                if let self = self, self.shouldShowAnimate {
                    switch result {
                    case .success(let value) :
                        cell.layoutImageAfterLoad(animated: value.cacheType == .none)
                        
                    case .failure(_) :
                        cell.layoutImageAfterLoad(animated: false)
                    }
                }
            })
        }
        cell.delegate = self
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if shouldShowAnimate {
            shouldShowAnimate = false
            
            var image: UIImage?
            let source = sources[indexPath.item]
            if source.image != nil {
                image = source.image
            } else {
                
                if let key = source.url?.absoluteString {
                    image = ImageCache.default.retrieveImageInMemoryCache(forKey: key)
                }
                if image == nil {
                    if let key = source.thumbnailUrl?.absoluteString {
                        image = ImageCache.default.retrieveImageInMemoryCache(forKey: key)
                    }
                }
            }
            
            if let image = image, let cell = cell as? PhotosBrowseCell {
                view.isUserInteractionEnabled = false
                let frame = cell.rectFromImage(image)
                let rect = animatedRect()
                cell.imageView.frame = rect
                
                isAnimating = true
                UIView.animate(withDuration: animateDuration) {
                    cell.imageView.image = image
                    cell.imageView.frame = frame
                } completion: { (_) in
                    cell.layoutImageAfterLoad(animated: false)
                    self.showCompletion()
                }

            } else {
                showCompletion()
            }
        }
        prefetchImage(for: indexPath.item - 1)
        prefetchImage(for: indexPath.item + 1)
    }

    ///预加载图片
    private func prefetchImage(for index: Int) {
        if index >= 0 && index < sources.count {
            if let url = sources[index].url {
                ImagePrefetcher(urls: [url]).start()
            }
        }
    }

    // MARK: - UIScrollViewDelegate

    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index: Int = floor(scrollView.bounds.minX / scrollView.gkWidth).intValue
        pageLabel.text = "\(index + 1)/\(sources.count)"
    }

    // MARK: - PhotosBrowseCellDelegate

    func photosBrowseCellDidClick(_ cell: PhotosBrowseCell) {
        if isAnimating {
            return
        }
        
        if cell.scrollView.zoomScale == cell.scrollView.minimumZoomScale {
            dismiss(animated: true)
        } else {
            cell.scrollView.setZoomScale(cell.scrollView.minimumZoomScale, animated: true)
        }
    }
}
