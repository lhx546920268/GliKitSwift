//
//  PhotosGridCell.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/29.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import Photos.PHAsset

///代理
protocol PhotosGridCellDelegate: AnyObject {
    
    ///选中某个图片
    func photosGridCellCheckedDidChange(_ cell: PhotosGridCell)
}

///相册网格
class PhotosGridCell: UICollectionViewCell {
    
    ///图片
    public let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    ///选中覆盖
    public private(set) lazy var overlay: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        contentView.insertSubview(view, belowSubview: checkBox)
        
        view.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        return view
    }()
    
    ///选中勾
    public let checkBox: PhotosCheckBox = {
        let checkBox = PhotosCheckBox()
        checkBox.contentInsets = .all(5)
        
        return checkBox
    }()
    
    ///asset标识符
    public var asset: PHAsset?
    
    ///代理
    public weak var delegate: PhotosGridCellDelegate?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        checkBox.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCheck)))
        contentView.addSubview(checkBox)
        checkBox.snp.makeConstraints { (make) in
            make.top.trailing.equalTo(0)
            make.size.equalTo(CGSize(30, 30))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///设置选中
    func setChecked(_ checked: Bool, animated: Bool = false) {
        if checked != checkBox.checked {
            overlay.isHidden = !checked
            checkBox.setChecked(checked, animated: animated)
        }
    }
    
    @objc private func handleCheck() {
        delegate?.photosGridCellCheckedDidChange(self)
    }
}
