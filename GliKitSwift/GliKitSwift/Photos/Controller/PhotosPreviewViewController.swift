//
//  PhotosPreviewViewController.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/29.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import Photos

///相册预览
class PhotosPreviewViewController: CollectionViewController, PhotosPreviewCellDelegate {
    
    ///图片间隔
    public var imageSpacing: CGFloat = 15
    
    ///选项
    public var photosOptions: PhotosOptions
    
    ///资源信息
    public var assets: [PHAsset]
    
    //选中的图片
    public var selectedAssets: NSMutableArray
    
    ///当前可见下标
    public var visiableIndex: Int
    
    ///底部工具条
    private let photosToolBar: PhotosToolBar = {
        let toolBar = PhotosToolBar()
        toolBar.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        toolBar.previewButton.isHidden = true
        toolBar.divider.isHidden = true
        toolBar.countLabel.textColor = .white
        toolBar.useButton.setTitleColor(.white, for: .normal)
        
        return toolBar
    }()
    
    ///加载图片选项
    private let imageRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        
        return options
    }()
    
    ///选中
    private var checkBox: PhotosCheckBox!
    
    ///标题
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .center
        
        return label
    }()
    
    ///当前下标
    private var selectedIndex: Int{
        floor(max(0, collectionView.contentOffset.x) / UIScreen.gkWidth).intValue
    }
    
    init(options: PhotosOptions, assets: [PHAsset], selectedAssets: NSMutableArray, visiableIndex: Int) {
        self.photosOptions = options
        self.assets = assets
        self.selectedAssets = selectedAssets
        self.visiableIndex = visiableIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setNavigatonBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gkBackBarButtonItem?.customView?.tintColor = .white
        navigatonBar?.backgroundColor = photosToolBar.backgroundColor
        view.backgroundColor = .black
        
        initViews()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func initViews() {
        container?.safeLayoutGuide = .none
        
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = imageSpacing
        flowLayout.sectionInset = UIEdgeInsets(0, imageSpacing / 2, 0, imageSpacing / 2)
        
        registerClass(PhotosPreviewCell.self)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        super.initViews()
        
        let size = gkNavigationBarHeight
        checkBox = PhotosCheckBox(frame: CGRect(0, 0, size - UIApplication.gkNavigationBarMargin * 2 + 6, size))
        checkBox.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCheck)))
        checkBox.contentInsets = UIEdgeInsets(10, UIApplication.gkNavigationBarMargin, 10, UIApplication.gkNavigationBarMargin)
        gkSetRightItem(customView: checkBox)
        
        titleLabel.frame = CGRect(0, 0, 100, gkNavigationBarHeight)
        navigationItem.titleView = titleLabel
        
        photosToolBar.useButton.addTarget(self, action: #selector(handleUse), for: .touchUpInside)
        view.addSubview(photosToolBar)
        photosToolBar.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(0)
        }
        
        updateTitle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if visiableIndex > 0 && visiableIndex < assets.count {
            collectionView.scrollToItem(at: IndexPath(item: visiableIndex, section: 0), at: .centeredHorizontally, animated: false)
            visiableIndex = 0
            updateTitle()
        }
    }
    
    // MARK: - action
    
    ///设置工具条隐藏
    private func setToolBarAndHeaderHidden(_ hidden: Bool) {
        if !hidden {
            photosToolBar.isHidden = hidden
        }
        setNavigatonBarHidden(hidden, animated: true)
        UIView.animate(withDuration: UINavigationController.hideShowBarDuration.doubleValue) {
            self.photosToolBar.gkBottomLayoutConstraint?.constant = hidden ? self.photosToolBar.gkHeight : 0
            self.view.layoutIfNeeded()
        } completion: { (_) in
            self.photosToolBar.isHidden = hidden
        }
        
    }
    
    //选中
    @objc private func handleCheck() {
        let asset = assets[selectedIndex]
        if checkBox.checked {
            checkBox.setChecked(false)
            removeAsset(asset)
        }else{
            if selectedAssets.count >= photosOptions.maxCount {
                AlertUtils.showAlert(
                    title: "您最多能选择\(photosOptions.maxCount)张图片",
                    buttonTitles: ["我知道了"])
                
            } else {
                selectedAssets.add(asset)
                checkBox.checkedText = selectedAssets.count.toString
                checkBox.setChecked(true, animated: true)
            }
        }
        photosToolBar.count = selectedAssets.count
    }
    
    ///使用
    @objc private func handleUse() {
        gkShowLoadingToast()
        gkBackBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        var datas: [Data] = []
        var totalCount = selectedAssets.count
        for asset in selectedAssets {
            if let _asset = asset as? PHAsset {
                PHImageManager.default().requestImageData(for: _asset, options: nil) { (data, _, _, _) in
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
    
    ///更新标题
    private func updateTitle() {
        titleLabel.text = "\(selectedIndex + 1)/\(assets.count)"
        let asset = assets[selectedIndex]
        if containAsset(asset) {
            checkBox.checkedText = (indexOfAsset(asset) + 1).toString
            checkBox.setChecked(true)
        } else {
            checkBox.setChecked(false)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateTitle()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateTitle()
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(collectionView.gkWidth - imageSpacing, collectionView.gkHeight)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotosPreviewCell.gkNameOfClass, for: indexPath) as! PhotosPreviewCell
        
        cell.loading = true
        cell.delegate = self
        
        let asset = assets[indexPath.item]
        cell.asset = asset
        
        let size = UIImage.gkFitImageSize(CGSize(asset.pixelWidth, asset.pixelHeight), size: CGSize(collectionView.gkWidth * photosOptions.scale, 0))
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: imageRequestOptions) { (image, _) in
            if asset.localIdentifier == cell.asset?.localIdentifier {
                cell.onLoadImage(image)
            }
        }
        
        return cell
    }
    
    func photosPreviewCellDidClick(_ cell: PhotosPreviewCell) {
        setToolBarAndHeaderHidden(!photosToolBar.isHidden)
    }
}
