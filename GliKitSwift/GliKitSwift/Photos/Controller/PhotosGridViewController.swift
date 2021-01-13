//
//  PhotosGridViewController.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/29.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import Photos

///相册网格列表
class PhotosGridViewController : CollectionViewController, PhotosGridCellDelegate {

///资源信息
    public let collection: PhotosCollection

///选项
    public let photosOptions: PhotosOptions
    
    //选中的图片
    public let selectedAssets: NSMutableArray = []

    ///图片管理
    private var imageManager: PHCachingImageManager?

    ///上一个预缓存的区域
    private var previousPrecachingRect: CGRect = .zero

    ///停止缓存的
    private var stopCachingAssets: [PHAsset] = []

    ///开始缓存的
    private var startCachingAssets: [PHAsset] = []

    ///底部工具条
    public private(set) lazy var photosToolBar: PhotosToolBar = {
        let toolBar = PhotosToolBar()
        toolBar.useButton.addTarget(self, action: #selector(handleUse), for: .touchUpInside)
        toolBar.previewButton.addTarget(self, action: #selector(handlePreview), for: .touchUpInside)
        
        return toolBar
    }()
    
    init(options: PhotosOptions, collection: PhotosCollection) {
        self.photosOptions = options
        self.collection = collection
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateAssetCaches()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isInit {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if navigationController?.presentingViewController != nil {
            gkSetRightItem(title: "取消", action: #selector(handleCancel))
        }
        
        navigationItem.title = collection.title
        initViews()
    }

    deinit {
        imageManager?.stopCachingImagesForAllAssets()
    }

    override func initViews() {
        var bottomView: UIView? = nil
        var tipButton: UIButton? = nil
        
        if #available(iOS 14, *) {
            if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
                
                let title = "无法访问您的照片，请在本机的“设置-隐私-照片”中设置,允许\(AppUtils.appName)访问您的照片"
                let btn = UIButton()
                btn.setTitle(title, for: .normal)
                btn.setTitleColor(.gkThemeTintColor, for: .normal)
                btn.backgroundColor = .gkThemeColor
                btn.titleLabel?.font = .systemFont(ofSize: 13)
                btn.titleLabel?.numberOfLines = 0
                btn.contentHorizontalAlignment = .left
                btn.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
                
                var insets: UIEdgeInsets = .all(15)
                if photosOptions.intention == .multiSelection {
                    insets.bottom += UIApplication.shared.delegate?.window??.gkSafeAreaInsets.bottom ?? 0
                    bottomView = btn
                } else {
                    bottomView = UIView()
                    bottomView?.addSubview(btn)
                    btn.snp.makeConstraints { (make) in
                        make.leading.top.trailing.equalTo(0)
                    }
                }
                btn.contentEdgeInsets = insets
                tipButton = btn
            }
        }
        
        if photosOptions.intention == .multiSelection {
            if bottomView != nil {
                bottomView?.addSubview(photosToolBar)
                photosToolBar.snp.makeConstraints { (make) in
                    make.leading.trailing.bottom.equalTo(0)
                    make.top.equalTo(tipButton!.snp.bottom)
                }
            } else {
                bottomView = photosToolBar
            }
        }
        
        self.bottomView = bottomView
        
        //要授权才调用
        if AppUtils.hasPhotosAuthorization {
            imageManager = PHCachingImageManager()
            imageManager?.allowsCachingHighQualityImages = false
        }
        
        let spacing = photosOptions.gridSpacing
        flowLayout.minimumLineSpacing = spacing
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.sectionInset = .all(spacing)
        
        let row: CGFloat = photosOptions.numberOfItemsPerRow.cgFloatValue
        let size: CGFloat = floor((UIScreen.gkWidth - (row + 1) * spacing) / row)
        flowLayout.itemSize = CGSize(size, size)
        
        registerClass(PhotosGridCell.self)
        collectionView.gkShouldShowEmptyView = true
        
        super.initViews()
        if collection.assets.count > 0 {
            collectionView.scrollToItem(at: IndexPath(item: collection.assets.count - 1, section: 0), at: .bottom, animated: false)
        }
    }

    // MARK: - action

    @objc private func handleSettings() {
        AppUtils.openSettings()
    }

    ///取消
    @objc private func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    ///预览
    @objc private func handlePreview() {
        let vc = PhotosPreviewViewController(
            options: photosOptions,
            assets: Array(_immutableCocoaArray: selectedAssets),
            selectedAssets: selectedAssets,
            visiableIndex: 0)
        navigationController?.pushViewController(vc, animated: true)
    }

    ///使用
    @objc private func handleUse() {
        useAssets(Array(_immutableCocoaArray: selectedAssets))
    }

    ///使用图片
    private func useAssets(_ assets: [PHAsset]) {
        gkShowLoadingToast()
        gkBackBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        var datas: [Data] = []
        var totalCount = assets.count
        for asset in assets {
            PHImageManager.default().requestImageData(for: asset, options: nil) { (data, _, _, _) in
                totalCount -= 1
                if data != nil {
                    datas.append(data!)
                }
                
                if totalCount <= 0 {
                    self.onImageDataLoad(datas)
                }
            }
        }
    }

    ///图片加载完成
    private func onImageDataLoad(_ datas: [Data]) {
        var results: [PhotosPickResult] = []
        DispatchQueue.global(qos: .default).async {
            for data in datas {
                if let result = PhotosPickResult(data: data, options: self.photosOptions) {
                    results.append(result)
                }
            }
            
            DispatchQueue.main.async {
                self.gkDismissLoadingToast()
                self.photosOptions.completion?(results)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    ///裁剪图片
    private func cropImage(asset: PHAsset) {
        gkShowLoadingToast()
        gkBackBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        imageManager?.requestImageData(for: asset, options: nil, resultHandler: { (data, _, _, _) in
            self.gkBackBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            
            if data != nil {
                self.gkDismissLoadingToast()
                self.photosOptions.cropSettings?.image = UIImage(data: data!, scale: self.photosOptions.scale)
                self.goToCropImage()
            } else {
                self.gkShowErrorText("加载图片失败")
            }
        })
    }

    ///跳转去图片裁剪界面
    private func goToCropImage() {
        let vc = ImageCropViewController(options: photosOptions)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - 操作

    ///是否选中asset
    private func containAsset(_ asset: PHAsset) -> Bool {
        for _asset in selectedAssets {
            if let _asset = _asset as? PHAsset {
                if asset.localIdentifier == _asset.localIdentifier {
                    return true
                }
            }
        }
        return false
    }
    
    ///删除某个asset
    private func removeAsset(_ asset: PHAsset) {
        var index: Int = NSNotFound
        for i in 0 ..< selectedAssets.count {
            if let _asset = selectedAssets[i] as? PHAsset {
                if asset.localIdentifier == _asset.localIdentifier {
                    index = i
                    break
                }
            }
        }
        if index < selectedAssets.count {
            selectedAssets.removeObject(at: index)
        }
    }
    
    ///获取某个asset的下标
    private func indexOfAsset(_ asset: PHAsset) -> Int{
        for i in 0 ..< selectedAssets.count {
            if let _asset = selectedAssets[i] as? PHAsset {
                if asset.localIdentifier == _asset.localIdentifier {
                    return i
                }
            }
        }
        
        return NSNotFound;
    }

    // MARK: - GKEmptyViewDelegate

    override func emptyViewWillAppear(_ view: EmptyView) {
        view.textLabel.text = "暂无照片信息"
    }

    // MARK: - caching

    ///更新缓存
    private func updateAssetCaches() {
        
        if isViewLoaded && view.window != nil && collection.assets.count > 0 {
            
            let size: CGSize = collectionView.bounds.size
            let visibleRect: CGRect = CGRect(collectionView.contentOffset, size)
            let precachingRect: CGRect = visibleRect.insetBy(dx: 0, dy: -size.height / 2)
            
            //滑动距离太短
            if abs(precachingRect.midY - previousPrecachingRect.midY) < size.height / 3 {
                return
            }
            
            stopCachingAssets.removeAll()
            startCachingAssets.removeAll()
            
            var stopCachingRect = previousPrecachingRect
            var startCachingRect = precachingRect
            
            //两个区域相交，移除后面的，保留中间交叉的，添加前面的
            if precachingRect.intersects(previousPrecachingRect) {
                if previousPrecachingRect.minY < precachingRect.minY {
                    //向下滑动
                    stopCachingRect = CGRect(0, precachingRect.minY, size.width, previousPrecachingRect.minY - precachingRect.minY)
                    startCachingRect = CGRect(0, previousPrecachingRect.maxY, size.width, precachingRect.maxY - previousPrecachingRect.maxY)
                } else {
                    //向上滑动
                    stopCachingRect = CGRect(0, precachingRect.maxY, size.width, previousPrecachingRect.maxY - precachingRect.maxY)
                    startCachingRect = CGRect(0, precachingRect.minY, size.width, previousPrecachingRect.minY - precachingRect.minY)
                }
            }
            
            if stopCachingRect.height > 0 {
                if let attrs = flowLayout.layoutAttributesForElements(in: stopCachingRect) {
                    for attr in attrs {
                        stopCachingAssets.append(collection.assets[attr.indexPath.item])
                    }
                }
            }
            
            if startCachingRect.height > 0 {
                if let attrs = flowLayout.layoutAttributesForElements(in: startCachingRect) {
                    for attr in attrs {
                        stopCachingAssets.append(collection.assets[attr.indexPath.item])
                    }
                }
            }
            
            if stopCachingAssets.count > 0 {
                imageManager?.stopCachingImages(for: stopCachingAssets, targetSize: flowLayout.itemSize, contentMode: .aspectFill, options: nil)
            }
            
            if startCachingAssets.count > 0 {
                imageManager?.startCachingImages(for: startCachingAssets, targetSize: flowLayout.itemSize, contentMode: .aspectFill, options: nil)
            }
            previousPrecachingRect = precachingRect
        }
    }

    // MARK: - UIScrollViewDelegate

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateAssetCaches()
    }

    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collection.assets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotosGridCell.gkNameOfClass, for: indexPath) as! PhotosGridCell
        let asset = collection.assets[indexPath.item]
        
        if photosOptions.intention == .multiSelection {
            cell.checkBox.isHidden = false
            cell.setChecked(containAsset(asset))
            
            if cell.checkBox.checked {
                cell.checkBox.checkedText = (indexOfAsset(asset) + 1).toString
            } else {
                cell.checkBox.checkedText = nil
            }
        } else {
            cell.checkBox.isHidden = true
        }
        
        cell.delegate = self
        cell.asset = asset
        
        imageManager?.requestImage(for: asset, targetSize: flowLayout.itemSize, contentMode: .aspectFill, options: nil, resultHandler: { (image, _) in
            if asset.localIdentifier == cell.asset?.localIdentifier {
                cell.imageView.image = image
                if image != nil {
                    cell.imageView.backgroundColor = .clear
                } else {
                    cell.imageView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
                }
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        switch photosOptions.intention {
        case .multiSelection :
            let vc = PhotosPreviewViewController(
                options: photosOptions,
                assets: Array(_immutableCocoaArray: collection.assets),
                selectedAssets: selectedAssets,
                visiableIndex: indexPath.item)
            navigationController?.pushViewController(vc, animated: true)
            
        case .crop :
            cropImage(asset: collection.assets[indexPath.item])
            
        case .singleSelection :
            useAssets([collection.assets[indexPath.item]])

        }
    }

    // MARK: - PhotosGridCellDelegate

    func photosGridCellCheckedDidChange(_ cell: PhotosGridCell) {
        
        if cell.checkBox.checked {
            cell.checkBox.setChecked(false)
            removeAsset(cell.asset!)
            
            //reloadData 图片会抖动 所以只刷新选中下标
            let indexPaths = collectionView.indexPathsForVisibleItems
            for indexPath in indexPaths {
                if let cell = collectionView.cellForItem(at: indexPath) as? PhotosGridCell {
                    let asset = collection.assets[indexPath.item]
                    cell.setChecked(containAsset(asset))
                    
                    if cell.checkBox.checked {
                        cell.checkBox.checkedText = (indexOfAsset(asset) + 1).toString
                    } else {
                        cell.checkBox.checkedText = nil
                    }
                }
            }
        } else {
            if selectedAssets.count > photosOptions.maxCount {
                AlertUtils.showAlert(
                    title: "您最多能选择\(photosOptions.maxCount)张图片",
                    buttonTitles: ["我知道了"])
            } else {
                selectedAssets.add(cell.asset!)
                cell.checkBox.checkedText = selectedAssets.count.toString
                cell.setChecked(true, animated: true)
            }
        }
        photosToolBar.count = selectedAssets.count
    }
}
