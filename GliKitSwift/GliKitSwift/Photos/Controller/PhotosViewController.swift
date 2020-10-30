//
//  PhotosViewController.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/29.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import Photos

///相册
public class PhotosViewController: TableViewController {

///选项
    public var photosOptions: PhotosOptions
    
    ///所有图片
    private var allPhotos: PHFetchResult<PHAsset>?

    ///智能相册
    private var smartAlbums: PHFetchResult<PHAssetCollection>?

    ///用户自定义相册
    private var userAlbums: PHFetchResult<PHCollection>?

    ///列表信息
    private var datas: [PhotosCollection]?

    ///相册资源获取选项
    private lazy var fetchOptions: PHFetchOptions = {
       let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        return options
    }()

    ///图片管理
    private var imageManager: PHCachingImageManager?
    
    init(options: PhotosOptions? = nil) {
        if options == nil {
            photosOptions = PhotosOptions()
        } else {
            photosOptions = options!
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isInit && datas?.count ?? 0 > 0 {
            initViews()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if navigationController?.presentingViewController != nil {
            gkSetRightItem(title: "取消", action: #selector(handleCancel))
        }
        
        navigationItem.title = "相册"
        gkReloadData()
    }

    deinit {
        imageManager?.stopCachingImagesForAllAssets()
    }

    public override func initViews() {
        //要授权才调用
        if AppUtils.hasPhotosAuthorization {
            imageManager = PHCachingImageManager()
            imageManager?.allowsCachingHighQualityImages = false
        }
        
        gkShowPageLoading = false
        registerClass(PhotosListCell.self)
        tableView.separatorStyle = .none
        tableView.rowHeight = 70
        tableView.gkShouldShowEmptyView = true
        
        super.initViews()
    }

    // MARK: - action

    ///取消
    @objc private func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - GKEmptyViewDelegate

    public override func emptyViewWillAppear(_ view: EmptyView) {
        var msg: String
        if !AppUtils.hasPhotosAuthorization {
            msg = "无法访问您的照片，请在本机的“设置-隐私-照片”中设置,允许\(AppUtils.appName)访问您的照片"
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSettings)))
        } else {
            msg = "暂无照片信息"
        }
        view.textLabel.text = msg
    }

    @objc private func handleSettings() {
        AppUtils.openSettings()
    }

    // MARK: - load

    public override func gkReloadData() {
        super.gkReloadData()
        gkShowPageLoading = true
        
        AppUtils.requestPhotosAuthorization { [weak self] (hasAuth) in
            if hasAuth {
                self?.loadPhotos()
            } else {
                self?.initViews()
            }
        }
    }

    ///加载相册信息
    private func loadPhotos() {
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            var onlyAllPhotos = false
            if #available(iOS 14, *) {
                onlyAllPhotos = AppUtils.photosAuthorizationStatus == .limited
            }
            
            if onlyAllPhotos {
                self?.allPhotos = PHAsset.fetchAssets(with: .image, options: self?.fetchOptions)
            } else {
                if self?.photosOptions.shouldDisplayAllPhotos ?? false {
                    self?.allPhotos = PHAsset.fetchAssets(with: .image, options: self?.fetchOptions)
                }
                
                self?.smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
                self?.userAlbums = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            }
            
            DispatchQueue.main.async {
                self?.generateDatas()
            }
        }
    }

    ///生成列表数据
    private func generateDatas() {
        datas = []
        if allPhotos?.count ?? 0 > 0 {
            var onlyAllPhotos = false
            if #available(iOS 14, *) {
                onlyAllPhotos = AppUtils.photosAuthorizationStatus == .limited
            }
            
            let title: String = onlyAllPhotos ? "可访问的图片": "所有图片"
            datas!.append(PhotosCollection(title: title, assets: allPhotos!))
        }
       
        addAssets(from: smartAlbums)
        addAssets(from: userAlbums)
        
        if isInit {
            tableView.reloadData()
        }
        
        if photosOptions.displayFistCollection && !datas!.isEmpty  {
            let vc = PhotosGridViewController(options: photosOptions, collection: datas!.first!)
            navigationController?.viewControllers = [self, vc]
        } else {
            if !isInit {
                initViews()
            }
        }
    }

    ///添加相册资源信息
    private func addAssets<T : PHCollection>(from collections: PHFetchResult<T>?) {
        if let datas = collections {
            for i in 0 ..< datas.count {
                if let collection = datas[i] as? PHAssetCollection {
                    let result = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                    if result.count > 0 || photosOptions.shouldDisplayEmptyCollection {
                        self.datas?.append(PhotosCollection(title: collection.localizedTitle, assets: result))
                    }
                }
            }
        }
    }

    // MARK: - UITableViewDelegate

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas?.count ?? 0
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotosListCell.gkNameOfClass, for: indexPath) as! PhotosListCell
        let collection = datas![indexPath.row]
        
        cell.titleLabel.text = collection.title
        cell.countLabel.text = "(\(collection.assets.count)"
        
        if collection.assets.count > 0 {
            cell.thumbnailImageView.backgroundColor = .clear
            cell.thumbnailImageView.image = nil
            
            let asset = collection.assets.firstObject!
            cell.assetLocalIdentifier = asset.localIdentifier
            
            imageManager?.requestImage(for: asset, targetSize: CGSize(60, 60), contentMode: .aspectFill, options: nil, resultHandler: { (image, _) in
                if asset.localIdentifier == cell.assetLocalIdentifier {
                    cell.thumbnailImageView.image = image
                    if image == nil {
                        cell.thumbnailImageView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
                    } else {
                        cell.thumbnailImageView.backgroundColor = .clear
                    }
                }
            })
        } else {
            cell.thumbnailImageView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
            cell.thumbnailImageView.image = nil
            cell.assetLocalIdentifier = nil
        }
        
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = PhotosGridViewController(options: photosOptions, collection: datas![indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }

}
